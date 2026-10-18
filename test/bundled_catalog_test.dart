import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/features/game/cubit/game_cubit.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';

Iterable<String> _paths(Object? value) sync* {
  if (value is Map<String, dynamic>) {
    for (final child in value.values) {
      yield* _paths(child);
    }
  } else if (value is List<dynamic>) {
    for (final child in value) {
      yield* _paths(child);
    }
  } else if (value is String &&
      (value.startsWith('assets/') || value.startsWith('http'))) {
    yield value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'every bundled pack starts without cache or plugin initialization',
    () async {
      for (final pack in await LocalPackService().getPacks()) {
        final cubit = GameCubit();
        await cubit.loadAndStartGame(pack.id);
        expect(cubit.state.status, GameStatus.playing, reason: pack.id);
        expect(cubit.state.tiles.length, pack.difficulty.totalTiles);
        await cubit.close();
      }
    },
  );
  test('every catalog image is a packaged, decodable local image', () async {
    final index = jsonDecode(
      await rootBundle.loadString('assets/data/packs_index.json'),
    );
    final paths = _paths(index).toSet();
    expect(paths.length, 121);
    for (final path in paths) {
      expect(path, startsWith('assets/images/catalog/'));
      final bytes = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(0), reason: path);
      expect(frame.image.height, greaterThan(0), reason: path);
      frame.image.dispose();
      codec.dispose();
    }
  });
}
