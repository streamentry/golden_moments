import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/download_manager.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/features/download_manager/cubit/downloaded_packs_state.dart';

/// Cubit for managing home screen state and logic
class DownloadedPacksCubit extends Cubit<DownloadedPacksState> {
  DownloadedPacksCubit() : super(const DownloadedPacksState());

  /// Initialize the home screen with data
  Future<void> initialize() async {
    // Try to log screen view, but don't fail if Firebase isn't available
    try {
      await FirebaseAnalytics.instance.logScreenView(
        screenName: 'Downloaded',
      );
    } catch (e) {
      // Silently ignore Firebase Analytics errors
      // This allows the app to work without Firebase
    }

    emit(state.copyWith(status: DownloadedPacksPageStatus.loading));

    // Load all packs
    final packs = await _loadPacks();

    final downloadedPacks = <Pack>[];
    final notDownloadedPacks = <Pack>[];
    for (final pack in packs) {
      if (await JsonCacheService().isPackCached(pack.id)) {
        downloadedPacks.add(pack);
      } else {
        notDownloadedPacks.add(pack);
      }
    }

    emit(
      state.copyWith(
        status: DownloadedPacksPageStatus.loaded,
        packs: packs,
        downloadedPacks: downloadedPacks,
        notDownloadedPacks: notDownloadedPacks,
      ),
    );

    // Listening for status change event
    DownloadManager().onStatusChanged.listen((event) async {
      final packs = await _loadPacks();
      final downloadedPacks = state.downloadedPacks;
      final notDownloadedPacks = state.notDownloadedPacks;

      final isDownloaded = event.value == PackStatus.completed;

      // Remove from both lists just in case
      downloadedPacks.removeWhere((p) => p.id == event.key);
      notDownloadedPacks.removeWhere((p) => p.id == event.key);

      final pack = packs.firstWhere((p) => p.id == event.key);

      // Add to the correct list
      if (isDownloaded) {
        downloadedPacks.add(pack);
      } else {
        notDownloadedPacks.add(pack);
      }

      emit(
        state.copyWith(
          downloadedPacks: downloadedPacks,
          notDownloadedPacks: notDownloadedPacks,
        ),
      );
    });
  }

  Future<List<Pack>> _loadPacks() async {
    return LocalPackService().getPacks();
  }

  /// Download all packs
  Future<void> downloadAllPacks() async {
    // Simulate downloading all packs
    final packs = await _loadPacks();
    for (final pack in packs) {
      if (!await JsonCacheService().isPackCached(pack.id)) {
        unawaited(DownloadManager().downloadPack(pack.id));
      }
    }
  }

  /// Delete selected packs
  Future<void> deletePacks(List<Pack> packsToDelete) async {
    for (final pack in packsToDelete) {
      await DownloadManager().deletePack(pack.id);
    }

    await initialize();
  }
}
