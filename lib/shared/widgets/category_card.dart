import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/pack/presentation/screens/pack_page.dart';
import 'package:golden_moments/shared/widgets/download_progress_card.dart';
import 'package:golden_moments/shared/widgets/pressable.dart';

/// Card widget for displaying a game pack
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.category,
    this.onTap,
    this.showDailyBadge = false,
    this.showPremiumBadge = false,
    this.downloadStatus,
    this.downloadProgress,
    super.key,
  });

  final Category category;
  final VoidCallback? onTap;
  final bool showDailyBadge;
  final bool showPremiumBadge;
  final PackDownloadStatus? downloadStatus;
  final double? downloadProgress;

  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Pressable(
        onPressed: () async {
          // Wait for ripple animation before calling onPressed
          await Future<void>.delayed(const Duration(milliseconds: 300));
          if (!parentContext.mounted) return;
          if (onTap == null) {
            await Navigator.of(parentContext).push(
              MaterialPageRoute<void>(
                builder: (context) => PackPage(
                  categoryName: category.name,
                  categoryId: category.id,
                ),
              ),
            );
          } else {
            onTap?.call();
          }
        },
        child: _buildLayout(theme),
      ),
    );
  }

  Widget _buildLayout(ThemeData theme) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(gmRadiusMd),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    category.iconUrl,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                ),
                // Completion indicator
                // if (category.isCompleted)
                //   Positioned(
                //     top: gmSpaceSm,
                //     right: gmSpaceSm,
                //     child: Container(
                //       padding: const EdgeInsets.all(2),
                //       decoration: BoxDecoration(
                //         color: theme.colorScheme.primary,
                //         shape: BoxShape.circle,
                //       ),
                //       child: Icon(
                //         Icons.check,
                //         size: 12,
                //         color: theme.colorScheme.onPrimary,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(gmSpaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildBadges(theme),
                    ],
                  ),
                  Text(
                    category.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges(ThemeData theme) {
    final badges = <Widget>[];

    if (showDailyBadge) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'DAILY',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (showPremiumBadge) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'PREMIUM',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: badges
          .map(
            (badge) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: badge,
            ),
          )
          .toList(),
    );
  }
}
