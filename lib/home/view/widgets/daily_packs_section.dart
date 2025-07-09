import 'package:flutter/material.dart';
import 'package:memory_lane/design_system.dart';
import 'package:memory_lane/game/models/models.dart';
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
            const SizedBox(width: gmSpaceSm),
            Text(
              'Daily Packs',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: gmSpaceSm),
        Text(
          'Fresh memory challenges updated daily',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: gmSpaceMd),

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
        crossAxisSpacing: gmSpaceSm,
        mainAxisSpacing: gmSpaceSm,
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
              Icons.calendar_today_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'No daily packs available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'Check back tomorrow for new content!',
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
