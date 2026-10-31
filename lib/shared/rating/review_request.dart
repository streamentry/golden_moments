import 'package:flutter/foundation.dart';
import 'package:golden_moments/shared/native/gm_native.dart';
import 'package:golden_moments/shared/utils/share_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// When to ask the system to show its rating prompt (DESIGN.md › Ratings).
///
/// Only after a finished game, once the person is back on Home (a voluntary
/// pause, never during play or at launch), and only after the app has been
/// enjoyed on more than one day. Apple also caps the prompt at three a year.
/// Every person is asked the same way: there is no satisfaction pre-screen.
class ReviewPolicy {
  const new _();

  static const minFinishedGames = 4;
  static const minPlayDays = 2;
  static const quietPeriod = Duration(days: 120);

  static bool shouldAsk({
    required bool finishedSinceHome,
    required int finishedGames,
    required int playDays,
    required DateTime now,
    DateTime? lastAsked,
  }) {
    if (!finishedSinceHome) return false;
    if (finishedGames < minFinishedGames || playDays < minPlayDays) {
      return false;
    }
    return lastAsked == null || now.difference(lastAsked) >= quietPeriod;
  }
}

/// Device-local memory for [ReviewPolicy]. No account, server or analytics.
class ReviewRequestStore {
  new _(this._prefs);

  static const _finishedKey = 'review_finished_games';
  static const _daysKey = 'review_play_days';
  static const _lastDayKey = 'review_last_play_day';
  static const _pendingKey = 'review_finished_since_home';
  static const _lastAskedKey = 'review_last_asked_ms';

  final SharedPreferences _prefs;

  static Future<ReviewRequestStore> load() async =>
      ReviewRequestStore._(await SharedPreferences.getInstance());

  static String _day(DateTime at) =>
      '${at.year}-${at.month.toString().padLeft(2, '0')}-'
      '${at.day.toString().padLeft(2, '0')}';

  /// Records a finished game: one more game, and one more day of play when
  /// this is the first finished game today. [mayAsk] is false when the finish
  /// already suggested sharing, so the two requests never follow each other.
  Future<void> recordFinishedGame({DateTime? now, bool mayAsk = true}) async {
    final today = _day(now ?? DateTime.now());
    await _prefs.setInt(_finishedKey, (_prefs.getInt(_finishedKey) ?? 0) + 1);
    if (_prefs.getString(_lastDayKey) != today) {
      await _prefs.setString(_lastDayKey, today);
      await _prefs.setInt(_daysKey, (_prefs.getInt(_daysKey) ?? 0) + 1);
    }
    await _prefs.setBool(_pendingKey, mayAsk);
  }

  /// Called when Home is shown again. Reports whether to ask now and, if so,
  /// remembers asking. A finished game counts once, whatever the answer.
  Future<bool> takeAskOnReturnHome({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final pending = _prefs.getBool(_pendingKey) ?? false;
    if (pending) await _prefs.setBool(_pendingKey, false);
    final lastMs = _prefs.getInt(_lastAskedKey);
    final ask = ReviewPolicy.shouldAsk(
      finishedSinceHome: pending,
      finishedGames: _prefs.getInt(_finishedKey) ?? 0,
      playDays: _prefs.getInt(_daysKey) ?? 0,
      now: at,
      lastAsked: lastMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastMs),
    );
    if (ask) await _prefs.setInt(_lastAskedKey, at.millisecondsSinceEpoch);
    return ask;
  }
}

/// Records a finished game for [ReviewPolicy]; pass whether the finish
/// suggested sharing. Best effort: storage trouble never affects play.
Future<void> recordFinishedGameForReview({
  required bool suggestedSharing,
}) async {
  try {
    await (await ReviewRequestStore.load()).recordFinishedGame(
      mayAsk: !suggestedSharing,
    );
  } on Object {
    // Rating is optional; never block play on storage.
  }
}

/// On returning to Home, asks the system for its rating prompt when
/// [ReviewPolicy] allows it.
Future<void> askForReviewOnReturnHome({
  GmNative native = const GmNative(),
}) async {
  if (!native.isSupported) return;
  try {
    final store = await ReviewRequestStore.load();
    if (await store.takeAskOnReturnHome()) await native.requestReview();
  } on Object {
    // Rating is optional; never interrupt Home.
  }
}

/// Where a person who chooses "Rate Golden Moments" is taken: the App Store
/// review page on Apple devices, the Play listing elsewhere. No tracking.
String storeReviewUrl({TargetPlatform? platform}) {
  final target = platform ?? defaultTargetPlatform;
  return switch (target) {
    TargetPlatform.iOS || TargetPlatform.macOS =>
      'https://apps.apple.com/app/id$appStoreId?action=write-review',
    _ => playStoreUrl,
  };
}
