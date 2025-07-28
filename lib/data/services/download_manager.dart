import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/models/download_error.dart';
import 'package:golden_moments/data/models/download_progress.dart';
import 'package:golden_moments/data/models/download_queue.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/models/pack_cache.dart';
import 'package:golden_moments/data/services/http_client_service.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/data/storage/cache_file_paths.dart';
import 'package:golden_moments/shared/utils/image_util.dart';
import 'package:golden_moments/shared/utils/string_util.dart';
import 'package:pool/pool.dart';

/// Download manager for processing pack and image downloads
class DownloadManager extends ChangeNotifier {
  factory DownloadManager() => _instance;
  DownloadManager._internal();
  static final DownloadManager _instance = DownloadManager._internal();

  final JsonCacheService _cacheService = JsonCacheService();
  final LocalPackService _localPackService = LocalPackService();
  final HttpClientService _httpClient = HttpClientService();

  final Map<String, StreamController<DownloadProgress>> _progressControllers =
      {};

  // Handle Pack Status
  final Map<String, PackStatus> _packsStatus = {};
  final _packStatusController =
      StreamController<MapEntry<String, PackStatus>>.broadcast();
  Stream<MapEntry<String, PackStatus>> get onStatusChanged =>
      _packStatusController.stream;

  final Map<String, PackDownloadProgress> _packsProgress = {};
  final Map<String, DownloadQueue> _packsDownloadQueue = {};

  final Pool _pool = Pool(3);

  Timer? _queueProcessor;

  // Load completed downloads from disk
  Future<void> initialize() async {
    final packs = await _localPackService.getPacks();
    for (final pack in packs) {
      if (await _cacheService.isPackCached(pack.id)) {
        _packsStatus[pack.id] = PackStatus.completed;
      } else {
        _packsStatus[pack.id] = PackStatus.notStarted;
      }
    }
  }

  PackStatus getPackStatus(String packId) {
    return _packsStatus[packId] ?? PackStatus.notStarted;
  }

  Map<String, PackStatus> getPacksStatus() {
    return _packsStatus;
  }

  bool isDownloaded(String packId) =>
      (_packsStatus[packId] ?? PackStatus.notStarted) == PackStatus.completed;

  /// Download a complete pack
  Future<void> downloadPack(String packId) async {
    try {
      // Wait for downloading slot to prevent network congestion
      final pooled = await _pool.request();

      _packsStatus[packId] = PackStatus.downloading;
      notifyListeners();

      // Get pack from local service (packs_index.json)
      final pack = await _localPackService.getPackById(packId);

      final isSpacesAvailable = await checkFreeSpaceBeforeDownload(
        parseSizeToBytes(pack.estimatedSize),
      );

      if (!isSpacesAvailable) return;

      // Create pack cache entry from local pack
      final packCache = PackCache.create(
        id: packId,
        version: pack.version,
        manifest: pack,
      );

      // Save initial pack cache
      await _cacheService.savePackCache(packCache);

      var downloadQueue = DownloadQueue.empty();

      final imageProgresses = <DownloadProgress>[];
      // Queue image downloads
      for (final image in pack.images) {
        // await _queueImageDownload(packId, image.id, image.url);
        // Create a pack progress

        imageProgresses.add(
          DownloadProgress.started(
            downloadId: generateDownloadId(packId, image.id),
            packId: packId,
            imageId: image.id,
            totalBytes: 0, // Will be updated during download
          ),
        );

        final downloadId = generateDownloadId(packId, image.id);

        downloadQueue = downloadQueue.addDownload(
          DownloadItem(
            id: downloadId,
            packId: packId,
            imageId: image.id,
            type: DownloadType.image,
            status: DownloadStatus.queued,
            priority: 1,
            retryCount: 0,
            queuedAt: DateTime.now(),
          ),
        );
      }

      final pdp = PackDownloadProgress(
        packId: packId,
        imageProgresses: imageProgresses,
        startTime: imageProgresses.first.startTime,
      );

      _packsProgress[packId] = pdp;
      _packsDownloadQueue[packId] = downloadQueue;

      // Process downloading
      await _processQueue(packId);

      // Handle Complete pack download here
      _packsStatus[packId] = PackStatus.completed;
      _packStatusController.add(MapEntry(packId, PackStatus.completed));
      notifyListeners();
      pooled.release();
    } catch (e) {
      throw e is DownloadError
          ? e
          : DownloadError.unknown(packId, e.toString());
    }
  }

  double getPackDownloadProgress(String packId) {
    if (_packsProgress.containsKey(packId)) {
      return _packsProgress[packId]!.progressByImage;
    } else {
      return 0;
    }
  }

  /// Get current download queue
  Future<DownloadQueue> getDownloadQueue() async {
    return _cacheService.loadDownloadQueue();
  }

  /// Process download queue
  Future<void> _processQueue(String packId) async {
    if (!_packsDownloadQueue.containsKey(packId)) return;
    final queue = _packsDownloadQueue[packId]!;

    // Start new downloads if under limit

    for (final entry in queue.queuedDownloads) {
      await _startDownload(entry);
    }
  }

  /// Start individual download
  Future<void> _startDownload(DownloadItem item) async {
    final downloadId = item.id;

    // Update queue to mark as active
    if (!_packsDownloadQueue.containsKey(item.packId)) return;
    _packsDownloadQueue[item.packId] = _packsDownloadQueue[item.packId]!
        .startDownload(downloadId);

    try {
      if (item.type == DownloadType.image) {
        await _downloadImage(item);
      }
    } on Exception catch (e) {
      await _handleDownloadError(item, e);
    }
  }

  /// Download individual image
  Future<void> _downloadImage(DownloadItem item) async {
    final downloadId = item.id;
    final packId = item.packId;
    final imageId = item.imageId!;

    // Get image URL from pack cache
    final packCache = await _cacheService.loadPackCache(packId);
    if (packCache == null) {
      throw DownloadError.unknown(downloadId, 'Pack cache not found');
    }

    final tile = packCache.manifest.images.firstWhere((t) => t.id == imageId);
    final imageUrl = tile.url;
    // Extract filename from URL for local storage
    final filename = '$imageId.jpg'; // Use consistent filename

    // Download with progress tracking
    final startTime = DateTime.now();

    // Emit progress (we'll get total bytes during download)
    final initialProgress = DownloadProgress.started(
      downloadId: downloadId,
      packId: packId,
      imageId: imageId,
      totalBytes: 0, // Will be updated during download
    );

    _emitProgress(initialProgress);

    // Download image data using HTTP client
    final imageData = await _httpClient.downloadBinary(
      imageUrl,
      onProgress: (int downloaded, int total) {
        // Calculate speed and ETA
        final elapsed = DateTime.now().difference(startTime);
        final speed = _httpClient.calculateDownloadSpeed(downloaded, elapsed);
        final eta = _httpClient.calculateETA(total - downloaded, speed);

        // Emit progress update with updated total bytes
        final progress =
            DownloadProgress.started(
              downloadId: downloadId,
              packId: packId,
              imageId: imageId,
              totalBytes: total,
            ).updateProgress(
              bytesDownloaded: downloaded,
              speed: speed,
              eta: eta,
            );
        _emitProgress(progress);
      },
    );

    // Save image to cache
    final imagePath = CacheFilePaths.imageFile(packId, filename);
    final fullPath = _cacheService.fileManager.getCachePath(imagePath);
    final imageFile = File(fullPath);

    // Ensure directory exists
    await imageFile.parent.create(recursive: true);

    // Write image data
    await imageFile.writeAsBytes(imageData);

    // Verify checksum if available
    final checksum = sha256.convert(imageData).toString();

    // Update pack cache with downloaded image
    final cachedImage = CachedImage.create(
      id: imageId,
      filename: filename,
      caption: tile.caption,
      altText: tile.caption,
      localPath: imagePath,
      downloadUrl: imageUrl,
      size: imageData.length,
      dimensions: '400x400', // TODO: Get actual dimensions
      format: filename.split('.').last.toUpperCase(),
      checksum: checksum,
    );

    final updatedPackCache = packCache.addImage(cachedImage);
    await _cacheService.savePackCache(updatedPackCache);

    // Mark download as completed
    _completeDownload(item);

    // Emit completion progress
    _emitProgress(initialProgress.complete());
  }

  /// Complete download
  void _completeDownload(DownloadItem item) {
    if (!_packsDownloadQueue.containsKey(item.packId)) return;
    _packsDownloadQueue[item.packId]!.completeDownload(item.id);
  }

  /// Handle download error
  Future<void> _handleDownloadError(DownloadItem item, dynamic error) async {
    final downloadError = error is DownloadError
        ? error
        : DownloadError.unknown(item.id, error.toString());

    // Update queue with failure
    final queue = await _cacheService.loadDownloadQueue();
    final updatedQueue = queue.failDownload(item.id, downloadError.message);
    await _cacheService.saveDownloadQueue(updatedQueue);

    // Emit error progress
    _emitProgress(
      DownloadProgress.failed(
        downloadId: item.id,
        packId: item.packId,
        imageId: item.imageId,
        bytesDownloaded: 0,
        totalBytes: 0,
        startTime: DateTime.now(),
        error: downloadError,
      ),
    );
  }

  /// Emit progress update
  void _emitProgress(DownloadProgress progress) {
    final controller = _progressControllers[progress.downloadId];
    if (controller != null && !controller.isClosed) {
      controller.add(progress);
    }

    if (_packsProgress.containsKey(progress.packId)) {
      final imagesProgress = _packsProgress[progress.packId]!.imageProgresses;
      final index = imagesProgress.indexWhere(
        (imageProgress) => imageProgress.imageId == progress.imageId,
      );
      imagesProgress[index] = progress;
    } else {
      return;
    }
  }

  Future<bool> checkFreeSpaceBeforeDownload(int downloadFileSizeInBytes) async {
    final diskSpacePlus = DiskSpacePlus();
    final freeDiskSpace = await diskSpacePlus.getFreeDiskSpace ?? 0;
    if ((freeDiskSpace * 1024 * 1024) >
        downloadFileSizeInBytes + 200 * 1024 * 1024) {
      return true;
    } else {
      return false;
    }
  }

  /// Delete a pack
  Future<void> deletePack(String packId) async {
    final pack = await _localPackService.getPackById(packId);
    for (final image in pack.images) {
      final file = File(getImageLocalPath(image.id, packId));
      if (file.existsSync()) {
        await file.delete();
      }
    }
    await _cacheService.deletePackCache(packId);
    _packsStatus[packId] = PackStatus.notStarted;
    _packStatusController.add(MapEntry(packId, PackStatus.notStarted));
    notifyListeners();
  }
}
