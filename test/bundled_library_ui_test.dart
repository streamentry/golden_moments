import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Every test starts from a fresh install. Tests share one isolate in CI
  // (very_good --optimization, random order), so a board or comfort choice
  // saved by another test must not leak in as a resume prompt.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('gentle home opens included packs without storage or downloads', (
    tester,
  ) async {
    await tester.runAsync(() => LocalPackService().getPacksIndex());
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: GentleHomePage(),
      ),
    );
    final library = find.text('Explore the picture-pack library');
    await tester.ensureVisible(library);
    await tester.pumpAndSettle();
    await tester.tap(library);
    await tester.pumpAndSettle();
    expect(find.byType(PackCard), findsWidgets);
    expect(find.text('Download'), findsNothing);
    expect(find.text('Download Pack'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
