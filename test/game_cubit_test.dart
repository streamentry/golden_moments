import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/models/image.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/features/game/cubit/game_cubit.dart';
import 'package:golden_moments/shared/constants/app_constants.dart';

class _SeededGameCubit extends GameCubit {
  _SeededGameCubit(List<Image> images) {
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
    await tester.pump(AppConstants.mismatchDisplayDuration);
    expect(tester.takeException(), isNull);
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
