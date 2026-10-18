import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/models/image.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/features/game/cubit/game_cubit.dart';

class _SeededGameCubit extends GameCubit {
  new(List<Image> images) {
    emit(state.copyWith(images: images));
  }
}

void main() {
  final images = List.generate(
    8,
    (index) => Image(
      id: 'image_$index',
      url: 'https://example.com/$index.jpg',
      caption: 'Image $index',
    ),
  );
  final pack = Pack(
    id: 'test',
    title: 'Test',
    theme: 'Test',
    category: 'test',
    version: '1',
    difficulty: GameDifficulty.medium,
    thumbnailUrl: images.first.url,
    images: images,
    estimatedSize: '1 MB',
  );

  test('matching a pair updates progress and replay clears it', () async {
    final cubit = _SeededGameCubit(images)..startNewGame(pack);
    addTearDown(cubit.close);
    expect(cubit.state.tiles.length, 16);
    expect(cubit.state.tiles.map((tile) => tile.id).toSet().length, 16);
    final first = cubit.state.tiles.first;
    final second = cubit.state.tiles.firstWhere(
      (tile) => tile.pairId == first.pairId && tile.id != first.id,
    );
    cubit
      ..onTileTap(first.id)
      ..onTileTap(second.id);
    expect(cubit.state.matchedPairs, 1);
    expect(cubit.state.tiles.where((tile) => tile.isMatched).length, 2);
    expect(cubit.state.selectedTiles, isEmpty);
    cubit.resetGame();
    expect(cubit.state.matchedPairs, 0);
    expect(cubit.state.moves, 0);
    expect(cubit.state.tiles.every((tile) => !tile.isRevealed), isTrue);
  });

  testWidgets('leaving during a mismatch cancels delayed state updates', (
    tester,
  ) async {
    final cubit = _SeededGameCubit(images)..startNewGame(pack);
    final first = cubit.state.tiles.first;
    final second = cubit.state.tiles.firstWhere(
      (tile) => tile.pairId != first.pairId,
    );
    cubit
      ..onTileTap(first.id)
      ..onTileTap(second.id);
    expect(cubit.state.showingMismatch, isTrue);
    await cubit.close();
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a mismatch stays visible until the next deliberate tap', (
    tester,
  ) async {
    final cubit = _SeededGameCubit(images)..startNewGame(pack);
    addTearDown(cubit.close);
    final first = cubit.state.tiles.first;
    final second = cubit.state.tiles.firstWhere(
      (tile) => tile.pairId != first.pairId,
    );
    cubit
      ..onTileTap(first.id)
      ..onTileTap(second.id);

    // No timer: much later, both pictures are still face up.
    await tester.pump(const Duration(minutes: 5));
    bool revealed(String id) =>
        cubit.state.tiles.firstWhere((tile) => tile.id == id).isRevealed;
    expect(cubit.state.showingMismatch, isTrue);
    expect(revealed(first.id), isTrue);
    expect(revealed(second.id), isTrue);

    // The next tap turns them over and starts the new turn.
    final third = cubit.state.tiles.firstWhere(
      (tile) => tile.id != first.id && tile.id != second.id,
    );
    cubit.onTileTap(third.id);
    expect(cubit.state.showingMismatch, isFalse);
    expect(revealed(first.id), isFalse);
    expect(revealed(second.id), isFalse);
    expect(revealed(third.id), isTrue);
    expect(cubit.state.selectedTiles.map((tile) => tile.id), [third.id]);
  });

  testWidgets('tapping a mismatched picture again selects it', (tester) async {
    final cubit = _SeededGameCubit(images)..startNewGame(pack);
    addTearDown(cubit.close);
    final first = cubit.state.tiles.first;
    final second = cubit.state.tiles.firstWhere(
      (tile) => tile.pairId != first.pairId,
    );
    cubit
      ..onTileTap(first.id)
      ..onTileTap(second.id)
      ..onTileTap(first.id);
    expect(cubit.state.showingMismatch, isFalse);
    expect(cubit.state.selectedTiles.map((tile) => tile.id), [first.id]);
  });

  testWidgets('a hint stays visible until the next tap', (tester) async {
    final cubit = _SeededGameCubit(images)
      ..startNewGame(pack)
      ..showHint();
    addTearDown(cubit.close);
    final hinted = cubit.state.hintTileIds;
    expect(hinted, hasLength(2));
    await tester.pump(const Duration(minutes: 5));
    expect(cubit.state.tiles.where((tile) => tile.isRevealed), hasLength(2));

    // Tapping one hinted picture, then its partner, makes the match.
    cubit
      ..onTileTap(hinted.first)
      ..onTileTap(hinted.last);
    expect(cubit.state.hintTileIds, isEmpty);
    expect(cubit.state.matchedPairs, 1);
  });

  testWidgets('leaving during a hint cancels delayed state updates', (
    tester,
  ) async {
    final cubit = _SeededGameCubit(images)
      ..startNewGame(pack)
      ..showHint();
    expect(cubit.state.tiles.where((tile) => tile.isRevealed).length, 2);
    await cubit.close();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
