import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/github_pack_index.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/data/services/long_term_image_cache.dart';
import 'package:golden_moments/game/models/models.dart';
import 'package:golden_moments/shared/widgets/download_progress_card.dart';

/// Cubit for managing pack details state
class PackDetailsCubit extends Cubit<PackDetailsState> {
  PackDetailsCubit(this.packInfo) : super(PackDetailsState(packInfo: packInfo));

  final GitHubPackInfo packInfo;
  final LocalPackService _packService = LocalPackService.instance;
  final LongTermImageCache _imageCache = LongTermImageCache.instance;

  /// Initialize pack details
  Future<void> initialize() async {
    emit(state.copyWith(status: PackDetailsStatus.loading));

    try {
      // Convert pack info to game pack
      final gamePack = _packService.convertToGamePack(packInfo);

      // Check if images are cached
      final imageUrls = packInfo.images
          .map((img) => img['url'] as String)
          .toList();
      final cachedCount = await _countCachedImages(imageUrls);

      final downloadStatus = cachedCount == imageUrls.length
          ? PackDownloadStatus.cached
          : PackDownloadStatus.available;

      emit(
        state.copyWith(
          status: PackDetailsStatus.loaded,
          downloadStatus: downloadStatus,
          gamePack: gamePack,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PackDetailsStatus.error,
          errorMessage: 'Failed to load pack details: $e',
        ),
      );
    }
  }

  /// Start downloading/caching the pack images
  Future<void> startDownload() async {
    emit(state.copyWith(downloadStatus: PackDownloadStatus.downloading));

    try {
      final imageUrls = packInfo.images
          .map((img) => img['url'] as String)
          .toList();
      await _imageCache.preloadPackImages(imageUrls);

      emit(
        state.copyWith(
          downloadStatus: PackDownloadStatus.cached,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          downloadStatus: PackDownloadStatus.failed,
          errorMessage: 'Failed to cache images: $e',
        ),
      );
    }
  }

  /// Count how many images are already cached
  Future<int> _countCachedImages(List<String> imageUrls) async {
    int cachedCount = 0;
    for (final url in imageUrls) {
      if (await _imageCache.isImageCached(url)) {
        cachedCount++;
      }
    }
    return cachedCount;
  }

  /// Refresh pack details
  Future<void> refresh() async {
    await initialize();
  }
}

/// Pack details state
class PackDetailsState extends Equatable {
  const PackDetailsState({
    required this.packInfo,
    this.status = PackDetailsStatus.initial,
    this.downloadStatus = PackDownloadStatus.available,
    this.gamePack,
    this.errorMessage = '',
  });

  final GitHubPackInfo packInfo;
  final PackDetailsStatus status;
  final PackDownloadStatus downloadStatus;
  final GamePack? gamePack;
  final String errorMessage;

  /// Check if pack can be played
  bool get canPlay =>
      gamePack != null && downloadStatus == PackDownloadStatus.cached;

  /// Check if pack is downloading
  bool get isDownloading => downloadStatus == PackDownloadStatus.downloading;

  /// Check if pack is cached
  bool get isCached => downloadStatus == PackDownloadStatus.cached;

  /// Check if download failed
  bool get downloadFailed => downloadStatus == PackDownloadStatus.failed;

  PackDetailsState copyWith({
    GitHubPackInfo? packInfo,
    PackDetailsStatus? status,
    PackDownloadStatus? downloadStatus,
    GamePack? gamePack,
    String? errorMessage,
  }) {
    return PackDetailsState(
      packInfo: packInfo ?? this.packInfo,
      status: status ?? this.status,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      gamePack: gamePack ?? this.gamePack,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    packInfo,
    status,
    downloadStatus,
    gamePack,
    errorMessage,
  ];
}

/// Pack details status enumeration
enum PackDetailsStatus {
  initial,
  loading,
  loaded,
  error,
}
