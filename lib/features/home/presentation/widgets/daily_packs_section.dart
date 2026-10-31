import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';
import 'package:golden_moments/shared/widgets/pack_grid.dart';

/// A few suggested packs (GM-026).
///
/// Suggestions come only from included packs that are not hidden, keep a
/// steady order and change only after the person's own choice. They never
/// start by themselves and are not described as new every day.
class DailyPacksSection extends StatelessWidget {
  const new({
    required this.packs,
    required this.onPackTap,
    this.onFavoriteChanged,
    this.onNotForMe,
    this.hiddenCount = 0,
    this.favoriteCount = 0,
    this.onShowOther,
    super.key,
  });

  final List<Pack> packs;
  final void Function(Pack pack) onPackTap;
  final void Function(Pack pack, {required bool favorite})? onFavoriteChanged;
  final void Function(Pack pack)? onNotForMe;

  /// How many packs are hidden, to explain why they are not suggested.
  final int hiddenCount;

  /// How many favorites are shown in their own group.
  final int favoriteCount;

  /// Shows other suggestions; null when there are no others.
  final VoidCallback? onShowOther;

  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    final favoriteChanged = onFavoriteChanged;
    final notForMe = onNotForMe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: gmSpaceSm),
            Flexible(
              child: Text(
                parentContext.l10n.librarySuggestedTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: gmSpaceSm),
        Text(
          parentContext.l10n.librarySuggestedBody,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (hiddenCount > 0) ...[
          const SizedBox(height: gmSpaceSm),
          Text(
            parentContext.l10n.librarySuggestedHiddenNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: gmSpaceMd),

        if (packs.isEmpty)
          _EmptyState(hiddenCount: hiddenCount, favoriteCount: favoriteCount)
        else
          PackGrid(
            packs: packs,
            cardBuilder: (context, pack) => PackCard(
              key: ValueKey('suggested-${pack.id}'),
              pack: pack,
              onTap: () => onPackTap(pack),
              onFavoriteChanged: favoriteChanged == null
                  ? null
                  : (favorite) => favoriteChanged(pack, favorite: favorite),
              onNotForMe: notForMe == null ? null : () => notForMe(pack),
            ),
          ),
        if (onShowOther != null) ...[
          const SizedBox(height: gmSpaceSm),
          TextButton.icon(
            onPressed: onShowOther,
            icon: const Icon(Icons.arrow_forward),
            label: Text(parentContext.l10n.librarySuggestOther),
          ),
        ],
      ],
    );
  }
}

/// Shown when nothing is left to suggest.
class _EmptyState extends StatelessWidget {
  const new({required this.hiddenCount, required this.favoriteCount});

  final int hiddenCount;
  final int favoriteCount;

  String _message(AppLocalizations l10n) {
    if (hiddenCount > 0) return l10n.librarySuggestedEmptyHidden;
    if (favoriteCount > 0) return l10n.librarySuggestedEmptyFavorites;
    return l10n.librarySuggestedEmptyNone;
  }

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
            Icons.lightbulb_outline,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: gmSpaceSm),
          Text(
            parentContext.l10n.librarySuggestedEmptyTitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: gmSpaceSm),
          Text(
            _message(parentContext.l10n),
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
