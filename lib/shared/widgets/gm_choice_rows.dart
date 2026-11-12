import 'dart:math';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';

/// One choice in [GmChoiceRows].
typedef GmChoice = ({String label, bool selected, VoidCallback onSelected});

/// Choice chips of equal width in full rows (DESIGN.md › Comfort-level
/// chips): all on one row when every label fits, otherwise in pairs,
/// otherwise one per row. No choice is ever left alone on a row of its own,
/// and a label never breaks inside a word: side by side it stays on one
/// line, and one per row it may wrap only between words.
class GmChoiceRows extends StatelessWidget {
  const new({required this.choices, super.key});

  final List<GmChoice> choices;

  /// Room a chip needs for [label] on one line with its check mark: the
  /// mark is as wide as the line is tall, plus label and chip padding.
  static double _needed(BuildContext context, String label) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: Theme.of(context).chipTheme.labelStyle,
      ),
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final needed = painter.width + painter.height + gmSpaceSm * 4 + 4;
    painter.dispose();
    return needed;
  }

  @override
  Widget build(BuildContext context) {
    if (choices.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final needed = choices
            .map((choice) => _needed(context, choice.label))
            .reduce(max);
        final count = choices.length;
        var columns = 1;
        for (final candidate in {count, 2}) {
          final width =
              (constraints.maxWidth - gmSpaceSm * (candidate - 1)) / candidate;
          if (count % candidate == 0 && width >= needed) {
            columns = candidate;
            break;
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var start = 0; start < count; start += columns) ...[
              if (start > 0) const SizedBox(height: gmSpaceSm),
              Row(
                children: [
                  for (var i = start; i < start + columns; i++) ...[
                    if (i > start) const SizedBox(width: gmSpaceSm),
                    Expanded(child: _chip(choices[i], oneLine: columns > 1)),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _chip(GmChoice choice, {required bool oneLine}) => ChoiceChip(
    // Centred in the full-width chip, beside the check when chosen.
    label: Center(
      child: Text(
        choice.label,
        softWrap: !oneLine,
        textAlign: TextAlign.center,
      ),
    ),
    selected: choice.selected,
    onSelected: (_) => choice.onSelected(),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}
