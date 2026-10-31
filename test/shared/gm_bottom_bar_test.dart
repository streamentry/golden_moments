import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/widgets/gm_bottom_bar.dart';

/// The colour of the line along the top of the bar.
Color _line(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(GmBottomBar),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  final border = (box.decoration as BoxDecoration).border! as Border;
  return border.top.color;
}

Widget _page({required GmMoreBelow moreBelow, required double contentHeight}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: gmBuildTheme(),
    home: Scaffold(
      body: moreBelow.watch(
        ListView(
          children: [
            SizedBox(height: contentHeight, child: const Text('Content')),
          ],
        ),
      ),
      bottomNavigationBar: GmBottomBar(
        moreBelow: moreBelow,
        child: OutlinedButton(
          onPressed: () {},
          child: const Text('Done for now'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('no line when the content ends above the bar', (tester) async {
    final moreBelow = GmMoreBelow();
    addTearDown(moreBelow.dispose);
    await tester.pumpWidget(_page(moreBelow: moreBelow, contentHeight: 100));
    await tester.pumpAndSettle();
    expect(moreBelow.value, isFalse);
    expect(_line(tester), Colors.transparent);
  });

  testWidgets('a line marks content that continues under the bar, until the '
      'end is reached', (tester) async {
    final moreBelow = GmMoreBelow();
    addTearDown(moreBelow.dispose);
    await tester.pumpWidget(_page(moreBelow: moreBelow, contentHeight: 3000));
    await tester.pumpAndSettle();
    expect(moreBelow.value, isTrue);
    expect(_line(tester), gmDriftwood500);

    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(moreBelow.value, isFalse);
    expect(_line(tester), Colors.transparent);

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(moreBelow.value, isTrue);
  });

  testWidgets('the bar keeps the content column and never adds height for '
      'the line', (tester) async {
    final moreBelow = GmMoreBelow();
    addTearDown(moreBelow.dispose);
    await tester.binding.setSurfaceSize(const Size(1024, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_page(moreBelow: moreBelow, contentHeight: 100));
    await tester.pumpAndSettle();
    final quiet = tester.getSize(find.byType(GmBottomBar));
    final button = tester.getRect(find.byType(OutlinedButton));
    expect(button.width, lessThanOrEqualTo(gmContentMaxWidth));

    await tester.pumpWidget(_page(moreBelow: moreBelow, contentHeight: 3000));
    await tester.pumpAndSettle();
    expect(moreBelow.value, isTrue);
    expect(tester.getSize(find.byType(GmBottomBar)), quiet);
  });

  testWidgets('without a listenable the bar draws no line', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: gmBuildTheme(),
        home: const Scaffold(
          bottomNavigationBar: GmBottomBar(child: Text('Done for now')),
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(GmBottomBar),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
  });
}
