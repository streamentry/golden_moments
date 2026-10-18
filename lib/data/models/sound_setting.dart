import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundSettings with ChangeNotifier {
  bool _isMusicOn = true;
  bool _isSoundOn = true;

  final _musicKey = 'Music_Key';
  final _soundKey = 'Sound_Key';

  bool get isMusicOn => _isMusicOn;
  bool get isSoundOn => _isSoundOn;

  void toggleMusic() {
    _isMusicOn = !_isMusicOn;
    unawaited(_save());
    notifyListeners();
  }

  void toggleSound() {
    _isSoundOn = !_isSoundOn;
    unawaited(_save());
    notifyListeners();
  }

  /// Load saved preferences
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool(_musicKey) ?? true;
    _isSoundOn = prefs.getBool(_soundKey) ?? true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicKey, _isMusicOn);
    await prefs.setBool(_soundKey, _isSoundOn);
  }
}
