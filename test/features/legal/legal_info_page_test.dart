import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/legal/presentation/legal_info_page.dart';

void main() {
  testWidgets('legal information is readable without opening a browser', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LegalInfoPage()));

    expect(find.text('Privacy and information'), findsOneWidget);
    expect(find.text('Your pictures, your choice'), findsOneWidget);
    expect(find.text('Mobile app privacy policy'), findsOneWidget);
    expect(find.text('Privacy choices and deletion'), findsOneWidget);
    expect(find.text('Terms and app license'), findsOneWidget);
    expect(find.text('Safety and intended use'), findsOneWidget);
    expect(find.text('Contact support'), findsOneWidget);
    expect(find.text('apple@locuno.com'), findsOneWidget);
  });
}
