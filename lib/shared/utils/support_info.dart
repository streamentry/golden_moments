import 'package:flutter/foundation.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// Matches `version:` in pubspec.yaml; a test keeps the two in step.
const String appVersion = '1.5.0+9';

/// The public help page already declared as `support_url` in the canonical
/// store metadata (a test keeps the two identical). It is shown as text to
/// copy; the app never opens it, so nothing leaves the device from here.
const String supportUrl = 'https://dementiaactivities.games/help/';

/// The mobile-app privacy policy and the terms of use on the owner's site.
/// Shown as text to copy, never opened by the app. The privacy page is the
/// app policy (`/app-privacy/`), not the general website notice.
const String privacyPolicyUrl = 'https://dementiaactivities.games/app-privacy/';
const String termsUrl = 'https://dementiaactivities.games/terms/';

/// The support address the owner publishes on the same site. Shown as text to
/// copy; the app never opens a mail client or sends anything by itself.
const String supportEmail = 'apple@locuno.com';

/// What went wrong, as a short closed list. A report carries only one of
/// these codes, never free text, file names, photo details or paths. The
/// codes stay in English so support can read every report; only the label
/// the person chooses from is translated.
enum ProblemKind {
  photosNotAdded('photo-import'),
  photosNotShown('photo-display'),
  boardMissing('resume'),
  textTooSmall('text-size'),
  somethingElse('other');

  new(this.code);
  final String code;

  /// The choice as the person reads it in the report dialog.
  String label(AppLocalizations l10n) => switch (this) {
    ProblemKind.photosNotAdded => l10n.supportProblemPhotosNotAdded,
    ProblemKind.photosNotShown => l10n.supportProblemPhotoNotShown,
    ProblemKind.boardMissing => l10n.supportProblemBoardMissing,
    ProblemKind.textTooSmall => l10n.supportProblemTextTooSmall,
    ProblemKind.somethingElse => l10n.supportProblemSomethingElse,
  };
}

String _platformName(TargetPlatform platform) => switch (platform) {
  TargetPlatform.iOS => 'iOS',
  TargetPlatform.android => 'Android',
  TargetPlatform.macOS => 'macOS',
  TargetPlatform.windows => 'Windows',
  TargetPlatform.linux => 'Linux',
  TargetPlatform.fuchsia => 'Fuchsia',
};

/// The whole report: app version, platform family and one problem code.
/// No device identifiers, no OS build, no photos, hashes, captions or logs.
/// The line names follow the app's language; the platform name and the
/// problem code stay in English.
String diagnosticSummary(
  ProblemKind kind,
  AppLocalizations l10n, {
  TargetPlatform? platform,
}) => [
  'Golden Moments $appVersion',
  l10n.supportReportPlatform(_platformName(platform ?? defaultTargetPlatform)),
  l10n.supportReportProblem(kind.code),
].join('\n');

/// Longest note that can be shared.
const int maxNoteLength = 1000;

/// Plain text the person wrote, tidied, with the app version and platform so
/// it can be understood. Nothing else is attached.
String feedbackMessage(String note, {TargetPlatform? platform}) {
  final cleaned = note
      // Control characters, zero-width and direction-override characters are
      // invisible in the preview, so none of them are sent.
      .replaceAll(
        RegExp(
          r'[\u0000-\u0008\u000B-\u001F\u007F-\u009F'
          r'\u200B-\u200F\u202A-\u202E\u2060-\u2064\u2066-\u2069\uFEFF]',
        ),
        ' ',
      )
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
  final body = cleaned.runes.length <= maxNoteLength
      ? cleaned
      : String.fromCharCodes(cleaned.runes.take(maxNoteLength)).trimRight();
  return '$body\n\n'
      '— Golden Moments $appVersion, '
      '${_platformName(platform ?? defaultTargetPlatform)}';
}
