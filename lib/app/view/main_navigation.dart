import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/app/cubit/navigation_cubit.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/download_manager/presentation/screens/download_manager_page.dart';
import 'package:golden_moments/features/home/presentation/screens/home_page.dart';
import 'package:golden_moments/shared/widgets/offline_indicator.dart';

/// Main navigation wrapper with bottom navigation bar
class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: const MainNavigationView(),
    );
  }
}

/// Main navigation view widget
class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              // Connectivity banner
              const ConnectivityBanner(),

              // Main content
              Expanded(
                child: IndexedStack(
                  index: state.currentIndex,
                  children: const [
                    HomePage(),
                    DownloadManagerPage(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, state),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    NavigationState state,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1), // Fixed method call
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80, // Larger height for senior-friendly design
          padding: const EdgeInsets.symmetric(horizontal: gmSpaceMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.home,
                label: 'Home',
                isSelected: state.currentIndex == 0,
                onTap: () {
                  SoundService().playTap();
                  context.read<NavigationCubit>().setIndex(0);
                },
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.download,
                label: 'Download',
                isSelected: state.currentIndex == 1,
                onTap: () {
                  SoundService().playTap();
                  context.read<NavigationCubit>().setIndex(1);
                },
                badge: state.activeDownloadsCount > 0
                    ? state.activeDownloadsCount.toString()
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(gmRadiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: gmSpaceSm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 28, // Larger icons for seniors
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          badge,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onError,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 4),

              // Label
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12, // Larger text for seniors
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation item data class
class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Widget page;
  final String? badge;
}

/// Navigation items configuration
class NavigationConfig {
  static const List<NavigationItem> items = [
    NavigationItem(
      icon: Icons.home,
      label: 'Home',
      page: HomePage(),
    ),
    NavigationItem(
      icon: Icons.download,
      label: 'Download',
      page: DownloadManagerPage(),
    ),
  ];

  /// Get navigation item by index
  static NavigationItem getItem(int index) {
    if (index < 0 || index >= items.length) {
      return items[0]; // Default to first item
    }
    return items[index];
  }

  /// Get total number of navigation items
  static int get itemCount => items.length;

  /// Get index of item by label
  static int getIndexByLabel(String label) {
    for (var i = 0; i < items.length; i++) {
      if (items[i].label == label) {
        return i;
      }
    }
    return 0; // Default to first item
  }
}

/// Navigation accessibility helper
class NavigationAccessibility {
  /// Get semantic label for navigation item
  static String getSemanticLabel(NavigationItem item, bool isSelected) {
    final status = isSelected ? 'selected' : 'not selected';
    return '${item.label} tab, $status';
  }

  /// Get semantic hint for navigation item
  static String getSemanticHint(NavigationItem item) {
    switch (item.label) {
      case 'Home':
        return 'View your game daily packs and category';
      case 'Download':
        return 'Manage your packs';
      default:
        return 'Navigate to ${item.label}';
    }
  }
}
