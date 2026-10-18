import 'dart:async';
import 'dart:io';

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
import 'package:golden_moments/data/storage/browser_image_store.dart';
import 'package:golden_moments/data/storage/cache_file_paths.dart';
import 'package:golden_moments/shared/utils/image_util.dart';
import 'package:golden_moments/shared/utils/string_util.dart';
import 'package:pool/pool.dart';

/// Download manager for processing pack and image downloads
class DownloadManager extends ChangeNotifier {
  factory() => _instance;
  DownloadManager._internal();
  static final DownloadManager _instance = DownloadManager._internal();

  final JsonCacheService _cacheService = JsonCacheService();
  final LocalPackService _localPackService = LocalPackService();
  final HttpClientService _httpClient = HttpClientService();

  // Handle Pack Status
  final Map<String, PackStatus> _packsStatus = {};
  final _packStatusController =
      StreamController<MapEntry<String, PackStatus>>.broadcast();
  Stream<MapEntry<String, PackStatus>> get onStatusChanged =>
      _packStatusController.stream;

  final Map<String, PackDownloadProgress> _packsProgress = {};
  final Map<String, DownloadQueue> _packsDownloadQueue = {};

  final Pool _pool = Pool(3);

  // Load completed downloads from disk
  Future<void> initialize() async {
    final packs = await _localPackService.getPacks();
    for (final pack in packs) {
      var cached = await _cacheService.isPackCached(pack.id);
      if (kIsWeb && cached) {
        // Repair metadata from web builds that discarded image bytes.
        for (final image in pack.images) {
          final bytes = await BrowserImageStore.read(image.url);
          if (bytes == null || bytes.isEmpty) {
            cached = false;
            await _cacheService.deletePackCache(pack.id);
            break;
          }
        }
      }
      if (cached) {
        _packsStatus[pack.id] = PackStatus.completed;
      } else {
        _packsStatus[pack.id] = PackStatus.notStarted;
      }
    }
    notifyListeners();
  }

  // Execute download initial packs
  Future<void> downloadInitialPacks() async {
    // Simulate downloading all packs
    final packs = await _localPackService.getPacks();
    for (final pack in packs) {
      if (!await JsonCacheService().isPackCached(pack.id)) {
        unawaited(
          downloadPack(pack.id).catchError((Object error) {
            debugPrint('Could not download ${pack.id}: $error');
          }),
        );
      }
    }
  }

  @override
  void dispose() {
    _packStatusController.close();
    super.dispose();
    // cancel or cleanup other resources if needed
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
    PoolResource? pooled;
    try {
      // Wait for downloading slot to prevent network congestion
      pooled = await _pool.request();

      _packsStatus[packId] = PackStatus.downloading;
      notifyListeners();

      // Get pack from local service (packs_index.json)
      final pack = await _localPackService.getPackById(packId);

      final isSpacesAvailable = await checkFreeSpaceBeforeDownload(
        parseSizeToBytes(pack.estimatedSize),
      );

      if (!isSpacesAvailable) {
        throw StateError('Not enough space to download this pack.');
      }

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
            imageUrl: image.url,
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

      // Save to local
      final packCache = PackCache.create(
        id: packId,
        version: pack.version,
        manifest: pack,
      );

      // Save initial pack cache
      await _cacheService.savePackCache(packCache);

      notifyListeners();
    } on Object catch (e) {
      _packsStatus[packId] = PackStatus.notStarted;
      _packStatusController.add(MapEntry(packId, PackStatus.notStarted));
      notifyListeners();
      throw e is DownloadError
          ? e
          : DownloadError.unknown('pack:$packId', e.toString());
    } finally {
      pooled?.release();
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
      rethrow;
    }
  }

  /// Download individual image
  Future<void> _downloadImage(DownloadItem item) async {
    final downloadId = item.id;
    final packId = item.packId;
    final imageId = item.imageId;
    final imageUrl = item.imageUrl;

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
      onProgress: (downloaded, total) {
        // Calculate speed and ETA
        final elapsed = DateTime.now().difference(startTime);
        final speed = _httpClient.calculateDownloadSpeed(downloaded, elapsed);
        final eta = _httpClient.calculateETA(total - downloaded, speed);

        // Emit progress update with updated total bytes
        final progress = DownloadProgress.started(
          downloadId: downloadId,
          packId: packId,
          imageId: imageId,
          totalBytes: total,
        ).updateProgress(bytesDownloaded: downloaded, speed: speed, eta: eta);
        _emitProgress(progress);
      },
    );

    // Persist bytes before marking a download complete on either platform.
    if (kIsWeb) {
      await BrowserImageStore.write(imageUrl, imageData);
    } else {
      try {
        final imagePath = CacheFilePaths.imageFile(packId, filename);
        final fullPath = _cacheService.fileManager.getCachePath(imagePath);
        final imageFile = File(fullPath);

        // Ensure directory exists
        await imageFile.parent.create(recursive: true);

        // Write image data
        await imageFile.writeAsBytes(imageData);
      } on Exception catch (e) {
        // On web, we can't save files directly
        debugPrint('Could not save image file (web platform): $e');
      }
    }

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
  Future<void> _handleDownloadError(DownloadItem item, Exception error) async {
    final downloadError = error is DownloadError
        ? error
        : DownloadError.unknown(item.imageUrl, error.toString());

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
    // On web, always return true to prevent blocking downloads
    if (kIsWeb) {
      return true;
    }

    try {
      final diskSpacePlus = DiskSpacePlus();
      final freeDiskSpace = await diskSpacePlus.getFreeDiskSpace ?? 0;
      if ((freeDiskSpace * 1024 * 1024) >
          downloadFileSizeInBytes + 200 * 1024 * 1024) {
        return true;
      } else {
        return false;
      }
    } on Object {
      // On platforms where disk space check isn't available,
      // assume there's enough space to prevent blocking downloads
      return true;
    }
  }

  /// Delete a pack
  Future<void> deletePack(String packId) async {
    if (kIsWeb) {
      final pack = await _localPackService.getPackById(packId);
      for (final image in pack.images) {
        await BrowserImageStore.delete(image.url);
      }
    }
    // Only try to delete files on non-web platforms
    if (!kIsWeb) {
      try {
        final pack = await _localPackService.getPackById(packId);
        for (final image in pack.images) {
          final file = File(getImageLocalPath(image.id, packId));
          if (file.existsSync()) {
            await file.delete();
          }
        }
      } on Exception catch (e) {
        // Ignore file deletion errors on web
        debugPrint('Error deleting pack files: $e');
      }
    }

    await _cacheService.deletePackCache(packId);
    _packsStatus[packId] = PackStatus.notStarted;
    _packStatusController.add(MapEntry(packId, PackStatus.notStarted));
    notifyListeners();
  }
}
