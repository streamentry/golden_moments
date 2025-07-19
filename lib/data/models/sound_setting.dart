import 'package:flutter/foundation.dart';

class SoundSettings with ChangeNotifier {
  bool _isMusicOn = true;
  bool _isSoundOn = true;

  bool get isMusicOn => _isMusicOn;
  bool get isSoundOn => _isSoundOn;

  void toggleMusic() {
    _isMusicOn = !_isMusicOn;
    notifyListeners();
  }

  void toggleSound() {
    _isSoundOn = !_isSoundOn;
    notifyListeners();
  }

  void setMusic(bool value) {
    _isMusicOn = value;
    notifyListeners();
  }

  void setSound(bool value) {
    _isSoundOn = value;
    notifyListeners();
  }
}
