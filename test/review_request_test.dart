import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/shared/native/gm_native.dart';
import 'package:golden_moments/shared/rating/review_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final start = DateTime(2026, 10, 30, 10);

  group('ReviewPolicy', () {
    bool ask({
      bool finished = true,
      int games = 4,
      int days = 2,
      DateTime? lastAsked,
    }) => ReviewPolicy.shouldAsk(
      finishedSinceHome: finished,
      finishedGames: games,
      playDays: days,
      now: start,
      lastAsked: lastAsked,
    );

    test('asks only after a finished game, enjoyed on more than one day', () {
      expect(ask(), isTrue);
      expect(ask(finished: false), isFalse);
      expect(ask(games: 3), isFalse);
      expect(ask(days: 1, games: 10), isFalse);
    });

    test('asks at most once per quiet period', () {
      expect(
        ask(lastAsked: start.subtract(const Duration(days: 119))),
        isFalse,
      );
      expect(ask(lastAsked: start.subtract(const Duration(days: 120))), isTrue);
    });
  });

  group('ReviewRequestStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('counts days of play, not just games', () async {
      final store = await ReviewRequestStore.load();
      for (var i = 0; i < 6; i++) {
        await store.recordFinishedGame(now: start);
      }
      // Six games on one day are not enough.
      expect(await store.takeAskOnReturnHome(now: start), isFalse);
      await store.recordFinishedGame(now: start.add(const Duration(days: 1)));
      expect(
        await store.takeAskOnReturnHome(
          now: start.add(const Duration(days: 1)),
        ),
        isTrue,
      );
    });

    test('returning Home without a new finished game never asks', () async {
      final store = await ReviewRequestStore.load();
      for (var d = 0; d < 4; d++) {
        await store.recordFinishedGame(now: start.add(Duration(days: d)));
      }
      final later = start.add(const Duration(days: 200));
      expect(await store.takeAskOnReturnHome(now: later), isTrue);
      // Leaving and coming back again is not a new finished game.
      final muchLater = later.add(const Duration(days: 200));
      expect(await store.takeAskOnReturnHome(now: muchLater), isFalse);
    });

    test('a finish that suggested sharing does not also ask', () async {
      final store = await ReviewRequestStore.load();
      for (var d = 0; d < 3; d++) {
        await store.recordFinishedGame(now: start.add(Duration(days: d)));
      }
      final at = start.add(const Duration(days: 3));
      await store.recordFinishedGame(now: at, mayAsk: false);
      expect(await store.takeAskOnReturnHome(now: at), isFalse);
      await store.recordFinishedGame(now: at);
      expect(await store.takeAskOnReturnHome(now: at), isTrue);
    });

    test('a finished game counts once, whatever the answer', () async {
      final store = await ReviewRequestStore.load();
      for (var d = 0; d < 4; d++) {
        await store.recordFinishedGame(now: start.add(Duration(days: d)));
      }
      final at = start.add(const Duration(days: 4));
      expect(await store.takeAskOnReturnHome(now: at), isTrue);
      await store.recordFinishedGame(now: at);
      expect(await store.takeAskOnReturnHome(now: at), isFalse);
    });
  });

  group('askForReviewOnReturnHome', () {
    const channel = MethodChannel('golden_moments/native');
    final calls = <String>[];

    setUp(() {
      calls.clear();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call.method);
            return null;
          });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('asks the system once the policy allows it', () async {
      final days = DateTime.now().subtract(const Duration(days: 3));
      SharedPreferences.setMockInitialValues({
        'review_finished_games': 5,
        'review_play_days': 3,
        'review_finished_since_home': true,
        'review_last_play_day': '${days.year}-01-01',
      });
      await askForReviewOnReturnHome();
      expect(calls, ['requestReview']);
      await askForReviewOnReturnHome();
      expect(calls, ['requestReview']);
    });

    test('never asks early in use', () async {
      SharedPreferences.setMockInitialValues({
        'review_finished_games': 1,
        'review_play_days': 1,
        'review_finished_since_home': true,
      });
      await askForReviewOnReturnHome();
      expect(calls, isEmpty);
    });

    test('does nothing where the platform has no prompt', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      SharedPreferences.setMockInitialValues({
        'review_finished_games': 9,
        'review_play_days': 9,
        'review_finished_since_home': true,
      });
      expect(const GmNative().isSupported, isFalse);
      await askForReviewOnReturnHome();
      expect(calls, isEmpty);
    });
  });

  test('the rating link goes to the right store, without tracking', () {
    final apple = storeReviewUrl(platform: TargetPlatform.iOS);
    expect(apple, startsWith('https://apps.apple.com/app/id6749312459'));
    expect(apple, endsWith('action=write-review'));
    expect(
      storeReviewUrl(platform: TargetPlatform.android),
      contains('play.google.com'),
    );
    for (final url in [
      apple,
      storeReviewUrl(platform: TargetPlatform.android),
    ]) {
      expect(url, isNot(contains('utm_')));
    }
  });
}
