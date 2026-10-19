import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/pack/presentation/screens/pack_page.dart';
import 'package:golden_moments/shared/widgets/download_progress_card.dart';
import 'package:golden_moments/shared/widgets/gm_mounted_picture.dart';
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

    // The whole card is one button. It opens at once: no artificial delay
    // for the ripple, so Reduce Motion users never wait (GM-015).
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Pressable(
        onPressed: () {
          if (onTap != null) {
            onTap?.call();
            return;
          }
          Navigator.of(parentContext).push(
            MaterialPageRoute<void>(
              builder: (context) => PackPage(
                categoryName: category.name,
                categoryId: category.id,
              ),
            ),
          );
        },
        // The button role annotates the tappable surface's own node, so a
        // screen reader finds one labelled button, not two (GM-014).
        child: Semantics(button: true, child: _buildLayout(theme)),
      ),
    );
  }

  Widget _buildLayout(ThemeData theme) {
    // A minimum height, not a fixed one, so the text can wrap at 200%.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 96 + gmSpaceSm * 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GmMountedPicture(asset: category.iconUrl, width: 96),
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
                          // Wraps at any text size; never truncated.
                          style: theme.textTheme.titleMedium,
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
