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
    await FirebaseAnalytics.instance.logScreenView(
      screenName: 'Downloaded',
    );
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
  }

  Future<List<Pack>> _loadPacks() async {
    return LocalPackService().getPacks();
  }

  /// Download all packs
  Future<void> downloadAllPacks() async {
    // emit(state.copyWith(status: DownloadedPacksPageStatus.loading));

    // Simulate downloading all packs
    final packs = await _loadPacks();
    for (final pack in packs) {
      if (!await JsonCacheService().isPackCached(pack.id)) {
        await DownloadManager().downloadPack(pack.id);
      }
    }

    // emit(
    //   state.copyWith(
    //     status: DownloadedPacksPageStatus.loaded,
    //     downloadedPacks: allPacks,
    //   ),
    // );
  }

  /// Delete selected packs
  Future<void> deletePacks(List<Pack> packsToDelete) async {
    for (final pack in packsToDelete) {
      await DownloadManager().deletePack(pack.id);
    }

    await initialize();
  }
}
