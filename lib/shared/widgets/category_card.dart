import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/pack/presentation/screens/pack_page.dart';
import 'package:golden_moments/shared/widgets/download_progress_card.dart';
import 'package:golden_moments/shared/widgets/pressable.dart';

/// Card widget for displaying a game pack
class CategoryCard extends StatelessWidget {
  const new({
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
    // A minimum height, not a fixed one, so the text can wrap at 200%.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            width: 100,
            height: 100,
            color: gmSurf200,
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    category.iconUrl,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.photo_outlined,
                      size: 40,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildBadges(theme),
                    ],
                  ),
                  Text(
                    category.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
          padding: const EdgeInsets.symmetric(
            horizontal: gmSpaceSm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(gmRadiusMd),
          ),
          child: Text(
            'Daily',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondary,
            ),
          ),
        ),
      );
    }

    if (showPremiumBadge) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: gmSpaceSm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(gmRadiusMd),
          ),
          child: Text(
            'Premium',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiary,
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
              padding: const EdgeInsets.only(bottom: gmSpaceXs),
              child: badge,
            ),
          )
          .toList(),
    );
  }
}
