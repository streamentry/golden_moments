import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/download_manager.dart';

/// Cubit for managing main navigation state
class NavigationCubit extends Cubit<NavigationState> {
  new() : super(const NavigationState()) {
    _initialize();
  }

  final DownloadManager _downloadManager = DownloadManager();
  StreamSubscription<MapEntry<String, PackStatus>>? _downloadSubscription;

  /// Initialize navigation cubit
  void _initialize() {
    _downloadSubscription = _downloadManager.onStatusChanged.listen((_) {
      unawaited(_updateDownloadCount());
    });
    // Note: Download manager integration simplified for local JSON approach
    // Subscribe to download progress to update badge count
    // _downloadSubscription = _downloadManager.progressStream.listen(
    //   (progress) {
    //     _updateDownloadCount();
    //   },
    //     // Handle download stream errors gracefully
    //   },
    // );

    // Initial download count update
    unawaited(_updateDownloadCount());
  }

  /// Set current navigation index
  void setIndex(int index) {
    if (index >= 0 && index < 2) {
      emit(state.copyWith(currentIndex: index));
    }
  }

  /// Navigate to Library tab
  void goToLibrary() {
    setIndex(0);
  }

  /// Navigate to Discover tab
  void goToDiscover() {
    setIndex(1);
  }

  /// Navigate to Downloads tab
  void goToDownloads() {
    setIndex(1);
  }

  /// Update active downloads count for badge
  Future<void> _updateDownloadCount() async {
    try {
      // In a real implementation, you would get this from the download manager
      // For now, we'll use a placeholder
      final activeCount = _downloadManager
          .getPacksStatus()
          .values
          .where((status) => status == PackStatus.downloading)
          .length;

      if (activeCount != state.activeDownloadsCount) {
        emit(state.copyWith(activeDownloadsCount: activeCount));
      }
    } on Object {
      // Handle error gracefully - don't update count if we can't get it
    }
  }

  /// Handle deep link navigation
  void handleDeepLink(String route) {
    switch (route) {
      case '/library':
        goToLibrary();
      case '/discover':
        goToDiscover();
      case '/downloads':
        goToDownloads();
      default:
        goToLibrary(); // Default to library
    }
  }

  /// Get current tab name
  String get currentTabName {
    switch (state.currentIndex) {
      case 0:
        return 'Library';
      case 1:
        return 'Downloads';
      default:
        return 'Library';
    }
  }

  /// Check if current tab is Library
  bool get isLibraryTab => state.currentIndex == 0;

  /// Check if current tab is Discover
  bool get isDiscoverTab => state.currentIndex == 1;

  /// Check if current tab is Downloads
  bool get isDownloadsTab => state.currentIndex == 1;

  /// Handle back button press
  bool handleBackPress() {
    // If not on Library tab, go to Library
    if (!isLibraryTab) {
      goToLibrary();
      return false; // Don't exit app
    }
    return true; // Allow app exit
  }

  /// Reset to default tab
  void reset() {
    emit(const NavigationState());
  }

  @override
  Future<void> close() {
    unawaited(_downloadSubscription?.cancel());
    return super.close();
  }
}

/// Navigation state
class NavigationState extends Equatable {
  const new({
    this.currentIndex = 0,
    this.activeDownloadsCount = 0,
    this.hasUnreadNotifications = false,
  });

  final int currentIndex;
  final int activeDownloadsCount;
  final bool hasUnreadNotifications;

  /// Check if downloads tab should show badge
  bool get shouldShowDownloadsBadge => activeDownloadsCount > 0;

  /// Get downloads badge text
  String get downloadsBadgeText {
    if (activeDownloadsCount > 99) return '99+';
    return activeDownloadsCount.toString();
  }

  NavigationState copyWith({
    int? currentIndex,
    int? activeDownloadsCount,
    bool? hasUnreadNotifications,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      activeDownloadsCount: activeDownloadsCount ?? this.activeDownloadsCount,
      hasUnreadNotifications:
          hasUnreadNotifications ?? this.hasUnreadNotifications,
    );
  }

  @override
  List<Object?> get props => [
    currentIndex,
    activeDownloadsCount,
    hasUnreadNotifications,
  ];
}

/// Navigation analytics helper
class NavigationAnalytics {
  /// Track tab selection
  static void trackTabSelected(String tabName) {
    // In a real app, you would send this to your analytics service
    // For now, we'll just log it
    debugPrint('Navigation: Selected tab $tabName');
  }

  /// Track deep link navigation
  static void trackDeepLink(String route) {
    debugPrint('Navigation: Deep link to $route');
  }

  /// Track back button usage
  static void trackBackButton(String fromTab) {
    debugPrint('Navigation: Back button from $fromTab');
  }
}

/// Navigation preferences
class NavigationPreferences {
  /// Default tab index
  static const int defaultTabIndex = 0;

  /// Whether to show badges
  static const bool showBadges = true;

  /// Whether to animate tab transitions
  static const bool animateTransitions = true;

  /// Tab switch animation duration
  static const Duration animationDuration = Duration(milliseconds: 200);

  /// Whether to remember last selected tab
  static const bool rememberLastTab = false;

  /// Maximum badge count to display
  static const int maxBadgeCount = 99;
}

/// Navigation constants
class NavigationConstants {
  /// Tab indices
  static const int libraryTabIndex = 0;
  static const int discoverTabIndex = 1;
  static const int downloadsTabIndex = 2;

  /// Tab names
  static const String libraryTabName = 'Library';
  static const String discoverTabName = 'Discover';
  static const String downloadsTabName = 'Downloads';

  /// Deep link routes
  static const String libraryRoute = '/library';
  static const String discoverRoute = '/discover';
  static const String downloadsRoute = '/downloads';

  /// Get tab name by index
  static String getTabName(int index) {
    switch (index) {
      case libraryTabIndex:
        return libraryTabName;
      case discoverTabIndex:
        return discoverTabName;
      case downloadsTabIndex:
        return downloadsTabName;
      default:
        return libraryTabName;
    }
  }

  /// Get tab index by name
  static int getTabIndex(String name) {
    switch (name.toLowerCase()) {
      case 'library':
        return libraryTabIndex;
      case 'discover':
        return discoverTabIndex;
      case 'downloads':
        return downloadsTabIndex;
      default:
        return libraryTabIndex;
    }
  }

  /// Validate tab index
  static bool isValidTabIndex(int index) {
    return index >= 0 && index <= 2;
  }
}
