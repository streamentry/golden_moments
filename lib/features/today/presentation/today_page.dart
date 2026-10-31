import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_collection_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:golden_moments/features/today/data/today_notes.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:share_plus/share_plus.dart';

/// Hands the notes to the system share sheet; replaceable in tests.
typedef ShareNotes = Future<void> Function(String text, String subject);

Future<void> _shareWithSystem(String text, String subject) async {
  await SharePlus.instance.share(ShareParams(text: text, subject: subject));
}

/// "What is hardest today?" for the family caregiver (the website's /today/
/// in the app): one hard moment, three things to try, when to get help, one
/// gentle activity, and a one-tap note of how it went. Notes stay on this
/// device and leave it only when the caregiver shares them.
class TodayPage extends StatefulWidget {
  const new({
    this.store = const TodayNotesStore(),
    this.share = _shareWithSystem,
    this.clock = DateTime.now,
    super.key,
  });

  final TodayNotesStore store;
  final ShareNotes share;
  final DateTime Function() clock;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

/// Words for one situation, in the app's language.
typedef _Words = ({String label, List<String> tries, String help});

class _TodayPageState extends State<TodayPage> {
  final GlobalKey _answerKey = GlobalKey();
  final _text = TextEditingController();
  Situation? _chosen;
  List<TodayNote> _notes = const [];
  String? _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    List<TodayNote> loaded;
    try {
      loaded = await widget.store.load();
    } on Object {
      loaded = const [];
    }
    if (mounted) setState(() => _notes = loaded);
  }

  void _choose(Situation s) {
    setState(() {
      _chosen = s;
      _status = null;
    });
    // Bring the answer into view once it is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _answerKey.currentContext;
      if (target != null && target.mounted) {
        Scrollable.ensureVisible(target, alignment: 0.05);
      }
    });
  }

  /// Saves [next]; [done] is shown on success, the failure always is.
  Future<void> _commit(List<TodayNote> next, String? done) async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    var saved = false;
    try {
      saved = await widget.store.save(next);
    } on Object {
      saved = false;
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _notes = next;
      _status = saved ? done : l10n.todayCouldNotSave;
    });
  }

  Future<void> _record(Outcome outcome) async {
    final chosen = _chosen;
    if (chosen == null) return;
    final now = widget.clock();
    final note = TodayNote(
      id: '${now.microsecondsSinceEpoch}',
      day: TodayNotes.localDay(now),
      situation: chosen,
      outcome: outcome,
      text: _text.text,
    );
    await _commit(TodayNotes.add(_notes, note), context.l10n.todaySaved);
    if (mounted) _text.clear();
  }

  static _Words _words(Situation s, AppLocalizations l10n) => switch (s) {
    Situation.goHome => (
      label: l10n.todayGoHome,
      tries: [l10n.todayGoHomeTry1, l10n.todayGoHomeTry2, l10n.todayGoHomeTry3],
      help: l10n.todayHelpDoctor,
    ),
    Situation.sameQuestion => (
      label: l10n.todaySameQuestion,
      tries: [
        l10n.todaySameQuestionTry1,
        l10n.todaySameQuestionTry2,
        l10n.todaySameQuestionTry3,
      ],
      help: l10n.todayHelpDoctor,
    ),
    Situation.saysNo => (
      label: l10n.todaySaysNo,
      tries: [l10n.todaySaysNoTry1, l10n.todaySaysNoTry2, l10n.todaySaysNoTry3],
      help: l10n.todayHelpDoctor,
    ),
    Situation.lateDay => (
      label: l10n.todayLateDay,
      tries: [
        l10n.todayLateDayTry1,
        l10n.todayLateDayTry2,
        l10n.todayLateDayTry3,
      ],
      help: l10n.todayHelpDoctor,
    ),
    Situation.nothingToDo => (
      label: l10n.todayNothingToDo,
      tries: [
        l10n.todayNothingToDoTry1,
        l10n.todayNothingToDoTry2,
        l10n.todayNothingToDoTry3,
      ],
      help: l10n.todayHelpDoctor,
    ),
    Situation.hardToTalk => (
      label: l10n.todayHardToTalk,
      tries: [
        l10n.todayHardToTalkTry1,
        l10n.todayHardToTalkTry2,
        l10n.todayHardToTalkTry3,
      ],
      help: l10n.todayHelpDoctor,
    ),
    Situation.visit => (
      label: l10n.todayVisit,
      tries: [l10n.todayVisitTry1, l10n.todayVisitTry2, l10n.todayVisitTry3],
      help: l10n.todayHelpVisit,
    ),
    Situation.wornOut => (
      label: l10n.todayWornOut,
      tries: [
        l10n.todayWornOutTry1,
        l10n.todayWornOutTry2,
        l10n.todayWornOutTry3,
      ],
      help: l10n.todayHelpCrisis,
    ),
  };

  /// One activity already in the app, or none when the moment is the
  /// caregiver's own.
  static ({String label, IconData icon, Widget Function() page})? _activity(
    Situation s,
    AppLocalizations l10n,
  ) => switch (s) {
    Situation.goHome || Situation.lateDay || Situation.hardToTalk => (
      label: l10n.commonLookTogether,
      icon: Icons.chat_bubble_outline,
      page: () => const PhotoTogetherPage(pictures: ActivityPicture.samples),
    ),
    Situation.sameQuestion || Situation.saysNo || Situation.nothingToDo => (
      label: l10n.homeStartGentleGame,
      icon: Icons.grid_view,
      page: () => const GentleGamePage(pictures: ActivityPicture.samples),
    ),
    Situation.visit => (
      label: l10n.commonYourFamilyPhotos,
      icon: Icons.photo_library_outlined,
      page: () => const PhotoCollectionPage(),
    ),
    Situation.wornOut => null,
  };

  String _outcomeLabel(Outcome o, AppLocalizations l10n) => switch (o) {
    Outcome.helped => l10n.todayOutcomeHelped,
    Outcome.notReally => l10n.todayOutcomeNotReally,
    Outcome.notTried => l10n.todayOutcomeNotTried,
  };

  String _dayLabel(String day) {
    final parsed = DateTime.tryParse(day);
    return parsed == null
        ? day
        : MaterialLocalizations.of(context).formatFullDate(parsed);
  }

  String _noteLine(TodayNote n, AppLocalizations l10n) {
    final words =
        '${_words(n.situation, l10n).label}: '
        '${_outcomeLabel(n.outcome, l10n)}';
    return n.text.isEmpty ? words : '$words. ${n.text}';
  }

  Future<void> _share() async {
    final l10n = context.l10n;
    final buffer = StringBuffer()
      ..writeln(l10n.todayShareTitle)
      ..writeln(l10n.todayShareDisclaimer);
    for (final day in TodayNotes.byDay(_notes)) {
      buffer
        ..writeln()
        ..writeln(_dayLabel(day.day));
      for (final n in day.notes) {
        buffer.writeln('- ${_noteLine(n, l10n)}');
      }
    }
    await widget.share(buffer.toString().trimRight(), l10n.todayShareTitle);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final chosen = _chosen;
    Widget heading(String text, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.only(top: gmSpaceLg, bottom: gmSpaceSm),
      child: Semantics(
        header: true,
        child: Text(text, style: style ?? theme.textTheme.titleMedium),
      ),
    );
    final days = TodayNotes.byDay(_notes);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: GmTitle(l10n.todayTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(l10n.todayIntro, style: theme.textTheme.bodyLarge),
                const SizedBox(height: gmSpaceLg),
                for (final s in Situation.values) ...[
                  _SituationButton(
                    label: _words(s, l10n).label,
                    selected: s == chosen,
                    onPressed: () => _choose(s),
                  ),
                  const SizedBox(height: gmSpaceSm),
                ],
                if (chosen != null)
                  _Answer(
                    key: _answerKey,
                    words: _words(chosen, l10n),
                    activity: _activity(chosen, l10n),
                    heading: heading,
                    onOpen: (page) => Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => page())),
                    text: _text,
                    outcomes: [
                      for (final o in Outcome.values)
                        OutlinedButton(
                          onPressed: _saving ? null : () => _record(o),
                          child: Text(_outcomeLabel(o, l10n)),
                        ),
                    ],
                  ),
                if (_status != null) ...[
                  const SizedBox(height: gmSpaceMd),
                  Semantics(
                    liveRegion: true,
                    child: Text(_status!, style: theme.textTheme.bodyLarge),
                  ),
                ],
                heading(l10n.todayNotesHeading),
                if (days.isEmpty)
                  Text(l10n.todayNotesEmpty, style: theme.textTheme.bodyLarge)
                else ...[
                  for (final day in days) ...[
                    heading(
                      _dayLabel(day.day),
                      style: theme.textTheme.titleSmall,
                    ),
                    for (final n in day.notes)
                      _NoteRow(
                        text: _noteLine(n, l10n),
                        removeLabel: l10n.todayRemove,
                        onRemove: _saving
                            ? null
                            : () => _commit(
                                TodayNotes.remove(_notes, n.id),
                                null,
                              ),
                      ),
                  ],
                  const SizedBox(height: gmSpaceMd),
                  OutlinedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.ios_share),
                    label: Text(l10n.todayShare),
                  ),
                ],
                const SizedBox(height: gmSpaceMd),
                Text(
                  l10n.todayNotesPrivacy,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: gmSpaceMd),
                Text(
                  l10n.todayDisclaimer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: gmSpaceMd),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonDoneForNow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A full-width choice; the chosen one is filled and says so to screen
/// readers, not by color alone (a check mark marks it too).
class _SituationButton extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          alignment: AlignmentDirectional.centerStart,
          backgroundColor: selected ? scheme.primaryContainer : null,
          foregroundColor: selected ? scheme.onPrimaryContainer : null,
          side: BorderSide(
            color: scheme.primary,
            width: selected ? gmBorderSelected : gmBorderResting * 2,
          ),
        ),
        onPressed: onPressed,
        icon: Icon(selected ? Icons.check : Icons.chevron_right),
        label: Text(label, textAlign: TextAlign.start),
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  const new({
    required this.words,
    required this.activity,
    required this.heading,
    required this.onOpen,
    required this.text,
    required this.outcomes,
    super.key,
  });

  final _Words words;
  final ({String label, IconData icon, Widget Function() page})? activity;
  final Widget Function(String text, {TextStyle? style}) heading;
  final void Function(Widget Function() page) onOpen;
  final TextEditingController text;
  final List<Widget> outcomes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final activity = this.activity;
    return Card(
      margin: const EdgeInsets.only(top: gmSpaceMd),
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(words.label, style: theme.textTheme.headlineSmall),
            ),
            heading(l10n.todayTryHeading),
            for (final (i, t) in words.tries.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: gmSpaceSm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Text(
                        '${i + 1}.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: gmSpaceSm),
                    Expanded(child: Text(t, style: theme.textTheme.bodyLarge)),
                  ],
                ),
              ),
            const SizedBox(height: gmSpaceMd),
            DecoratedBox(
              decoration: BoxDecoration(
                // DESIGN.md notice: secondary-container fill and outline.
                color: gmSapphire50,
                borderRadius: BorderRadius.circular(gmRadiusMd),
                border: Border.all(color: gmSapphire100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(gmSpaceMd),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: gmSpaceSm),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${l10n.todayGetHelp}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: words.help),
                          ],
                        ),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (activity != null) ...[
              heading(l10n.todayActivityHeading),
              FilledButton.icon(
                onPressed: () => onOpen(activity.page),
                icon: Icon(activity.icon),
                label: Text(activity.label),
              ),
            ],
            heading(l10n.todayHowHeading),
            TextField(
              controller: text,
              maxLength: TodayNotes.maxText,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.todayNoteLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Wrap(spacing: gmSpaceSm, runSpacing: gmSpaceSm, children: outcomes),
          ],
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const new({
    required this.text,
    required this.removeLabel,
    required this.onRemove,
  });

  final String text;
  final String removeLabel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: gmSpaceSm),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: gmSpaceSm,
        children: [
          Text(text, style: theme.textTheme.bodyLarge),
          TextButton(onPressed: onRemove, child: Text(removeLabel)),
        ],
      ),
    );
  }
}
