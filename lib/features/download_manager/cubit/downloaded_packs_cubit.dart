import 'package:bloc/bloc.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/features/download_manager/cubit/downloaded_packs_state.dart';

/// Cubit for managing home screen state and logic
class DownloadedPacksCubit extends Cubit<DownloadedPacksState> {
  DownloadedPacksCubit() : super(const DownloadedPacksState());

  /// Initialize the home screen with data
  Future<void> initialize() async {
    emit(state.copyWith(status: DownloadedPacksPageStatus.loading));

    // Load all packs
    final packs = await _loadPacks();

    final downloadedPacks = <Pack>[];
    for (final pack in packs) {
      if (await JsonCacheService().isPackCached(pack.id)) {
        downloadedPacks.add(pack);
      }
    }

    emit(
      state.copyWith(
        status: DownloadedPacksPageStatus.loaded,
        downloadedPacks: downloadedPacks,
      ),
    );
  }

  Future<List<Pack>> _loadPacks() async {
    return LocalPackService().getPacks();
  }
}
