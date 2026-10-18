import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/category/presentation/screens/category_page.dart';
import 'package:golden_moments/features/home/data/interest_preferences.dart';
import 'package:golden_moments/shared/widgets/category_card.dart';

/// Section displaying the game library, with optional topic choices.
class LibrarySection extends StatefulWidget {
  const new({
    required this.categories,
    required this.onCategoryTap,
    this.interestStore = const InterestStore(),
    super.key,
  });

  final List<Category> categories;
  final void Function(Category category) onCategoryTap;
  final InterestStore interestStore;

  @override
  State<LibrarySection> createState() => _LibrarySectionState();
}

class _LibrarySectionState extends State<LibrarySection> {
  Set<String> _chosen = {};
  bool _saveFailed = false;

  /// Set once the person has chosen or cleared anything, so a slower load of
  /// the saved choice can never overwrite what they just did.
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final saved = await widget.interestStore.load();
    if (!mounted || _touched) return;
    // Only topics that still exist count; a stale choice is dropped.
    final known = {for (final category in widget.categories) category.id};
    final current = saved.intersection(known);
    if (current.isNotEmpty) setState(() => _chosen = current);
    if (current.length != saved.length) {
      unawaited(widget.interestStore.save(current));
    }
  }

  Future<void> _toggle(String id, {required bool selected}) async {
    _touched = true;
    final next = {..._chosen};
    if (selected) {
      next.add(id);
    } else {
      next.remove(id);
    }
    setState(() => _chosen = next);
    final saved = await widget.interestStore.save(next);
    if (mounted) setState(() => _saveFailed = !saved);
  }

  Future<void> _clear() async {
    _touched = true;
    setState(() => _chosen = {});
    final saved = await widget.interestStore.save({});
    if (mounted) setState(() => _saveFailed = !saved);
  }

  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    final categories = widget.categories;
    final shown = categoriesForInterests(categories, _chosen);
    final filtered = _chosen.isNotEmpty && shown.length != categories.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: gmSpaceSm,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.library_books,
                  size: 32,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: gmSpaceSm),
                Flexible(
                  child: Text(
                    'Library',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                unawaited(SoundService().playTap());
                Navigator.of(parentContext).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        CategoryPage(categories: widget.categories),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: gmSpaceSm),
        Text(
          'Explore our full collection of nostalgic memory games',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: gmSpaceMd),

        if (categories.length > 1) ...[
          Text(
            'Pick topics you enjoy (optional)',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: gmSpaceSm),
          Wrap(
            spacing: gmSpaceSm,
            runSpacing: gmSpaceSm,
            children: [
              for (final category in categories)
                FilterChip(
                  label: Text(category.name),
                  selected: _chosen.contains(category.id),
                  showCheckmark: true,
                  onSelected: (selected) =>
                      unawaited(_toggle(category.id, selected: selected)),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
            ],
          ),
          if (_chosen.isNotEmpty)
            TextButton(onPressed: _clear, child: const Text('Show all topics')),
          if (_saveFailed)
            Text(
              'Your choice could not be saved. It will apply until you close '
              'the app.',
              style: theme.textTheme.bodyMedium,
            ),
          const SizedBox(height: gmSpaceSm),
        ],

        // Library packs
        if (categories.isEmpty)
          _EmptyState()
        else
          _PacksList(
            categories: shown,
            showAll: filtered,
            onPackTap: widget.onCategoryTap,
          ),
      ],
    );
  }
}

/// List layout for library packs
class _PacksList extends StatelessWidget {
  const new({
    required this.categories,
    required this.onPackTap,
    this.showAll = false,
  });

  final List<Category> categories;
  final void Function(Category pack) onPackTap;

  /// When the person has chosen topics, show every chosen one.
  final bool showAll;

  @override
  Widget build(BuildContext parentContext) {
    // Show only first few packs in home view
    final displayCategories = showAll
        ? categories
        : categories.take(3).toList();

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
      width: double.infinity,
      padding: const EdgeInsets.all(gmSpaceLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(gmRadiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: gmSpaceSm),
          Text(
            'Library is empty',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: gmSpaceSm),
          Text(
            'New content will be added soon!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
