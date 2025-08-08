import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';

/// Section displaying daily featured game packs
class DailyPacksSection extends StatelessWidget {
  const DailyPacksSection({
    required this.packs,
    required this.onPackTap,
    super.key,
  });

  final List<Pack> packs;
  final void Function(Pack pack) onPackTap;

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

  final List<Pack> packs;
  final void Function(Pack pack) onPackTap;

  @override
  Widget build(BuildContext parentContext) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: gmSpaceSm,
        mainAxisSpacing: gmSpaceSm,
      ),
      itemCount: packs.length,
      itemBuilder: (context, index) {
        final pack = packs[index];
        return PackCard(
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
