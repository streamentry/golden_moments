import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/models/gentle_board.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';
import 'package:golden_moments/shared/sharing/share_invitation.dart';

/// The matching activity: the board comes first, "Done for now" is always
/// visible, and comfort settings open only on request (GM-001/002/003/005).
class GentleGamePage extends StatefulWidget {
  const new({
    required this.pictures,
    this.preferencesStore = const GentlePreferencesStore(),
    super.key,
  });
  final List<ActivityPicture> pictures;
  final GentlePreferencesStore preferencesStore;

  @override
  State<GentleGamePage> createState() => _GentleGamePageState();
}

class _GentleGamePageState extends State<GentleGamePage> {
  GentleBoard? _board;
  GentlePreferences _prefs = const GentlePreferences();
  bool _invite = false;
  bool _shared = false;

  /// Largest comfortable size no bigger than the pictures available.
  int get _pairs {
    final fits = GentlePreferences.pairChoices.where(
      (p) => p <= widget.pictures.length,
    );
    if (fits.isEmpty) return 0;
    return fits.contains(_prefs.pairs) ? _prefs.pairs : fits.last;
  }

  @override
  void initState() {
    super.initState();
    _start();
    unawaited(_loadPreferences());
  }

  @override
  void dispose() {
    _settleInvitation();
    super.dispose();
  }

  /// The board is playable immediately with defaults; saved comfort choices
  /// apply only while the board is still untouched.
  Future<void> _loadPreferences() async {
    final saved = await widget.preferencesStore.load();
    if (!mounted || saved == _prefs) return;
    final board = _board;
    if (board != null && (board.hasProgress || board.complete)) return;
    setState(() {
      _prefs = saved;
      _start();
    });
  }

  void _tap(int index) {
    final board = _board;
    if (board == null) return;
    final wasComplete = board.complete;
    setState(() => board.tap(index));
    if (!wasComplete && board.complete) unawaited(_recordCompletion());
  }

  Future<void> _recordCompletion() async {
    bool invite;
    try {
      invite = await (await ShareInvitationStore.load()).recordCompletedGame();
    } on Object {
      invite = false;
    }
    if (mounted && invite) setState(() => _invite = true);
  }

  Future<void> _share() async {
    if (await shareAndRemember() && mounted) setState(() => _shared = true);
  }

  /// Carrying on without sharing is a complete answer, never a nag.
  void _settleInvitation() {
    if (_invite && !_shared) {
      unawaited(
        ShareInvitationStore.load()
            .then((store) => store.markDeclined())
            .catchError((Object _) {}),
      );
    }
    _invite = false;
    _shared = false;
  }

  void _start() {
    _settleInvitation();
    final pairs = _pairs;
    if (pairs < 2) {
      _board = null;
      return;
    }
    final choices = List<ActivityPicture>.of(widget.pictures)
      ..shuffle(Random());
    _board = GentleBoard(choices.take(pairs).map((p) => p.id).toList());
  }

  /// Discarding meaningful progress needs a yes; "Keep this board" leaves the
  /// exact board as it was.
  Future<bool> _confirmDiscard(String question, String action) async {
    final board = _board;
    if (board == null || !board.hasProgress) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question),
        content: const Text(
          'The pictures you have found on this board will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep this board'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _startAgain() async {
    if (!await _confirmDiscard('Start again?', 'Start again')) return;
    if (mounted) setState(_start);
  }

  /// Returns the preferences in effect afterwards and whether they were saved.
  Future<({GentlePreferences prefs, bool saved})> _applyPreferences(
    GentlePreferences next,
  ) async {
    if (next.pairs != _prefs.pairs &&
        !await _confirmDiscard('Change the number of tiles?', 'Change')) {
      return (prefs: _prefs, saved: true);
    }
    if (!mounted) return (prefs: _prefs, saved: true);
    final pairsChanged = next.pairs != _prefs.pairs;
    setState(() {
      _prefs = next;
      if (pairsChanged) _start();
    });
    final saved = await widget.preferencesStore.save(next);
    return (prefs: next, saved: saved);
  }

  Future<GentlePreferences> _resetPreferences() async {
    const defaults = GentlePreferences();
    final pairsChanged = _prefs.pairs != defaults.pairs;
    if (pairsChanged &&
        !await _confirmDiscard('Reset comfort settings?', 'Reset')) {
      return _prefs;
    }
    await widget.preferencesStore.reset();
    if (!mounted) return _prefs;
    setState(() {
      _prefs = defaults;
      if (pairsChanged) _start();
    });
    return defaults;
  }

  void _showHelp() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              gmSpaceLg,
              0,
              gmSpaceLg,
              gmSpaceLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How this works',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: gmSpaceMd),
                const Text(
                  'Tap one picture, then tap another. Pictures that match stay '
                  'together. Pictures that do not match stay in view until '
                  'your next tap.',
                ),
                const SizedBox(height: gmSpaceMd),
                const Text(
                  'There is no time limit and no wrong answer. It is fine to '
                  'just look at the pictures, talk about them, change the '
                  'number of tiles, or stop with Done for now.',
                ),
                const SizedBox(height: gmSpaceLg),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to the pictures'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => _ComfortSheet(
          initial: _prefs,
          maxPairs: widget.pictures.length,
          onChanged: _applyPreferences,
          onReset: _resetPreferences,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final board = _board;
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gentle photo match'),
        actions: [
          IconButton(
            onPressed: _showHelp,
            icon: const Icon(Icons.help_outline),
            tooltip: 'How this works',
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.tune),
            tooltip: 'Comfort settings',
          ),
        ],
      ),
      body: board == null
          ? const Center(child: Text('Choose at least two photos to play.'))
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: gmContentMaxWidth,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final instruction = Text(
                        'Tap two pictures that match. Take your time.',
                        style: theme.textTheme.bodyLarge,
                      );
                      final status = Semantics(
                        liveRegion: true,
                        child: Text(
                          board.complete
                              ? 'All pairs together. '
                                    'Play again or take a break.'
                              : board.waitingForNextTurn
                              ? 'Take your time. Tap a picture to continue.'
                              : 'There is no time limit.',
                          style: theme.textTheme.bodyLarge,
                        ),
                      );
                      const padding = EdgeInsets.symmetric(
                        horizontal: gmSpaceLg,
                        vertical: gmSpaceMd,
                      );
                      final width = constraints.maxWidth - padding.horizontal;
                      // Large text or a short landscape screen: scroll the
                      // page instead of squeezing the board below tile size.
                      final tight = constraints.maxHeight < 360 + 240 * scale;
                      if (tight) {
                        return SingleChildScrollView(
                          padding: padding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              instruction,
                              const SizedBox(height: gmSpaceMd),
                              _grid(board, width, constraints.maxHeight * 0.8),
                              const SizedBox(height: gmSpaceMd),
                              status,
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: padding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            instruction,
                            const SizedBox(height: gmSpaceMd),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, box) => Center(
                                  child: _grid(
                                    board,
                                    box.maxWidth,
                                    box.maxHeight,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: gmSpaceMd),
                            status,
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
      bottomNavigationBar: board == null
          ? null
          : SafeArea(
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: gmContentMaxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      gmSpaceLg,
                      0,
                      gmSpaceLg,
                      gmSpaceMd,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (board.complete && _invite && !_shared) ...[
                          ShareInvitation(onShare: _share),
                          const SizedBox(height: gmSpaceSm),
                        ],
                        if (board.complete && _shared) ...[
                          Text(
                            'Thank you for sharing.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: gmSpaceSm),
                        ],
                        Wrap(
                          spacing: gmSpaceMd,
                          runSpacing: gmSpaceSm,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Done for now'),
                            ),
                            if (board.complete)
                              FilledButton(
                                onPressed: () => setState(_start),
                                child: const Text('Play again'),
                              )
                            else
                              OutlinedButton(
                                onPressed: _startAgain,
                                child: const Text('Start again'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  /// Square tiles as large as the space allows, never below [gmTileMin].
  Widget _grid(GentleBoard board, double maxWidth, double maxHeight) {
    final count = board.cards.length;
    final columns = gmBoardColumns(
      tileCount: count,
      maxColumns: min(4, count),
      size: Size(maxWidth, maxHeight),
    );
    final rows = (count / columns).ceil();
    var tile = min(
      (maxWidth - gmTileGap * (columns - 1)) / columns,
      (maxHeight - gmTileGap * (rows - 1)) / rows,
    );
    tile = max(gmTileMin, tile);
    final byId = {for (final p in widget.pictures) p.id: p};
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: columns * tile + gmTileGap * (columns - 1),
      child: Wrap(
        spacing: gmTileGap,
        runSpacing: gmTileGap,
        children: [
          for (var index = 0; index < count; index++)
            SizedBox.square(
              dimension: tile,
              child: _tile(index, board, byId[board.cards[index]]!, scheme),
            ),
        ],
      ),
    );
  }

  Widget _tile(
    int index,
    GentleBoard board,
    ActivityPicture picture,
    ColorScheme scheme,
  ) {
    final visible = board.isVisible(index, keepVisible: _prefs.keepVisible);
    final matched = board.isMatched(index);
    final emphasized = matched || board.isSelected(index);
    return Semantics(
      button: true,
      enabled: !matched,
      onTap: matched ? null : () => _tap(index),
      label: visible
          ? '${picture.label}, tile ${index + 1}'
          : 'Hidden picture, tile ${index + 1}',
      value: matched
          ? 'Matched'
          : board.isSelected(index)
          ? 'Selected'
          : '',
      child: ExcludeSemantics(
        child: Material(
          color: visible ? scheme.surface : gmSurf200,
          shape: gmTileShape(scheme, emphasized: emphasized),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: matched ? null : () => _tap(index),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.all(gmSpaceSm),
                  child: visible
                      ? PictureView(picture: picture)
                      : Icon(
                          Icons.photo_outlined,
                          size: 56,
                          color: scheme.onSurfaceVariant,
                        ),
                ),
                if (matched)
                  const Positioned(
                    top: gmSpaceSm,
                    right: gmSpaceSm,
                    child: GmMatchBadge(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Comfort choices on request. Changes apply and save as they are made.
class _ComfortSheet extends StatefulWidget {
  const new({
    required this.initial,
    required this.maxPairs,
    required this.onChanged,
    required this.onReset,
  });
  final GentlePreferences initial;
  final int maxPairs;
  final Future<({GentlePreferences prefs, bool saved})> Function(
    GentlePreferences,
  )
  onChanged;
  final Future<GentlePreferences> Function() onReset;

  @override
  State<_ComfortSheet> createState() => _ComfortSheetState();
}

class _ComfortSheetState extends State<_ComfortSheet> {
  late GentlePreferences _prefs = widget.initial;
  bool _saveFailed = false;

  Future<void> _change(GentlePreferences next) async {
    final result = await widget.onChanged(next);
    if (!mounted) return;
    setState(() {
      _prefs = result.prefs;
      _saveFailed = !result.saved;
    });
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
              child: const Text('Back to the pictures'),
            ),
          ],
        ),
      ),
    );
  }
}
