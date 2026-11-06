import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_preferences.dart';
import 'package:golden_moments/features/gentle_activities/data/high_contrast_setting.dart';

void main() {
  test('higher contrast is off by default and survives a save and reload', () {
    expect(const GentlePreferences().highContrast, isFalse);
    final on = const GentlePreferences().copyWith(highContrast: true);
    final back = GentlePreferences.fromJson(on.toJson());
    expect(back.highContrast, isTrue);
    expect(back, on);
  });

  test('an older saved choice with no contrast field loads with it off', () {
    final old = GentlePreferences.fromJson({
      'v': 1,
      'pairs': 4,
      'keepVisible': true,
    });
    expect(old.highContrast, isFalse);
    expect(old.pairs, 4);
  });

  test('a damaged contrast value is treated as off, not as on', () {
    final bad = GentlePreferences.fromJson({'v': 1, 'highContrast': 'yes'});
    expect(bad.highContrast, isFalse);
  });

  test('the app-wide setting notifies only on a real change', () {
    final setting = HighContrastSetting();
    var calls = 0;
    setting.addListener(() => calls++);
    setting.set(enabled: true);
    setting.set(enabled: true);
    setting.set(enabled: false);
    expect(calls, 2);
    expect(setting.enabled, isFalse);
  });

  test('the setting starts from the saved choice', () {
    expect(HighContrastSetting(initial: true).enabled, isTrue);
  });
}
