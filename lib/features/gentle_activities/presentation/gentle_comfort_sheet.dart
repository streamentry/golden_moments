import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/widgets/gm_choice_rows.dart';

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
            GmChoiceRows(
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.comfortHighContrast),
              subtitle: Text(l10n.comfortHighContrastHint),
              value: _prefs.highContrast,
              onChanged: (value) =>
                  _change(_prefs.copyWith(highContrast: value)),
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
