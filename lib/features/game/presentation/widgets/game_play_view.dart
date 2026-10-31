import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/game_cubit.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_board.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_header.dart';

/// The board first: guidance moves below it at very large text, and the
/// page scrolls only when the board cannot fit at [gmTileMin] beside the
/// guidance (GM-012/GM-016).
///
/// The header's measured height is reserved, never smaller than the
/// tallest message seen at this width and text size, so tiles do not resize
/// or move between turns when a longer message appears.
class GamePlayView extends StatefulWidget {
  const new({required this.state, super.key});

  final GameState state;

  @override
  State<GamePlayView> createState() => _GamePlayViewState();
}

class _GamePlayViewState extends State<GamePlayView> {
  static const _padding = EdgeInsets.symmetric(
    horizontal: gmSpaceLg,
    vertical: gmSpaceMd,
  );

  double _headerHeight = 0;
  (double, double)? _measuredFor;

  void _onHeaderHeight((double, double) key, double height) {
    if (!mounted) return;
    final next = _measuredFor == key ? math.max(_headerHeight, height) : height;
    if (next == _headerHeight && _measuredFor == key) return;
    setState(() {
      _measuredFor = key;
      _headerHeight = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final guidanceBelow = scale > 1.5;

    GameBoard board({double? heightBudget}) => GameBoard(
      tiles: state.tiles,
      selectedTileIds: {for (final tile in state.selectedTiles) tile.id},
      waitingForNextTap: state.showingMismatch || state.hintTileIds.isNotEmpty,
      heightBudget: heightBudget,
      packId: state.currentPack.id,
      onTileTap: (tileId) => context.read<GameCubit>().onTileTap(tileId),
    );

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final key = (constraints.maxWidth, scale);
              final header = ConstrainedBox(
                constraints: BoxConstraints(minHeight: _headerHeight),
                child: _HeightReporter(
                  onHeight: (height) => _onHeaderHeight(key, height),
                  child: GameHeader(state: state),
                ),
              );
              final viewport = constraints.maxHeight - _padding.vertical;
              final width = constraints.maxWidth - _padding.horizontal;
              bool fits(double height) {
                final fit = GameBoard.fit(
                  count: state.tiles.length,
                  size: Size(width, height),
                );
                final rows = (state.tiles.length / fit.columns).ceil();
                return rows * fit.tile + gmTileGap * (rows - 1) <= height;
              }

              // The board takes the space left beside the measured header.
              // If it cannot fit there even at gmTileMin, and the guidance
              // sits below it, the board gets the whole screen first.
              final besideHeader = viewport - _headerHeight - gmSpaceMd;
              final budget = guidanceBelow && !fits(besideHeader)
                  ? viewport
                  : besideHeader;
              // One page scroll view, never nested scrolling: it only moves
              // when the content is taller than the screen, and it keeps a
              // header that grows mid-game from overflowing.
              return SingleChildScrollView(
                padding: _padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!guidanceBelow) ...[
                      header,
                      const SizedBox(height: gmSpaceMd),
                    ],
                    board(heightBudget: budget),
                    if (guidanceBelow) ...[
                      const SizedBox(height: gmSpaceMd),
                      header,
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Reports its child's laid-out height after the frame, when it changes.
class _HeightReporter extends SingleChildRenderObjectWidget {
  const new({required this.onHeight, required super.child});

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeightReporter(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeightReporter renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderHeightReporter extends RenderProxyBox {
  new(this.onHeight);

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (height == _reported) return;
    _reported = height;
    WidgetsBinding.instance.addPostFrameCallback((_) => onHeight(height));
  }
}
