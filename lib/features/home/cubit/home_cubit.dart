import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:golden_moments/data/models/packs_index.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/features/home/cubit/home_state.dart';
import 'package:golden_moments/features/home/data/pack_preferences.dart';
import 'package:golden_moments/features/home/data/pack_selection.dart';

/// Loads the included catalog.
typedef CatalogLoader = Future<PacksIndex> Function();

/// Cubit for the included-pack library: the catalog plus the person's
/// favorites and "Not for me" choices (see `pack_selection.dart` for how they
/// combine). Nothing here launches a pack or changes on a timer.
class HomeCubit extends Cubit<HomeState> {
  new({
    PackPreferencesStore preferencesStore = const PackPreferencesStore(),
    CatalogLoader? loadCatalog,
  }) : _store = preferencesStore,
       _loadCatalog = loadCatalog ?? LocalPackService().getPacksIndex,
       super(const HomeState());

  final PackPreferencesStore _store;
  final CatalogLoader _loadCatalog;

  /// Saves run one after another so an older choice never lands last.
  Future<void> _saving = Future.value();

  /// How long the catalog waits for saved choices before it opens without
  /// them. Storage trouble must never keep the included packs from opening.
  static const Duration preferencesGrace = Duration(seconds: 1);

  /// Initialize the home screen with data.
  ///
  /// Saved choices load alongside the catalog. If they are slow, the catalog
  /// opens first with Favorite and Not for me turned off until they arrive,
  /// so a late load can never overwrite them.
  Future<void> initialize() async {
    emit(state.copyWith(status: HomeStatus.loading));
    // Choices already loaded stay authoritative: every change goes through
    // this cubit.
    final pending = state.preferencesReady ? null : _store.load();

    try {
      final index = await _loadCatalog();
      final early = pending == null ? null : await _within(pending);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          packs: List.unmodifiable(index.packs),
          libraryPacks: List.unmodifiable(index.categories),
          packPreferences: early,
          preferencesReady: pending == null || early != null,
        ),
      );
      if (pending != null && early == null) {
        final late = await pending;
        if (!isClosed) {
          emit(state.copyWith(packPreferences: late, preferencesReady: true));
        }
      }
    } on Object catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<PackPreferences?> _within(Future<PackPreferences> pending) async {
    try {
      return await pending.timeout(preferencesGrace);
    } on TimeoutException {
      return null;
    }
  }

  /// Marks or unmarks [packId] as a favorite.
  Future<void> setFavorite(String packId, {required bool favorite}) => _change(
    packId,
    (prefs) => prefs.withFavorite(packId, favorite: favorite),
  );

  /// "Not for me": hides [packId] everywhere except the hidden list. Nothing
  /// is deleted, and it stays hidden until the person shows it again.
  Future<void> hidePack(String packId) =>
      _change(packId, (prefs) => prefs.withHidden(packId, hide: true));

  /// Shows a hidden pack again.
  Future<void> showPack(String packId) =>
      _change(packId, (prefs) => prefs.withHidden(packId, hide: false));

  /// Moves to the next few suggestions, only when the person asks.
  void showOtherSuggestions() {
    if (!state.hasOtherSuggestions) return;
    emit(
      state.copyWith(
        suggestionOffset: state.suggestionOffset + suggestionCount,
      ),
    );
  }

  Future<void> _change(
    String packId,
    PackPreferences Function(PackPreferences) change,
  ) async {
    // Ignore ids that are not in the included catalog, and any change before
    // the saved choices are known.
    if (state.status != HomeStatus.loaded ||
        !state.preferencesReady ||
        !state.packs.any((pack) => pack.id == packId)) {
      return;
    }
    final next = change(state.packPreferences);
    if (next == state.packPreferences) return;
    emit(state.copyWith(packPreferences: next));
    final saved = await _enqueueSave(next);
    if (!isClosed) emit(state.copyWith(preferencesSaveFailed: !saved));
  }

  Future<bool> _enqueueSave(PackPreferences value) {
    final result = _saving.then((_) => _store.save(value));
    _saving = result.then<void>((_) {}, onError: (Object _) {});
    return result.catchError((Object _) => false);
  }
}
