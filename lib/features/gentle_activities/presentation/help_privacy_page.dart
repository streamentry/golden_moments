import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';
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
    final l10n = context.l10n;
    setState(
      () => _status = switch (outcome) {
        ShareOutcome.shared => l10n.helpStatusShared,
        ShareOutcome.dismissed => l10n.helpStatusDismissed,
        ShareOutcome.unknown => l10n.helpStatusUnknown,
      },
    );
  }

  Future<void> _writeNote() async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => const _NoteDialog(),
    );
    if (note == null || note.trim().isEmpty || !mounted) return;
    await _send(feedbackMessage(note), context.l10n.helpNoteSubject);
  }

  Future<void> _rate() async {
    if (await widget.storeOpener(storeReviewUrl()) || !mounted) return;
    final message = context.l10n.helpStatusStoreFailed;
    setState(() => _status = message);
  }

  Future<void> _reportProblem() async {
    final kind = await showDialog<ProblemKind>(
      context: context,
      builder: (context) => const _ProblemDialog(),
    );
    if (kind == null || !mounted) return;
    await _send(
      diagnosticSummary(kind, context.l10n),
      context.l10n.helpProblemSubject,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final l10n = context.l10n;
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
        title: GmTitle(l10n.helpTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(
                  l10n.helpWorksOffline,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                heading(l10n.helpTogetherHeading),
                para(l10n.helpTogetherInterests),
                para(l10n.helpTogetherNotMedical),
                heading(l10n.helpPhotosHeading),
                para(l10n.helpPhotosChoose),
                para(l10n.helpPhotosBackups),
                para(l10n.helpPhotosLibrary),
                heading(l10n.helpTroubleHeading),
                para(l10n.helpTroublePhotos),
                para(l10n.helpTroubleGame),
                para(l10n.helpTroubleTextSize),
                heading(l10n.helpReachHeading),
                para(l10n.helpReachEmail(supportEmail)),
                GmCopyableText(
                  supportEmail,
                  style: theme.textTheme.titleMedium,
                ),
                para(l10n.helpOnlineHelp),
                GmCopyableText(supportUrl, style: theme.textTheme.titleMedium),
                para(l10n.helpPolicyLinks),
                GmCopyableText(
                  privacyPolicyUrl,
                  style: theme.textTheme.titleMedium,
                ),
                GmCopyableText(termsUrl, style: theme.textTheme.titleMedium),
                const SizedBox(height: gmSpaceSm),
                OutlinedButton.icon(
                  onPressed: _writeNote,
                  icon: const Icon(Icons.edit_note),
                  label: Text(l10n.helpWriteNote),
                ),
                const SizedBox(height: gmSpaceSm),
                OutlinedButton.icon(
                  onPressed: _reportProblem,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text(l10n.commonReportProblem),
                ),
                heading(l10n.helpRateHeading),
                para(l10n.helpRateBody),
                OutlinedButton.icon(
                  onPressed: _rate,
                  icon: const Icon(Icons.star_outline),
                  label: Text(l10n.helpRateButton),
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
                  l10n.helpVersion(appVersion),
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
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
    final l10n = context.l10n;
    return AlertDialog(
      scrollable: true,
      title: GmTitle(l10n.helpWriteNote),
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
            decoration: InputDecoration(
              labelText: l10n.helpNoteField,
              helperText: l10n.helpNoteFieldHint,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: gmSpaceMd),
          Text(
            l10n.helpNotePreviewHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: gmSpaceSm),
          GmCopyableText(preview),
        ],
      ),
      actions: gmDialogActions(
        other: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel, textAlign: TextAlign.center),
        ),
        primary: FilledButton(
          onPressed: _controller.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, _controller.text),
          child: Text(l10n.helpChooseWhereToSend, textAlign: TextAlign.center),
        ),
        labels: (l10n.commonCancel, l10n.helpChooseWhereToSend),
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
    final l10n = context.l10n;
    return AlertDialog(
      scrollable: true,
      title: GmTitle(l10n.commonReportProblem),
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
                    title: Text(kind.label(context.l10n)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: gmSpaceSm),
          Text(
            l10n.helpProblemPreviewHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: gmSpaceSm),
          GmCopyableText(diagnosticSummary(_kind, context.l10n)),
        ],
      ),
      actions: gmDialogActions(
        other: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel, textAlign: TextAlign.center),
        ),
        primary: FilledButton(
          onPressed: () => Navigator.pop(context, _kind),
          child: Text(l10n.helpChooseWhereToSend, textAlign: TextAlign.center),
        ),
        labels: (l10n.commonCancel, l10n.helpChooseWhereToSend),
      ),
    );
  }
}
