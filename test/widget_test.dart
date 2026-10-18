import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';

void main() {
  testWidgets('primary action honors disabled and enabled states', (
    tester,
  ) async {
    var taps = 0;
    Widget button({bool disabled = false}) => MaterialApp(
      home: Scaffold(
        body: GmPrimaryButton(
          label: 'Play',
          disabled: disabled,
          onTap: () => taps++,
        ),
      ),
    );
    await tester.pumpWidget(button(disabled: true));
    await tester.tap(find.text('Play'));
    expect(taps, 0);
    await tester.pumpWidget(button());
    await tester.tap(find.text('Play'));
    expect(taps, 1);
  });
}
