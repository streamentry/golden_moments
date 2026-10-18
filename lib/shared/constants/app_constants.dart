/// Application-wide constants for Memory Lane
class AppConstants {
  AppConstants._();

  // App information
  static const String appName = 'Golden Moments';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'A nostalgia-themed memory game for seniors';

  // Game configuration
  static const int maxSelectedTiles = 2;
  static const Duration tileFlipDuration = Duration(milliseconds: 300);
  static const Duration matchCelebrationDuration = Duration(milliseconds: 800);

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Layout constants
  static const double defaultPadding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;
  static const double cardBorderRadius = 16;
  static const double buttonBorderRadius = 12;

  // Accessibility
  static const double minTouchTargetSize = 48;
  static const double maxFontSizeMultiplier = 2;
  static const double minFontSizeMultiplier = 0.8;

  // Storage keys
  static const String userPreferencesKey = 'user_preferences';
  static const String completedPacksKey = 'completed_packs';
  static const String gameProgressKey = 'game_progress';
  static const String firstLaunchKey = 'first_launch';

  // Premium features
  static const String premiumSubscriptionId = 'premium_monthly';
  static const String adFreeProductId = 'ad_free_forever';
  static const double premiumPrice = 1.99;
  static const double adFreePrice = 2.99;

  // Game pack themes
  static const List<String> availableThemes = [
    '1960s Cars',
    'Classic Movies',
    'Vintage Household Items',
    'Old TV Shows',
    'Retro Toys',
    'Historical Events',
    'Classic Music',
    'Vintage Fashion',
    'Old Advertisements',
    'Nostalgic Foods',
  ];

  // Default game packs (free content)
  static const List<String> freePackIds = [
    'classic_cars_easy',
    'vintage_toys_easy',
    'old_movies_easy',
  ];

  // Voice prompts
  static const List<String> memoryPrompts = [
    'Did you own one of these?',
    'Do you remember this?',
    'Does this bring back memories?',
    'What memories does this spark?',
    'Tell us about your experience with this!',
  ];

  // Achievement messages
  static const List<String> encouragementMessages = [
    'Well done!',
    'Excellent memory!',
    'Great job!',
    'Wonderful!',
    "You're doing fantastic!",
    'Keep it up!',
    'Marvelous!',
  ];

  // Error messages
  static const String networkErrorMessage =
      'Please check your internet connection and try again.';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String premiumRequiredMessage =
      'This content requires a premium subscription.';
  static const String adLoadErrorMessage =
      'Unable to load advertisement. Please try again.';

  // Accessibility labels
  static const String tileAccessibilityLabel = 'Memory game tile';
  static const String matchedTileLabel = 'Matched tile';
  static const String revealedTileLabel = 'Revealed tile';
  static const String hiddenTileLabel = 'Hidden tile';
}
