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
                  children: const [HomePage(), DownloadManagerPage()],
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          // A minimum, not a fixed height, so 200% text never overflows.
          constraints: const BoxConstraints(
            minHeight: gmTargetHero + gmSpaceMd,
          ),
          child: Padding(
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
    final scheme = theme.colorScheme;
    final foreground = isSelected ? scheme.onSurface : scheme.onSurfaceVariant;

    return Expanded(
      child: MergeSemantics(
        child: Semantics(
          button: true,
          selected: isSelected,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(gmRadiusMd),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: gmTargetMin),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: gmSpaceSm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with badge. The selected tab also gets an
                    // indicator pill, so selection is not shown by color
                    // alone.
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        DecoratedBox(
                          decoration: ShapeDecoration(
                            color: isSelected
                                ? scheme.primaryContainer
                                : Colors.transparent,
                            shape: const StadiumBorder(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: gmSpaceMd,
                              vertical: gmSpaceXs,
                            ),
                            child: Icon(
                              icon,
                              size: 28,
                              color: isSelected
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Positioned(
                            right: -gmSpaceXs,
                            top: -gmSpaceSm,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: gmSpaceXs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.error,
                                borderRadius: BorderRadius.circular(
                                  gmTargetMin,
                                ),
                                border: Border.all(
                                  color: scheme.surface,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              child: Text(
                                badge,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onError,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: gmSpaceXs),

                    // Label, always visible
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
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
    NavigationItem(icon: Icons.home, label: 'Home', page: HomePage()),
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
  static String getSemanticLabel(
    NavigationItem item, {
    required bool isSelected,
  }) {
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
