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
            Icon(Icons.today, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: gmSpaceSm),
            Flexible(
              child: Text(
                'Daily Packs',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: gmSpaceSm),
        Text(
          'Fresh memory challenges updated daily',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: gmSpaceMd),

        // Daily packs grid
        if (packs.isEmpty)
          _EmptyState()
        else
          _PacksGrid(packs: packs, onPackTap: onPackTap),
      ],
    );
  }
}

/// Grid layout for displaying packs
class _PacksGrid extends StatelessWidget {
  const _PacksGrid({required this.packs, required this.onPackTap});

  final List<Pack> packs;
  final void Function(Pack pack) onPackTap;

  @override
  Widget build(BuildContext parentContext) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 170).floor().clamp(1, 4);
        final cardWidth =
            (constraints.maxWidth - (columns - 1) * gmSpaceSm) / columns;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: PackCard.gridExtent(context, cardWidth),
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
            Icons.calendar_today_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: gmSpaceSm),
          Text(
            'No daily packs available',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: gmSpaceSm),
          Text(
            'Check back tomorrow for new content!',
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
