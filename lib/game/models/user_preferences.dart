import 'package:equatable/equatable.dart';
import 'package:golden_moments/data/models/pack.dart';

/// Font size options for accessibility
enum FontSize {
  small(multiplier: 1, displayName: 'Small'),
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
    this.highContrastMode = false,
    this.preferredDifficulty = GameDifficulty.easy,
    this.isMusicOn = true,
    this.isSoundOn = true,
    this.isHapticsOn = true,
    this.autoReadCaptions = true,
    this.animationSpeed = 1.0,
    this.completedPacks = const [],
    this.isPremiumUser = false,
    this.adFreeEnabled = false,
  });

  /// Selected font size for accessibility
  final FontSize fontSize;

  /// Whether high contrast mode is enabled
  final bool highContrastMode;

  /// User's preferred difficulty level
  final GameDifficulty preferredDifficulty;

  /// Whether music is enabled
  final bool isMusicOn;

  /// Whether sound effects are enabled
  final bool isSoundOn;

  /// Whether haptic feedback is enabled
  final bool isHapticsOn;

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
    bool? isSoundOn,
    bool? isMusicOn,
    bool? isHapticsOn,
    bool? highContrastMode,
    GameDifficulty? preferredDifficulty,
    bool? autoReadCaptions,
    double? animationSpeed,
    List<String>? completedPacks,
    bool? isPremiumUser,
    bool? adFreeEnabled,
  }) {
    return UserPreferences(
      fontSize: fontSize ?? this.fontSize,
      isSoundOn: isSoundOn ?? this.isSoundOn,
      isMusicOn: isMusicOn ?? this.isMusicOn,
      isHapticsOn: isHapticsOn ?? this.isHapticsOn,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
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
    isSoundOn,
    isMusicOn,
    isHapticsOn,
    highContrastMode,
    preferredDifficulty,
    autoReadCaptions,
    animationSpeed,
    completedPacks,
    isPremiumUser,
    adFreeEnabled,
  ];
}
