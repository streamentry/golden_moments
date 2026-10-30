import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_session.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/models/gentle_board.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_comfort_sheet.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';
import 'package:golden_moments/shared/rating/review_request.dart';
import 'package:golden_moments/shared/sharing/share_invitation.dart';
import 'package:golden_moments/shared/widgets/gm_bottom_bar.dart';

/// The matching activity: the board comes first, "Done for now" is always
/// visible, and comfort settings open only on request (GM-001/002/003/005).
class GentleGamePage extends StatefulWidget {
  const new({
    required this.pictures,
    this.preferencesStore = const GentlePreferencesStore(),
    this.sessionStore = const GentleSessionStore(),
    this.sessionKey = 'starter',
    super.key,
  });
  final List<ActivityPicture> pictures;
  final GentlePreferencesStore preferencesStore;
  final GentleSessionStore sessionStore;

  /// Separates saved boards by picture source (starter vs family photos).
  final String sessionKey;

  @override
  State<GentleGamePage> createState() => _GentleGamePageState();
}

class _GentleGamePageState extends State<GentleGamePage> {
  GentleBoard? _board;
  GentlePreferences _prefs = const GentlePreferences();
  bool _invite = false;
  bool _shared = false;
  final GmMoreBelow _moreBelow = GmMoreBelow();

  /// The line under the board that names the finish; at large text the
  /// page scrolls to it when the last pair is found.
  final GlobalKey _finishKey = GlobalKey();

  /// "All pairs together.", above the board unless the text is very large.
  final GlobalKey _headingKey = GlobalKey();

  /// False until a saved board has been offered (or ruled out). Until then
  /// taps are not saved, so an earlier unfinished board is never overwritten
  /// before the person has been asked about it.
  bool _resumeSettled = false;

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
    unawaited(_loadSaved());
  }

  @override
  void dispose() {
    _settleInvitation();
    _moreBelow.dispose();
    super.dispose();
  }

  /// The board is playable immediately with defaults; saved comfort choices
  /// apply only while the board is still untouched.
  Future<void> _loadSaved() async {
    final saved = await widget.preferencesStore.load();
    if (!mounted) return;
    if (saved != _prefs && _untouched) {
      setState(() {
        _prefs = saved;
        _start();
      });
    }
    try {
      await _offerResume();
    } finally {
      _resumeSettled = true;
    }
  }

  bool get _untouched {
    final board = _board;
    return board == null || !(board.hasProgress || board.complete);
  }

  /// Resuming is always a visible choice: a saved board is offered once, on
  /// opening, and never replaces a board the person has already started.
  Future<void> _offerResume() async {
    final session = await widget.sessionStore.load(widget.sessionKey);
    if (session == null || !mounted || !_untouched) return;
    final restored = session.toBoard(
      availablePictureIds: {for (final p in widget.pictures) p.id},
    );
    if (restored == null) {
      // Deleted photos or an unusable record: start fresh, change nothing else.
      await widget.sessionStore.clear(widget.sessionKey);
      return;
    }
    final resume = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const GmTitle('Pick up where you left off?'),
        content: const Text(
          'You have a board in progress. You can carry on with it or start '
          'a new one.',
        ),
        actions: gmDialogActions(
          other: TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Start fresh', textAlign: TextAlign.center),
          ),
          primary: FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Carry on', textAlign: TextAlign.center),
          ),
          labels: ('Start fresh', 'Carry on'),
        ),
      ),
    );
    if (!mounted) return;
    if (resume ?? false) {
      if (_untouched) {
        _settleInvitation();
        setState(() => _board = restored);
      }
    } else if (resume == false) {
      await widget.sessionStore.clear(widget.sessionKey);
    }
    // Dismissed with system back (null): nothing was chosen, so the saved
    // board stays until a deliberate choice or the next move replaces it.
  }

  /// Saves the unfinished board; a finished or empty board leaves nothing to
  /// resume. Never awaited by play, and failures are harmless.
  void _persist() {
    if (!_resumeSettled) return;
    final board = _board;
    if (board == null || board.complete || !board.hasProgress) {
      unawaited(widget.sessionStore.clear(widget.sessionKey));
    } else {
      unawaited(
        widget.sessionStore.save(
          widget.sessionKey,
          GentleSession.fromBoard(board),
        ),
      );
    }
  }

  /// A deliberate new board forgets the saved one.
  void _restart() {
    unawaited(widget.sessionStore.clear(widget.sessionKey));
    setState(_start);
  }

  void _tap(int index) {
    final board = _board;
    if (board == null) return;
    final wasComplete = board.complete;
    setState(() => board.tap(index));
    _persist();
    if (!wasComplete && board.complete) {
      unawaited(_recordCompletion());
      _revealFinish();
    }
  }

  /// Brings the finish into view when the page scrolls: "All pairs
  /// together." and the closing words below the board. When both fit, the
  /// page goes as far down as it can with the heading still in sight (to the
  /// end where possible, so nothing is left under the bar). When they do
  /// not, the heading is what stays in view, with as little movement as
  /// possible. Without a page scroll view this does nothing.
  void _revealFinish() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final statusContext = _finishKey.currentContext;
      final heading = _headingKey.currentContext?.findRenderObject();
      final status = statusContext?.findRenderObject();
      if (!mounted || statusContext == null || heading == null) return;
      final scrollable = Scrollable.maybeOf(statusContext);
      final viewport = RenderAbstractViewport.maybeOf(heading);
      if (scrollable == null || viewport == null || status == null) return;
      final position = scrollable.position;
      final headingTop = viewport.getOffsetToReveal(heading, 0).offset;
      final headingEnd = viewport.getOffsetToReveal(heading, 1).offset;
      final statusEnd = viewport.getOffsetToReveal(status, 1).offset;
      // A heading taller than the viewport (large text in a short window)
      // has headingEnd above headingTop; its top is then what stays in view.
      final target =
          (statusEnd <= headingTop
                  ? position.maxScrollExtent.clamp(statusEnd, headingTop)
                  : headingEnd <= headingTop
                  ? position.pixels.clamp(headingEnd, headingTop)
                  : headingTop)
              .clamp(position.minScrollExtent, position.maxScrollExtent);
      if ((target - position.pixels).abs() < 0.5) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        position.jumpTo(target);
      } else {
        unawaited(
          position.animateTo(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  Future<void> _recordCompletion() async {
    bool invite;
    try {
      invite = await (await ShareInvitationStore.load()).recordCompletedGame();
    } on Object {
      invite = false;
    }
    unawaited(recordFinishedGameForReview(suggestedSharing: invite));
    if (mounted && invite) {
      setState(() => _invite = true);
      // The suggestion makes the bar taller; keep the closing words in view.
      _revealFinish();
    }
  }

  Future<void> _share() async {
    if (await shareAndRemember() && mounted) {
      setState(() => _shared = true);
      _revealFinish();
    }
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
        scrollable: true,
        title: Text(question),
        content: const Text(
          'The pictures you have found on this board will be cleared.',
        ),
        // Keeping the board is the safe choice, so it is the primary one.
        actions: gmDialogActions(
          other: TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action, textAlign: TextAlign.center),
          ),
          primary: FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep this board', textAlign: TextAlign.center),
          ),
          labels: (action, 'Keep this board'),
        ),
      ),
    );
    return ok ?? false;
  }

  Future<void> _startAgain() async {
    if (!await _confirmDiscard('Start again?', 'Start again')) return;
    if (mounted) _restart();
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
    if (pairsChanged) {
      unawaited(widget.sessionStore.clear(widget.sessionKey));
    }
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
    if (pairsChanged) {
      unawaited(widget.sessionStore.clear(widget.sessionKey));
    }
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
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to the pictures'),
                  ),
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
        builder: (context) => GentleComfortSheet(
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
        toolbarHeight: gmToolbarHeight(context),
        title: const GmTitle('Gentle photo match'),
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
          : _moreBelow.watch(
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: gmContentMaxWidth,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // At very large text the board comes first and the
                        // instruction moves into the status line below it.
                        final instructionBelow = scale > 1.5;
                        // A finished board says so calmly where the
                        // instruction was: a check and a plain sentence, no
                        // confetti, score or praise (DESIGN.md › Celebration).
                        final instruction = board.complete
                            ? Semantics(
                                key: _headingKey,
                                liveRegion: true,
                                header: true,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: theme.colorScheme.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(width: gmSpaceSm),
                                    Expanded(
                                      child: Text(
                                        'All pairs together.',
                                        style: theme.textTheme.headlineSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                'Tap two pictures that match.',
                                style: theme.textTheme.bodyLarge,
                              );
                        final status = Semantics(
                          key: _finishKey,
                          liveRegion: true,
                          child: Text(
                            board.complete
                                ? 'Play again or take a break.'
                                : board.waitingForNextTurn
                                ? 'Take your time. Tap a picture to continue.'
                                : instructionBelow
                                ? 'Tap two pictures that match. '
                                      'There is no time limit.'
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
                                if (!instructionBelow) ...[
                                  instruction,
                                  const SizedBox(height: gmSpaceMd),
                                ],
                                // Centred, like a board that fits.
                                Center(
                                  child: _grid(
                                    board,
                                    width,
                                    constraints.maxHeight * 0.8,
                                  ),
                                ),
                                const SizedBox(height: gmSpaceMd),
                                // At large text the finish is named below the
                                // board, where the instruction went.
                                if (instructionBelow && board.complete) ...[
                                  instruction,
                                  const SizedBox(height: gmSpaceSm),
                                ],
                                status,
                              ],
                            ),
                          );
                        }
                        // Nothing scrolls in this layout, so nothing is below.
                        if (_moreBelow.value) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) _moreBelow.value = false;
                          });
                        }
                        return Padding(
                          padding: padding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!instructionBelow) ...[
                                instruction,
                                const SizedBox(height: gmSpaceMd),
                              ],
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
                              if (instructionBelow && board.complete) ...[
                                instruction,
                                const SizedBox(height: gmSpaceSm),
                              ],
                              status,
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: board == null
          ? null
          : GmBottomBar(
              moreBelow: _moreBelow,
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
                  _exitButtons(board),
                ],
              ),
            ),
    );
  }

  /// Side by side normally; stacked full width at large text so labels never
  /// squeeze into a few letters per line or push the board off screen.
  Widget _exitButtons(GentleBoard board) {
    final done = OutlinedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Done for now', textAlign: TextAlign.center),
    );
    if (board.complete) {
      // Play again is the one primary action, so it comes first when the
      // two buttons have to stack.
      return GmButtonPair(
        first: done,
        second: FilledButton(
          onPressed: _restart,
          child: const Text('Play again', textAlign: TextAlign.center),
        ),
        labels: ('Done for now', 'Play again'),
        secondOnTop: true,
      );
    }
    return GmButtonPair(
      first: done,
      second: OutlinedButton(
        onPressed: _startAgain,
        child: const Text('Start again', textAlign: TextAlign.center),
      ),
      labels: ('Done for now', 'Start again'),
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
                if (visible)
                  // Mounted like a print: cropped to the tile, never
                  // letterboxed, with softly rounded corners.
                  Padding(
                    padding: const EdgeInsets.all(gmSpaceSm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(gmRadiusMd),
                      child: PictureView(picture: picture, fit: BoxFit.cover),
                    ),
                  )
                else
                  const GmTileBack(),
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
