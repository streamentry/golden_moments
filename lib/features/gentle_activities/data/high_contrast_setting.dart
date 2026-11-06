import 'package:flutter/foundation.dart';

/// The app-wide "Higher contrast" choice, read by the theme. The comfort sheet
/// saves it with the other comfort settings and updates this at once, so every
/// screen changes together. Off unless the person turns it on.
class HighContrastSetting extends ChangeNotifier {
  new({bool initial = false}) : _enabled = initial;

  bool _enabled;

  bool get enabled => _enabled;

  void set({required bool enabled}) {
    if (enabled == _enabled) return;
    _enabled = enabled;
    notifyListeners();
  }
}
