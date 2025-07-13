import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/pack.dart';

/// Font size options for accessibility
enum FontSize {
  small(multiplier: 1.0, displayName: 'Small'),
  medium(multiplier: 1.2, displayName: 'Medium'),
  large(multiplier: 1.5, displayName: 'Large'),
  extraLarge(multiplier: 1.8, displayName: 'Extra Large');

  const FontSize({
    required this.multiplier,
    required this.displayName,
  });

  /// Multiplier to apply to base font sizes
  final double multiplier;

  /// Human-readable name for the font size
  final String displayName;
}

/// User preferences and settings
class UserPreferences extends Equatable {
  const UserPreferences({
    this.fontSize = FontSize.large,
    this.voiceEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.highContrastMode = false,
    this.preferredDifficulty = GameDifficulty.easy,
    this.soundEnabled = true,
    this.autoReadCaptions = true,
    this.animationSpeed = 1.0,
    this.completedPacks = const [],
    this.isPremiumUser = false,
    this.adFreeEnabled = false,
  });

  /// Selected font size for accessibility
  final FontSize fontSize;

  /// Whether voice-over/text-to-speech is enabled
  final bool voiceEnabled;

  /// Whether haptic feedback is enabled
  final bool hapticFeedbackEnabled;

  /// Whether high contrast mode is enabled
  final bool highContrastMode;

  /// User's preferred difficulty level
  final GameDifficulty preferredDifficulty;

  /// Whether sound effects are enabled
  final bool soundEnabled;

  /// Whether captions should be read aloud automatically
  final bool autoReadCaptions;

  /// Animation speed multiplier (0.5 = slower, 2.0 = faster)
  final double animationSpeed;

  /// List of completed pack IDs
  final List<String> completedPacks;

  /// Whether user has premium subscription
  final bool isPremiumUser;

  /// Whether user has purchased ad-free experience
  final bool adFreeEnabled;

  /// Creates a copy of preferences with updated properties
  UserPreferences copyWith({
    FontSize? fontSize,
    bool? voiceEnabled,
    bool? hapticFeedbackEnabled,
    bool? highContrastMode,
    GameDifficulty? preferredDifficulty,
    bool? soundEnabled,
    bool? autoReadCaptions,
    double? animationSpeed,
    List<String>? completedPacks,
    bool? isPremiumUser,
    bool? adFreeEnabled,
  }) {
    return UserPreferences(
      fontSize: fontSize ?? this.fontSize,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoReadCaptions: autoReadCaptions ?? this.autoReadCaptions,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      completedPacks: completedPacks ?? this.completedPacks,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      adFreeEnabled: adFreeEnabled ?? this.adFreeEnabled,
    );
  }

  @override
  List<Object?> get props => [
    fontSize,
    voiceEnabled,
    hapticFeedbackEnabled,
    highContrastMode,
    preferredDifficulty,
    soundEnabled,
    autoReadCaptions,
    animationSpeed,
    completedPacks,
    isPremiumUser,
    adFreeEnabled,
  ];
}
