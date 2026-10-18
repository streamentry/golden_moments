import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';

void main() {
  testWidgets('starter works without plugin or network initialization', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GentleHomePage()));
    await tester.tap(find.text('Start a gentle game'));
    await tester.pumpAndSettle();
    expect(find.text('Gentle photo match'), findsOneWidget);
    expect(find.text('4 tiles'), findsOneWidget);
    expect(find.text('Keep pictures visible'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('four-tile game supports large text on a narrow phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const GentleGamePage(pictures: ActivityPicture.samples),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
