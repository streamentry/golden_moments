import 'package:flutter/widgets.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/features/game/game.dart';

/// The browser keeps the picture-pack game and its smoke tests.
Widget packGamePage(BuildContext context, Pack pack) =>
    GamePage(gamePack: pack);
