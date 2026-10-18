import 'package:flutter/foundation.dart';

/// Matches `version:` in pubspec.yaml; a test keeps the two in step.
const String appVersion = '1.3.0+5';

/// A public support address, once the owner decides one. Until then no
/// address is shown and reports go through the system share sheet instead.
const String? supportEmail = null;

/// What went wrong, as a short closed list. A report carries only one of
/// these codes, never free text, file names, photo details or paths.
enum ProblemKind {
  photosNotAdded('photo-import', 'Photos would not add'),
  photosNotShown('photo-display', 'A photo would not show'),
  boardMissing('resume', 'My game was not where I left it'),
  textTooSmall('text-size', 'Text or buttons were hard to use'),
  somethingElse('other', 'Something else');

  new(this.code, this.label);
  final String code;
  final String label;
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
String diagnosticSummary(ProblemKind kind, {TargetPlatform? platform}) =>
    'Golden Moments $appVersion\n'
    'Platform: ${_platformName(platform ?? defaultTargetPlatform)}\n'
    'Problem: ${kind.code}';

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
