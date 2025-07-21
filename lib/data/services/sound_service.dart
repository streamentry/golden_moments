import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:golden_moments/data/models/sound_setting.dart';

/// Singleton service for playing app sounds
class SoundService with WidgetsBindingObserver {
  factory SoundService() => _instance;
  SoundService._internal() {
    WidgetsBinding.instance.addObserver(this); // Observe app lifecycle changes
  }
  static final SoundService _instance = SoundService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  late SoundSettings _soundSettings;

  Future<void> initialize(SoundSettings settings) async {
    _soundSettings = settings;

    await _musicPlayer.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none, // allow mixing
        ),
      ),
    );
    await _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(1);

    // Listen to changes to auto-play/stop music
    _soundSettings.addListener(_onSettingsChanged);

    if (_soundSettings.isMusicOn) {
      await playMusic();
    }
  }

  void _onSettingsChanged() {
    if (_soundSettings.isMusicOn) {
      playMusic();
    } else {
      _musicPlayer.stop();
    }
  }

  Future<void> _playAsset(String assetPath, {bool isMusic = false}) async {
    if (isMusic && !_soundSettings.isMusicOn) return;
    if (!isMusic && !_soundSettings.isSoundOn) return;
    if (isMusic) {
      switch (_musicPlayer.state) {
        case PlayerState.paused:
          await _musicPlayer.resume();
        case PlayerState.stopped:
        case PlayerState.completed:
        case PlayerState.disposed:
          await _musicPlayer.play(AssetSource(assetPath));
        case PlayerState.playing:
      }
    } else {
      // Use a separate player for sound effects to avoid disrupting music
      final soundEffectPlayer = AudioPlayer();
      await soundEffectPlayer.setPlayerMode(PlayerMode.lowLatency);
      await soundEffectPlayer.play(AssetSource(assetPath));
      soundEffectPlayer.onPlayerComplete.listen((_) {
        soundEffectPlayer.dispose();
      });
    }
  }

  Future<void> playTap() => _playAsset('sounds/button_tap.mp3');
  Future<void> playWinner() => _playAsset('sounds/winner.mp3');
  Future<void> playMusic() => _playAsset('sounds/music.mp3', isMusic: true);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _musicPlayer.pause();
    } else if (state == AppLifecycleState.resumed && _soundSettings.isMusicOn) {
      _musicPlayer.resume();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Clean up observer
    _musicPlayer.dispose();
  }
}
