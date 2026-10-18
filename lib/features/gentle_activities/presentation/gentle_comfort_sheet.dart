import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';

/// Comfort choices on request, from the activity or from Home (GM-003/037).
/// Changes apply and save as they are made; the caller decides what applying
/// means (restart a board, or just save).
class GentleComfortSheet extends StatefulWidget {
  const new({
    required this.initial,
    required this.maxPairs,
    required this.onChanged,
    required this.onReset,
    this.closeLabel = 'Back to the pictures',
    super.key,
  });
  final GentlePreferences initial;

  /// What the button that closes the sheet says, to fit where it opened.
  final String closeLabel;
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
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Reset comfort settings?'),
        content: const Text(
          'This only returns the tile count and picture view to their '
          'starting choices. Your photos and picture packs are not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep my settings'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final prefs = await widget.onReset();
    if (mounted) setState(() => _prefs = prefs);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(gmSpaceLg, 0, gmSpaceLg, gmSpaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Comfort settings', style: theme.textTheme.headlineSmall),
            const SizedBox(height: gmSpaceMd),
            Text('Number of tiles', style: theme.textTheme.titleMedium),
            const SizedBox(height: gmSpaceSm),
            Wrap(
              spacing: gmSpaceSm,
              runSpacing: gmSpaceSm,
              children: [
                for (final pairs in GentlePreferences.pairChoices)
                  if (pairs <= widget.maxPairs)
                    ChoiceChip(
                      label: Text('${pairs * 2} tiles'),
                      selected: _prefs.pairs == pairs,
                      onSelected: (_) => _change(_prefs.copyWith(pairs: pairs)),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                    ),
              ],
            ),
            const SizedBox(height: gmSpaceSm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Keep pictures visible'),
              subtitle: const Text(
                'Turn off only when you prefer hidden tiles.',
              ),
              value: _prefs.keepVisible,
              onChanged: (value) =>
                  _change(_prefs.copyWith(keepVisible: value)),
            ),
            if (_saveFailed)
              Padding(
                padding: const EdgeInsets.only(bottom: gmSpaceSm),
                child: Text(
                  'These choices could not be saved. They will apply until '
                  'you close the app.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: gmSpaceSm),
            OutlinedButton(
              onPressed: _reset,
              child: const Text('Reset comfort settings'),
            ),
            const SizedBox(height: gmSpaceSm),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(widget.closeLabel),
            ),
          ],
        ),
      ),
    );
  }
}
