import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Music and sound choices for the picture-pack library.
///
/// Quiet by default (DESIGN.md › Sound, GM-003/GM-015): with no stored
/// choice both stay off. A choice saved earlier is read back as it is and
/// never rewritten on load; only an explicit toggle writes.
class SoundSettings with ChangeNotifier {
  /// Used when no explicit choice has been stored.
  static const quietByDefault = false;

  static const musicKey = 'Music_Key';
  static const soundKey = 'Sound_Key';

  bool _isMusicOn = quietByDefault;
  bool _isSoundOn = quietByDefault;

  bool get isMusicOn => _isMusicOn;
  bool get isSoundOn => _isSoundOn;

  void toggleMusic() {
    _isMusicOn = !_isMusicOn;
    unawaited(_save(musicKey, value: _isMusicOn));
    notifyListeners();
  }

  void toggleSound() {
    _isSoundOn = !_isSoundOn;
    unawaited(_save(soundKey, value: _isSoundOn));
    notifyListeners();
  }

  /// Loads saved choices; a missing value means quiet.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool(musicKey) ?? quietByDefault;
    _isSoundOn = prefs.getBool(soundKey) ?? quietByDefault;
    notifyListeners();
  }

  /// Saves only the choice that changed, so the other one keeps its own
  /// earlier choice or the quiet default.
  Future<void> _save(String key, {required bool value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
