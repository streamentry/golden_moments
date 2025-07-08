import 'package:flutter/material.dart';
import 'package:memory_lane/game/models/models.dart';
import 'package:memory_lane/shared/constants/app_constants.dart';
import 'package:memory_lane/shared/widgets/game_pack_card.dart';

/// Section displaying daily featured game packs
class DailyPacksSection extends StatelessWidget {
  const DailyPacksSection({
    super.key,
    required this.packs,
    required this.onPackTap,
  });

  final List<GamePack> packs;
  final void Function(GamePack pack) onPackTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.today,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              'Daily Packs',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Fresh memory challenges updated daily',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Daily packs grid
        if (packs.isEmpty)
          _EmptyState()
        else
          _PacksGrid(
            packs: packs,
            onPackTap: onPackTap,
          ),
      ],
    );
  }
}

/// Grid layout for displaying packs
class _PacksGrid extends StatelessWidget {
  const _PacksGrid({
    required this.packs,
    required this.onPackTap,
  });

  final List<GamePack> packs;
  final void Function(GamePack pack) onPackTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppConstants.smallPadding,
        mainAxisSpacing: AppConstants.smallPadding,
      ),
      itemCount: packs.length,
      itemBuilder: (context, index) {
        final pack = packs[index];
        return GamePackCard(
          pack: pack,
          onTap: () => onPackTap(pack),
          showDailyBadge: true,
        );
      },
    );
  }
}

/// Empty state when no daily packs are available
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'No daily packs available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Check back tomorrow for new content!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
