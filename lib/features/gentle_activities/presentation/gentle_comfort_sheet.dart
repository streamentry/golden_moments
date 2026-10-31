import 'dart:math';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// Comfort choices on request, from the activity or from Home (GM-003/037).
/// Changes apply and save as they are made; the caller decides what applying
/// means (restart a board, or just save).
class GentleComfortSheet extends StatefulWidget {
  const new({
    required this.initial,
    required this.maxPairs,
    required this.onChanged,
    required this.onReset,
    this.closeLabel,
    super.key,
  });
  final GentlePreferences initial;

  /// What the button that closes the sheet says, to fit where it opened.
  /// Defaults to "Back to the pictures" in the current language.
  final String? closeLabel;
  final int maxPairs;
  final Future<({GentlePreferences prefs, bool saved})> Function(
    GentlePreferences,
  )
  onChanged;
  final Future<GentlePreferences> Function() onReset;

  @override
  State<GentleComfortSheet> createState() => _GentleComfortSheetState();
}

class _GentleComfortSheetState extends State<GentleComfortSheet> {
  late GentlePreferences _prefs = widget.initial;
  bool _saveFailed = false;
  int _latest = 0;

  /// Shows the choice at once and builds the next one on top of it, so two
  /// quick taps both count. Only the newest answer is allowed to settle the
  /// sheet, so a slow earlier save cannot undo a later choice.
  Future<void> _change(GentlePreferences next) async {
    final mine = ++_latest;
    setState(() => _prefs = next);
    final result = await widget.onChanged(next);
    if (!mounted || mine != _latest) return;
    setState(() {
      _prefs = result.prefs;
      _saveFailed = !result.saved;
    });
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          scrollable: true,
          title: Text(l10n.gentleGameResetComfortQuestion),
          content: Text(l10n.comfortResetBody),
          // Keeping the settings is the safe choice, so it is the primary one.
          actions: gmDialogActions(
            other: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.commonReset, textAlign: TextAlign.center),
            ),
            primary: FilledButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                l10n.comfortKeepMySettings,
                textAlign: TextAlign.center,
              ),
            ),
            labels: (l10n.commonReset, l10n.comfortKeepMySettings),
          ),
        );
      },
    );
    if (ok != true || !mounted) return;
    final prefs = await widget.onReset();
    if (mounted) setState(() => _prefs = prefs);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(gmSpaceLg, 0, gmSpaceLg, gmSpaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.commonComfortSettings,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: gmSpaceXs),
            Text(
              l10n.comfortChangesApply,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: gmSpaceMd),
            Text(l10n.comfortNumberOfTiles, style: theme.textTheme.titleMedium),
            const SizedBox(height: gmSpaceSm),
            _ChoiceRows(
              choices: [
                for (final pairs in GentlePreferences.pairChoices)
                  if (pairs <= widget.maxPairs)
                    (
                      label: l10n.comfortTileCount(pairs * 2),
                      selected: _prefs.pairs == pairs,
                      onSelected: () => _change(_prefs.copyWith(pairs: pairs)),
                    ),
              ],
            ),
            const SizedBox(height: gmSpaceSm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.comfortKeepVisible),
              subtitle: Text(l10n.comfortKeepVisibleHint),
              value: _prefs.keepVisible,
              onChanged: (value) =>
                  _change(_prefs.copyWith(keepVisible: value)),
            ),
            if (_saveFailed)
              Padding(
                padding: const EdgeInsets.only(bottom: gmSpaceSm),
                child: Text(
                  l10n.comfortSaveFailed,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            // Reset is a quiet, confirmed side action; closing is the one
            // primary action and spans the sheet like other sheet actions.
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.comfortResetButton),
            ),
            const SizedBox(height: gmSpaceSm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(widget.closeLabel ?? l10n.gentleGameBackToPictures),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _Choice = ({String label, bool selected, VoidCallback onSelected});

/// Choice chips of equal width in full rows: all on one row when every label
/// fits, otherwise in pairs, otherwise one per row. No choice is ever left
/// alone on a row of its own, and no label wraps.
class _ChoiceRows extends StatelessWidget {
  const new({required this.choices});

  final List<_Choice> choices;

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
                    Expanded(child: _chip(choices[i])),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _chip(_Choice choice) => ChoiceChip(
    // Centred in the full-width chip, beside the check when chosen.
    label: Center(child: Text(choice.label, softWrap: false)),
    selected: choice.selected,
    onSelected: (_) => choice.onSelected(),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}
