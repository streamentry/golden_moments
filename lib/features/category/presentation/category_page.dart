import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/shared/widgets/category_card.dart';

/// Page to display all categories
class CategoryPage extends StatelessWidget {
  const CategoryPage({
    required this.categories,
    this.onCategoryTap,
    super.key,
  });

  final List<Category> categories;
  final void Function(Category category)? onCategoryTap;

  @override
  Widget build(BuildContext parentContext) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        SoundService().playTap();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Categories'),
        ),
        body: categories.isEmpty
            ? _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(gmSpaceMd),
                itemCount: categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: gmSpaceSm),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryCard(
                    category: category,
                    onTap: onCategoryTap == null
                        ? null
                        : () => {onCategoryTap?.call(category)},
                    // showPremiumBadge: category.isPremium && !userPreferences.isPremiumUser,
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withAlpha(128),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'No categories found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(180),
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'Please check back later for more categories!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
