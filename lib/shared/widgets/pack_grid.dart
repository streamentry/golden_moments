import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/design_system.dart';

/// Lays out pack cards in rows whose height follows their content, so cards
/// grow with the system text size instead of clipping at 200% text.
///
/// Columns depend on the space available at the current text size; a large
/// text size or a narrow phone gives one column. Not lazily built: the
/// included catalog is small.
class PackGrid extends StatelessWidget {
  const new({required this.packs, required this.cardBuilder, super.key});

  final List<Pack> packs;
  final Widget Function(BuildContext context, Pack pack) cardBuilder;

  /// Narrowest comfortable card at 100% text.
  static const double minCardWidth = 170;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / (minCardWidth * scale))
            .floor()
            .clamp(1, 4);
        final rows = <Widget>[];
        for (var start = 0; start < packs.length; start += columns) {
          final cells = <Widget>[];
          for (var i = start; i < start + columns; i++) {
            if (i > start) cells.add(const SizedBox(width: gmSpaceSm));
            cells.add(
              Expanded(
                child: i < packs.length
                    ? cardBuilder(context, packs[i])
                    : const SizedBox.shrink(),
              ),
            );
          }
          if (rows.isNotEmpty) rows.add(const SizedBox(height: gmSpaceSm));
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cells,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
