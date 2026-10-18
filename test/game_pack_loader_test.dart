import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/features/game/cubit/game_cubit.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads a game from a bundled pack with no cache or download', () async {
    final pack = (await LocalPackService().getPacks()).first;
    final cubit = GameCubit();
    addTearDown(cubit.close);
    await cubit.loadAndStartGame(pack.id);
    expect(cubit.state.status, GameStatus.playing);
    expect(cubit.state.tiles.length, pack.difficulty.totalTiles);
  });

  test('unknown packs fail without crashing', () async {
    final cubit = GameCubit();
    addTearDown(cubit.close);
    await cubit.loadAndStartGame('missing');
    expect(cubit.state.status, GameStatus.failed);
  });
}
