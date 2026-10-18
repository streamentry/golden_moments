import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/features/game/cubit/game_cubit.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';
import 'package:golden_moments/shared/utils/image_util.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _Paths extends PathProviderPlatform with MockPlatformInterfaceMixin {
  new(this.root);
  final String root;
  @override
  Future<String?> getApplicationDocumentsPath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('golden-game-test-');
    final original = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(root.path);
    addTearDown(() {
      PathProviderPlatform.instance = original;
    });
    await JsonCacheService().initialize();
  });
  tearDownAll(() => root.delete(recursive: true));
  test('loads a game from real cached image files', () async {
    final pack = (await LocalPackService().getPacks()).first;
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aN1cAAAAASUVORK5CYII=',
    );
    for (final image in pack.images) {
      final file = File(getImageLocalPath(image.id, pack.id));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(png);
    }
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
