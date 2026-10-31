import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/utils/share_util.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// When to suggest sharing (DESIGN.md › Sharing).
///
/// Ask rarely, at the end of a good moment, and never again once the person
/// has shared or has passed it by twice. Counters stay on this device.
class SharePolicy {
  const new _();

  /// The first suggestion waits until people have enjoyed a few games.
  static const firstAskAfterGames = 3;

  /// At most one suggestion in this period.
  static const quietPeriod = Duration(days: 30);

  /// Passing the suggestion by this many times turns it off for good.
  static const maxDeclines = 2;

  static bool shouldAsk({
    required int completedGames,
    required bool shared,
    required int declines,
    required DateTime now,
    DateTime? lastAsked,
  }) {
    if (shared || declines >= maxDeclines) return false;
    if (completedGames < firstAskAfterGames) return false;
    return lastAsked == null || now.difference(lastAsked) >= quietPeriod;
  }
}

/// Device-local memory for [SharePolicy]. No account, server or analytics.
class ShareInvitationStore {
  new _(this._prefs);

  static const _completedKey = 'share_completed_games';
  static const _sharedKey = 'share_has_shared';
  static const _declinesKey = 'share_declines';
  static const _lastAskedKey = 'share_last_asked_ms';

  final SharedPreferences _prefs;

  static Future<ShareInvitationStore> load() async =>
      ShareInvitationStore._(await SharedPreferences.getInstance());

  /// Records a finished game and reports whether to show the suggestion now.
  /// Showing it is recorded here, so it appears at most once per period.
  Future<bool> recordCompletedGame({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final completed = (_prefs.getInt(_completedKey) ?? 0) + 1;
    await _prefs.setInt(_completedKey, completed);
    final lastMs = _prefs.getInt(_lastAskedKey);
    final ask = SharePolicy.shouldAsk(
      completedGames: completed,
      shared: _prefs.getBool(_sharedKey) ?? false,
      declines: _prefs.getInt(_declinesKey) ?? 0,
      now: at,
      lastAsked: lastMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastMs),
    );
    if (ask) await _prefs.setInt(_lastAskedKey, at.millisecondsSinceEpoch);
    return ask;
  }

  Future<void> markShared() => _prefs.setBool(_sharedKey, true);

  Future<void> markDeclined() =>
      _prefs.setInt(_declinesKey, (_prefs.getInt(_declinesKey) ?? 0) + 1);
}

/// Opens the system share sheet. Returns true only when the platform reports
/// that something was actually shared. [l10n] supplies the message in the
/// app's language.
Future<bool> shareGoldenMoments(AppLocalizations l10n) async {
  try {
    final result = await SharePlus.instance.share(
      ShareParams(text: appShareText(l10n), subject: l10n.appTitle),
    );
    return result.status == ShareResultStatus.success;
  } on Object {
    return false;
  }
}

/// Shares and, if it worked, stops future suggestions. Returns whether
/// something was shared.
Future<bool> shareAndRemember(AppLocalizations l10n) async {
  if (!await shareGoldenMoments(l10n)) return false;
  try {
    await (await ShareInvitationStore.load()).markShared();
  } on Object {
    // Sharing already happened; remembering it is best effort.
  }
  return true;
}

/// A quiet, inline suggestion shown inside an end-of-game message. It never
/// opens on its own, counts down or blocks play; simply carrying on is a
/// complete answer.
class ShareInvitation extends StatelessWidget {
  const new({required this.onShare, super.key});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(gmRadiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.shareInvitationText,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: gmSpaceSm),
            ShareWithFamilyButton(onPressed: onShare),
          ],
        ),
      ),
    );
  }
}

/// The always-available, low-key way to share.
class ShareWithFamilyButton extends StatelessWidget {
  const new({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onPressed,
    icon: Icon(Icons.adaptive.share),
    label: Text(context.l10n.shareWithFamily),
  );
}
