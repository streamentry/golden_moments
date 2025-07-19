import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';

/// Grid widget for displaying pack categories
class PackCategoryGrid extends StatelessWidget {
  const PackCategoryGrid({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    // Add "All" category at the beginning
    final allCategories = ['All', ...categories];

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: gmSpaceMd),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: gmSpaceSm,
          mainAxisSpacing: gmSpaceSm,
        ),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isAll = category == 'All';
          final isSelected = isAll
              ? selectedCategory == null
              : selectedCategory == category;

          return PackCategoryCard(
            category: category,
            isSelected: isSelected,
            onTap: () {
              onCategorySelected(isAll ? null : category);
            },
          );
        },
      ),
    );
  }
}

/// Individual category card widget
class PackCategoryCard extends StatelessWidget {
  const PackCategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(gmRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(gmSpaceSm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(gmSpaceSm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                  borderRadius: BorderRadius.circular(gmRadiusMd),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  size: 24,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: gmSpaceSm),

              // Category name
              Text(
                category,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.grid_view;
      case 'animals':
        return Icons.pets;
      case 'nature':
        return Icons.nature;
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.flight;
      case 'vehicles':
        return Icons.directions_car;
      case 'sports':
        return Icons.sports_soccer;
      case 'music':
        return Icons.music_note;
      case 'art':
        return Icons.palette;
      case 'history':
        return Icons.history_edu;
      case 'science':
        return Icons.science;
      case 'technology':
        return Icons.computer;
      case 'fashion':
        return Icons.checkroom;
      case 'home':
        return Icons.home;
      case 'toys':
        return Icons.toys;
      case 'books':
        return Icons.menu_book;
      case 'movies':
        return Icons.movie;
      case 'vintage':
        return Icons.camera_alt;
      case 'classic':
        return Icons.star;
      case 'retro':
        return Icons.radio;
      default:
        return Icons.category;
    }
  }
}

/// Horizontal category chips widget
class PackCategoryChips extends StatelessWidget {
  const PackCategoryChips({
    super.key,
    required this.categories,
    this.selectedCategories = const [],
    required this.onCategoryToggled,
    this.multiSelect = false,
  });

  final List<String> categories;
  final List<String> selectedCategories;
  final ValueChanged<String> onCategoryToggled;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: gmSpaceMd),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategories.contains(category);

          return Padding(
            padding: const EdgeInsets.only(right: gmSpaceSm),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                onCategoryToggled(category);
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Category statistics widget
class CategoryStats extends StatelessWidget {
  const CategoryStats({
    super.key,
    required this.categories,
    required this.packCounts,
  });

  final List<String> categories;
  final Map<String, int> packCounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: gmSpaceSm),
        ...categories.map((category) {
          final count = packCounts[category] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: gmSpaceSm),
                    Text(
                      category,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(gmRadiusMd),
                  ),
                  child: Text(
                    count.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'animals':
        return Icons.pets;
      case 'nature':
        return Icons.nature;
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.flight;
      case 'vehicles':
        return Icons.directions_car;
      case 'sports':
        return Icons.sports_soccer;
      case 'music':
        return Icons.music_note;
      case 'art':
        return Icons.palette;
      case 'history':
        return Icons.history_edu;
      case 'science':
        return Icons.science;
      case 'technology':
        return Icons.computer;
      case 'fashion':
        return Icons.checkroom;
      case 'home':
        return Icons.home;
      case 'toys':
        return Icons.toys;
      case 'books':
        return Icons.menu_book;
      case 'movies':
        return Icons.movie;
      case 'vintage':
        return Icons.camera_alt;
      case 'classic':
        return Icons.star;
      case 'retro':
        return Icons.radio;
      default:
        return Icons.category;
    }
  }
}
