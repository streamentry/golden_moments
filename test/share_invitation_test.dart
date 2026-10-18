import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/shared/sharing/share_invitation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final start = DateTime(2026, 10, 18);

  group('SharePolicy', () {
    bool ask({
      int completed = 3,
      bool shared = false,
      int declines = 0,
      DateTime? lastAsked,
      DateTime? now,
    }) => SharePolicy.shouldAsk(
      completedGames: completed,
      shared: shared,
      declines: declines,
      lastAsked: lastAsked,
      now: now ?? start,
    );

    test('waits until a few games have been enjoyed', () {
      expect(ask(completed: 1), isFalse);
      expect(ask(completed: 2), isFalse);
      expect(ask(), isTrue);
    });

    test('asks at most once per quiet period', () {
      expect(ask(lastAsked: start.subtract(const Duration(days: 29))), isFalse);
      expect(ask(lastAsked: start.subtract(const Duration(days: 30))), isTrue);
    });

    test('stops for good after sharing or after passing it by twice', () {
      expect(ask(shared: true), isFalse);
      expect(ask(declines: 1), isTrue);
      expect(ask(declines: 2), isFalse);
    });
  });

  group('ShareInvitationStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('suggests on the third game, then rests, then gives up', () async {
      final store = await ShareInvitationStore.load();
      expect(await store.recordCompletedGame(now: start), isFalse);
      expect(await store.recordCompletedGame(now: start), isFalse);
      expect(await store.recordCompletedGame(now: start), isTrue);
      expect(await store.recordCompletedGame(now: start), isFalse);
      await store.markDeclined();

      final later = start.add(const Duration(days: 31));
      expect(await store.recordCompletedGame(now: later), isTrue);
      await store.markDeclined();

      final muchLater = later.add(const Duration(days: 365));
      expect(await store.recordCompletedGame(now: muchLater), isFalse);
    });

    test('never suggests again after sharing', () async {
      final store = await ShareInvitationStore.load();
      await store.markShared();
      for (var i = 0; i < 5; i++) {
        expect(await store.recordCompletedGame(now: start), isFalse);
      }
    });
  });

  group('gentle game', () {
    Future<void> finishBoard(WidgetTester tester) async {
      final tiles = find.bySemanticsLabel(RegExp(r', tile \d+$'));
      final groups = <String, List<int>>{};
      final count = tester.widgetList(tiles).length;
      for (var i = 0; i < count; i++) {
        final label = tester.getSemantics(tiles.at(i)).label.split(', ').first;
        groups.putIfAbsent(label, () => []).add(i);
      }
      for (final pair in groups.values) {
        for (final index in pair) {
          await tester.ensureVisible(tiles.at(index));
          await tester.tap(tiles.at(index));
          await tester.pump();
        }
      }
      await tester.pumpAndSettle();
    }

    Future<void> pumpGame(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: gmBuildTheme(),
          home: const GentleGamePage(pictures: ActivityPicture.samples),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the first finished games carry no suggestion', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await pumpGame(tester);
      await finishBoard(tester);
      expect(
        find.text('All pairs together. Play again or take a break.'),
        findsOneWidget,
      );
      expect(find.byType(ShareInvitation), findsNothing);
    });

    testWidgets('the third finished game shows a quiet inline suggestion; '
        'carrying on counts as "not now"', (tester) async {
      SharedPreferences.setMockInitialValues({'share_completed_games': 2});
      await pumpGame(tester);
      await finishBoard(tester);
      expect(find.byType(ShareInvitation), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);

      await tester.ensureVisible(find.text('Play again'));
      await tester.tap(find.text('Play again'));
      await tester.pumpAndSettle();
      expect(find.byType(ShareInvitation), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('share_declines'), 1);
    });
  });
}
