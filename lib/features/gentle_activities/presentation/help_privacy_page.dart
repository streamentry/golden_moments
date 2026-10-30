import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/shared/rating/review_request.dart';
import 'package:golden_moments/shared/utils/support_info.dart';
import 'package:golden_moments/shared/widgets/gm_copyable_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// What the platform reported about a share. `unknown` is common: many
/// platforms cannot say whether the person finished sharing.
enum ShareOutcome { shared, dismissed, unknown }

/// Sends text through the system share sheet.
typedef TextSharer = Future<ShareOutcome> Function(String text, String subject);

Future<ShareOutcome> shareText(String text, String subject) async {
  try {
    final result = await SharePlus.instance.share(
      ShareParams(text: text, subject: subject),
    );
    return switch (result.status) {
      ShareResultStatus.success => ShareOutcome.shared,
      ShareResultStatus.dismissed => ShareOutcome.dismissed,
      ShareResultStatus.unavailable => ShareOutcome.unknown,
    };
  } on Object {
    return ShareOutcome.dismissed;
  }
}

/// Opens a store page outside the app; returns whether it opened.
typedef StoreOpener = Future<bool> Function(String url);

Future<bool> openStorePage(String url) async {
  try {
    return await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } on Object {
    return false;
  }
}

/// Offline help, privacy and support (GM-031, GM-034). Everything here is
/// local text. Nothing leaves the app unless the person reviews it and
/// chooses a destination in the system share sheet; reaching support is
/// separate from the optional rating link, and nothing here changes saved
/// data.
class HelpPrivacyPage extends StatefulWidget {
  const new({
    this.sharer = shareText,
    this.storeOpener = openStorePage,
    super.key,
  });

  final TextSharer sharer;

  /// Opens the store review page, only after "Rate Golden Moments" is tapped.
  final StoreOpener storeOpener;

  @override
  State<HelpPrivacyPage> createState() => _HelpPrivacyPageState();
}

class _HelpPrivacyPageState extends State<HelpPrivacyPage> {
  String? _status;

  Future<void> _send(String text, String subject) async {
    final outcome = await widget.sharer(text, subject);
    if (!mounted) return;
    setState(
      () => _status = switch (outcome) {
        ShareOutcome.shared => 'Thank you. Nothing else was sent.',
        ShareOutcome.dismissed => 'Nothing was sent. You can try again.',
        ShareOutcome.unknown =>
          'The share window closed. If you sent it, thank you. Nothing '
              'else was sent.',
      },
    );
  }

  Future<void> _writeNote() async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => const _NoteDialog(),
    );
    if (note == null || note.trim().isEmpty || !mounted) return;
    await _send(feedbackMessage(note), 'Golden Moments note');
  }

  Future<void> _rate() async {
    if (await widget.storeOpener(storeReviewUrl()) || !mounted) return;
    setState(
      () => _status =
          'Could not open the store. You can find Golden Moments there '
          'later.',
    );
  }

  Future<void> _reportProblem() async {
    final kind = await showDialog<ProblemKind>(
      context: context,
      builder: (context) => const _ProblemDialog(),
    );
    if (kind == null || !mounted) return;
    await _send(diagnosticSummary(kind), 'Golden Moments problem report');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: gmSpaceLg, bottom: gmSpaceSm),
      child: Semantics(
        header: true,
        child: Text(text, style: theme.textTheme.titleMedium),
      ),
    );
    Widget para(String text) => Padding(
      padding: const EdgeInsets.only(bottom: gmSpaceSm),
      child: Text(text, style: theme.textTheme.bodyLarge),
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: const GmTitle('Help and privacy'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(
                  'This page works without internet.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                heading('Enjoying it together'),
                para(
                  'Follow the person’s interests. Keep pictures visible, use '
                  'fewer tiles, or simply look together. There is no need to '
                  'remember names or finish a game. It is fine to stop, or to '
                  'change the activity, at any time.',
                ),
                para(
                  'Golden Moments offers recreation and shared conversation. '
                  'It does not diagnose, treat, prevent or measure dementia '
                  'or Alzheimer’s disease.',
                ),
                heading('Your photos and privacy'),
                para(
                  'You choose which photos to add. Copies are kept on this '
                  'device, and your originals are never changed. There is no '
                  'account and no family sync.',
                ),
                para(
                  'Copies may be included in your phone’s backups. Removing a '
                  'copy here does not erase an earlier backup or a picture '
                  'someone already received.',
                ),
                para(
                  'The picture library is included in the app and works '
                  'without internet.',
                ),
                heading('If something goes wrong'),
                para(
                  'Photos would not add: choose fewer or smaller photos and '
                  'check your free space. Nothing already saved is changed.',
                ),
                para(
                  'A game was not where you left it: choose Start fresh. Your '
                  'photos and settings are not affected.',
                ),
                para(
                  'Text or buttons are hard to use: change the text size in '
                  'your phone’s settings. The app follows it.',
                ),
                heading('Reach us'),
                para(
                  'You can email $supportEmail (copy it; the app does not '
                  'open your mail), or send a note or a problem report below. '
                  'You review exactly what will be sent. Nothing is sent '
                  'automatically.',
                ),
                GmCopyableText(
                  supportEmail,
                  style: theme.textTheme.titleMedium,
                ),
                para(
                  'Online help, when you are connected (copy this into your '
                  'browser; the app does not open it):',
                ),
                GmCopyableText(supportUrl, style: theme.textTheme.titleMedium),
                para(
                  'Privacy policy and terms of use (also copy-only; the app '
                  'does not open them):',
                ),
                GmCopyableText(
                  privacyPolicyUrl,
                  style: theme.textTheme.titleMedium,
                ),
                GmCopyableText(termsUrl, style: theme.textTheme.titleMedium),
                const SizedBox(height: gmSpaceSm),
                OutlinedButton.icon(
                  onPressed: _writeNote,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Write a note'),
                ),
                const SizedBox(height: gmSpaceSm),
                OutlinedButton.icon(
                  onPressed: _reportProblem,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Report a problem'),
                ),
                heading('Tell other families'),
                para(
                  'If Golden Moments has been useful, a rating in the store '
                  'helps other families find it. It is entirely optional, '
                  'and separate from writing to us.',
                ),
                OutlinedButton.icon(
                  onPressed: _rate,
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Rate Golden Moments'),
                ),
                if (_status != null) ...[
                  const SizedBox(height: gmSpaceMd),
                  Semantics(
                    liveRegion: true,
                    child: Text(_status!, style: theme.textTheme.bodyLarge),
                  ),
                ],
                const SizedBox(height: gmSpaceLg),
                Text(
                  'Version $appVersion',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: gmSpaceMd),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The person reads the exact words before choosing where they go.
class _NoteDialog extends StatefulWidget {
  const new();

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = feedbackMessage(_controller.text);
    return AlertDialog(
      scrollable: true,
      title: const GmTitle('Write a note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            maxLength: maxNoteLength,
            maxLines: 5,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Your note',
              helperText:
                  'Please leave out names, addresses and anything private.',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: gmSpaceMd),
          Text(
            'This is exactly what will be shared:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: gmSpaceSm),
          GmCopyableText(preview),
        ],
      ),
      actions: gmDialogActions(
        other: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', textAlign: TextAlign.center),
        ),
        primary: FilledButton(
          onPressed: _controller.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, _controller.text),
          child: const Text(
            'Choose where to send',
            textAlign: TextAlign.center,
          ),
        ),
        labels: ('Cancel', 'Choose where to send'),
      ),
    );
  }
}

class _ProblemDialog extends StatefulWidget {
  const new();

  @override
  State<_ProblemDialog> createState() => _ProblemDialogState();
}

class _ProblemDialogState extends State<_ProblemDialog> {
  ProblemKind _kind = ProblemKind.somethingElse;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const GmTitle('Report a problem'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioGroup<ProblemKind>(
            groupValue: _kind,
            onChanged: (value) => setState(() => _kind = value ?? _kind),
            child: Column(
              children: [
                for (final kind in ProblemKind.values)
                  RadioListTile<ProblemKind>(
                    contentPadding: EdgeInsets.zero,
                    value: kind,
                    title: Text(kind.label),
                  ),
              ],
            ),
          ),
          const SizedBox(height: gmSpaceSm),
          Text(
            'This is exactly what will be shared. It has no photos, names or '
            'file details:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: gmSpaceSm),
          GmCopyableText(diagnosticSummary(_kind)),
        ],
      ),
      actions: gmDialogActions(
        other: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', textAlign: TextAlign.center),
        ),
        primary: FilledButton(
          onPressed: () => Navigator.pop(context, _kind),
          child: const Text(
            'Choose where to send',
            textAlign: TextAlign.center,
          ),
        ),
        labels: ('Cancel', 'Choose where to send'),
      ),
    );
  }
}
