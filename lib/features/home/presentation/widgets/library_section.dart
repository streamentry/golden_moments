import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/category/presentation/screens/category_page.dart';
import 'package:golden_moments/shared/widgets/category_card.dart';

/// Section displaying the game library
class LibrarySection extends StatelessWidget {
  const LibrarySection({
    required this.categories,
    required this.onCategoryTap,
    super.key,
  });

  final List<Category> categories;
  final void Function(Category category) onCategoryTap;

  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.library_books,
              size: 32,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: gmSpaceSm),
            Text(
              'Library',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                FirebaseAnalytics.instance.logScreenView(
                  screenName: 'Category',
                );
                SoundService().playTap();
                Navigator.of(parentContext).push(
                  MaterialPageRoute<void>(
                    builder: (context) => CategoryPage(
                      categories: categories,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: gmSpaceSm),
        Text(
          'Explore our full collection of nostalgic memory games',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: gmSpaceMd),

        // Library packs
        if (categories.isEmpty)
          _EmptyState()
        else
          _PacksList(
            categories: categories,
            onPackTap: onCategoryTap,
          ),
      ],
    );
  }
}

/// List layout for library packs
class _PacksList extends StatelessWidget {
  const _PacksList({
    required this.categories,
    required this.onPackTap,
  });

  final List<Category> categories;
  final void Function(Category pack) onPackTap;

  @override
  Widget build(BuildContext parentContext) {
    // Show only first few packs in home view
    final displayCategories = categories.take(3).toList();

    return Column(
      children: displayCategories.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: gmSpaceSm),
          child: CategoryCard(
            category: category,
            onTap: () => onPackTap(category),
            // showPremiumBadge:
            //     category.isPremium && !userPreferences.isPremiumUser,
          ),
        );
      }).toList(),
    );
  }
}

/// Empty state when no library packs are available
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(gmRadiusMd),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'Library is empty',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'New content will be added soon!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
