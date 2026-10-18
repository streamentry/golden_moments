import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/game_cubit.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_board.dart';
import 'package:provider/provider.dart';

/// The legacy picture-pack route as the app builds it: theme, sound
/// settings provider, and the system text/motion settings under test.
Widget legacyApp(
  Widget home, {
  double textScale = 1,
  bool reduceMotion = false,
}) => ChangeNotifierProvider<SoundSettings>(
  create: (_) => SoundSettings(),
  child: MaterialApp(
    theme: gmBuildTheme(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: reduceMotion,
      ),
      child: child!,
    ),
    home: home,
  ),
);

/// A plain first screen that opens [page], so Back has somewhere to go.
class Launcher extends StatelessWidget {
  const new({required this.page, super.key});

  final Widget page;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: FilledButton(
        onPressed: () =>
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => page)),
        child: const Text('Open'),
      ),
    ),
  );
}

/// Opens [page] on top of [Launcher] and waits for it to settle.
Future<void> openPage(
  WidgetTester tester,
  Widget page, {
  double textScale = 1,
  bool reduceMotion = false,
}) async {
  await tester.pumpWidget(
    legacyApp(
      Launcher(page: page),
      textScale: textScale,
      reduceMotion: reduceMotion,
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

/// Loads the bundled catalog outside the fake clock.
Future<Pack> bundledPack(WidgetTester tester, String id) async =>
    (await tester.runAsync(() => LocalPackService().getPackById(id)))!;

Future<void> setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Every board tile, found the way a screen reader sees it.
final Finder boardTiles = find.bySemanticsLabel(RegExp(r', tile \d+$'));

Finder boardTile(int position) =>
    find.bySemanticsLabel(RegExp(', tile $position\$'));

GameCubit gameCubit(WidgetTester tester) =>
    BlocProvider.of<GameCubit>(tester.element(find.byType(GameBoard)));

Future<void> tapTile(WidgetTester tester, int index) async {
  final tile = boardTile(index + 1);
  await tester.ensureVisible(tile);
  await tester.pumpAndSettle();
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

/// Index of the other tile in the pair of the tile at [index].
int partnerOf(GameCubit cubit, int index) {
  final tiles = cubit.state.tiles;
  return tiles.indexWhere(
    (tile) => tile.pairId == tiles[index].pairId && tile.id != tiles[index].id,
  );
}

/// Index of a tile that is not a pair with the tile at [index].
int strangerOf(GameCubit cubit, int index) {
  final tiles = cubit.state.tiles;
  return tiles.indexWhere((tile) => tile.pairId != tiles[index].pairId);
}

/// Texts that would amount to a clock, move counter or score.
final RegExp scoreLike = RegExp(
  r'\bmoves?\b|\bscore|\bpoints?\b|\btimer\b|\bseconds?\b|\bstreak|'
  r'\d+\s*:\s*\d\d|\bstars?\b|\brate\b|\brating|\breview',
  caseSensitive: false,
);
