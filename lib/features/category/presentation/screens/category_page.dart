import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/shared/widgets/category_card.dart';

/// Page to display all categories
class CategoryPage extends StatelessWidget {
  const new({required this.categories, this.onCategoryTap, super.key});

  final List<Category> categories;
  final void Function(Category category)? onCategoryTap;

  @override
  Widget build(BuildContext parentContext) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        unawaited(SoundService().playTap());
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('All categories')),
        body: categories.isEmpty
            ? _EmptyState()
            : ListView.separated(
                padding: _centeredPadding(parentContext),
                itemCount: categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: gmSpaceSm),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryCard(
                    category: category,
                    onTap: onCategoryTap == null
                        ? null
                        : () => onCategoryTap?.call(category),
                  );
                },
              ),
      ),
    );
  }
}

/// Keeps the list in one centered column no wider than
/// [gmContentMaxWidth]; extra width becomes margin.
EdgeInsets _centeredPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final side = width > gmContentMaxWidth + gmSpaceMd * 2
      ? (width - gmContentMaxWidth) / 2
      : gmSpaceMd;
  return EdgeInsets.symmetric(horizontal: side, vertical: gmSpaceMd);
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'No categories found',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'The picture library is empty in this version.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
