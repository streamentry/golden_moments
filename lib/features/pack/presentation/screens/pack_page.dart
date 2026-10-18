import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/home/cubit/home_cubit.dart';
import 'package:golden_moments/features/home/cubit/home_state.dart';
import 'package:golden_moments/features/home/presentation/widgets/hidden_packs_section.dart';
import 'package:golden_moments/features/home/presentation/widgets/pack_choice_not_saved.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';
import 'package:golden_moments/shared/widgets/pack_grid.dart';

/// Page to display all packs for a given category.
///
/// Favorites come first and packs marked "Not for me" are listed separately
/// with "Show again", so hiding is visible and reversible here too.
class PackPage extends StatelessWidget {
  const new({
    required this.categoryId,
    required this.categoryName,
    this.onPackTap,
    this.library,
    super.key,
  });

  final String categoryName;
  final String categoryId;
  final void Function(Pack pack)? onPackTap;

  /// The home library, so choices made here show up there at once. Without
  /// it the page loads its own copy of the same locally saved choices.
  final HomeCubit? library;

  @override
  Widget build(BuildContext context) {
    final view = _PackView(
      categoryId: categoryId,
      categoryName: categoryName,
      onPackTap: onPackTap,
    );
    final shared = library;
    if (shared != null) return BlocProvider.value(value: shared, child: view);
    return BlocProvider(
      create: (_) {
        final cubit = HomeCubit();
        unawaited(cubit.initialize());
        return cubit;
      },
      child: view,
    );
  }
}

class _PackView extends StatelessWidget {
  const new({
    required this.categoryId,
    required this.categoryName,
    required this.onPackTap,
  });

  final String categoryName;
  final String categoryId;
  final void Function(Pack pack)? onPackTap;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        unawaited(SoundService().playTap());
      },
      child: Scaffold(
        appBar: AppBar(title: Text(categoryName)),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.error) {
              return _LoadError(
                onRetry: () =>
                    unawaited(context.read<HomeCubit>().initialize()),
              );
            }
            if (state.status != HomeStatus.loaded) {
              return const Center(child: CircularProgressIndicator());
            }
            final packs = state.browsablePacksIn(categoryId);
            final hidden = state.hiddenPacksIn(categoryId);
            if (packs.isEmpty && hidden.isEmpty) return _EmptyState();
            return _buildList(context, state, packs, hidden);
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    HomeState state,
    List<Pack> packs,
    List<Pack> hidden,
  ) {
    final cubit = context.read<HomeCubit>();
    final prefs = state.packPreferences;
    final tap = onPackTap;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(gmSpaceMd),
      child: Center(
        // One centered column no wider than gmContentMaxWidth.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.preferencesSaveFailed) ...[
                const PackChoiceNotSaved(),
                const SizedBox(height: gmSpaceMd),
              ],
              if (packs.isEmpty)
                Text(
                  'Every pack in this topic is marked Not for me. Show one '
                  'again below.',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              else
                PackGrid(
                  packs: packs,
                  cardBuilder: (context, pack) => PackCard(
                    key: ValueKey('pack-${pack.id}'),
                    pack: pack,
                    onTap: tap == null ? null : () => tap(pack),
                    isFavorite: prefs.isFavorite(pack.id),
                    // Offered only once the saved choices are known.
                    onFavoriteChanged: state.preferencesReady
                        ? (favorite) => unawaited(
                            cubit.setFavorite(pack.id, favorite: favorite),
                          )
                        : null,
                    onNotForMe: state.preferencesReady
                        ? () => unawaited(cubit.hidePack(pack.id))
                        : null,
                  ),
                ),
              if (hidden.isNotEmpty) ...[
                const SizedBox(height: gmSpaceXl),
                HiddenPacksSection(
                  packs: hidden,
                  favoriteIds: prefs.favorites,
                  onShowAgain: (pack) => unawaited(cubit.showPack(pack.id)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const new({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'These packs could not be opened.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
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
              Icons.extension_off,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'No packs found',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'There are no packs in this category yet.',
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
