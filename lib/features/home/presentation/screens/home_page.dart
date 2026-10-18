import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/presentation/screens/game_page.dart';
import 'package:golden_moments/features/home/cubit/home_cubit.dart';
import 'package:golden_moments/features/home/cubit/home_state.dart';
import 'package:golden_moments/features/home/presentation/widgets/daily_packs_section.dart';
import 'package:golden_moments/features/home/presentation/widgets/favorites_section.dart';
import 'package:golden_moments/features/home/presentation/widgets/hidden_packs_section.dart';
import 'package:golden_moments/features/home/presentation/widgets/library_section.dart';
import 'package:golden_moments/features/home/presentation/widgets/pack_choice_not_saved.dart';
import 'package:golden_moments/features/home/presentation/widgets/setting_modal.dart';
import 'package:golden_moments/features/pack/presentation/screens/pack_page.dart';

/// Home page of the Memory Lane app
class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext parentContext) {
    return BlocProvider(
      create: (context) {
        final cubit = HomeCubit();
        unawaited(cubit.initialize());
        return cubit;
      },
      child: const HomeView(),
    );
  }
}

/// Home view widget
class HomeView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext parentContext) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        Widget body;
        switch (state.status) {
          case HomeStatus.initial:
          case HomeStatus.loading:
            body = const _LoadingView();
          case HomeStatus.error:
            body = _ErrorView(message: state.errorMessage);
          case HomeStatus.loaded:
            body = _LoadedView(state: state);
        }
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: gmToolbarHeight(context),
            // Opened from the gentle home this is one place among several, so
            // it is named for what it holds; on the web it is the whole app.
            title: GmTitle(
              Navigator.canPop(context) ? 'Picture packs' : 'Golden Moments',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  unawaited(SoundService().playTap());
                  unawaited(showSettingModal(context: parentContext));
                },
                tooltip: 'Settings',
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }
}

/// Loading state view
class _LoadingView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext parentContext) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: gmSpaceMd),
          Text(
            'Getting the picture packs ready…',
            style: Theme.of(parentContext).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Error state view
class _ErrorView extends StatelessWidget {
  const new({required this.message});

  final String? message;

  @override
  Widget build(BuildContext parentContext) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(parentContext).colorScheme.error,
            ),
            const SizedBox(height: gmSpaceMd),
            Text(
              'The picture library could not open',
              style: Theme.of(parentContext).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              message ??
                  'Your gentle activities still work. You can try again now.',
              style: Theme.of(parentContext).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceLg),
            GmPrimaryButton(
              label: 'Try again',
              onTap: () {
                unawaited(parentContext.read<HomeCubit>().initialize());
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Loaded state view.
///
/// Order: favorites first (easy to find again), then a few suggestions, the
/// topic library, and last the hidden packs with "Show again". Nothing starts
/// a pack except the person's own tap. Until the saved choices are known only
/// the topics are shown, so a hidden pack never appears, even briefly.
class _LoadedView extends StatelessWidget {
  const new({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext parentContext) {
    final cubit = parentContext.read<HomeCubit>();
    final prefs = state.packPreferences;
    final favorites = state.favoritePacks;
    final hidden = state.hiddenPacks;
    final ready = state.preferencesReady;
    final choices = state.choicesEnabled;
    final lastHidden = state.lastHiddenPack;

    void openPack(Pack pack) {
      Navigator.of(parentContext).push(
        MaterialPageRoute<void>(builder: (context) => GamePage(gamePack: pack)),
      );
    }

    void setFavorite(Pack pack, {required bool favorite}) =>
        unawaited(cubit.setFavorite(pack.id, favorite: favorite));
    void notForMe(Pack pack) => unawaited(cubit.hidePack(pack.id));

    // Everything is bundled, so there is nothing to pull-to-refresh; a
    // spinner that changes nothing would be motion without meaning.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(gmSpaceMd),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              _WelcomeSection(),
              if (state.preferencesSaveFailed) ...[
                const SizedBox(height: gmSpaceMd),
                const PackChoiceNotSaved(),
              ],
              if (state.preferencesUnreadable) ...[
                const SizedBox(height: gmSpaceMd),
                const PackChoicesUnreadable(),
              ],
              const SizedBox(height: gmSpaceLg),

              if (!ready) ...[
                const PackChoicesLoading(),
                const SizedBox(height: gmSpaceLg),
              ] else ...[
                if (lastHidden != null) ...[
                  HiddenNotice(
                    pack: lastHidden,
                    onShowAgain: () => unawaited(cubit.showPack(lastHidden.id)),
                  ),
                  const SizedBox(height: gmSpaceLg),
                ],
                if (favorites.isNotEmpty) ...[
                  FavoritesSection(
                    packs: favorites,
                    onPackTap: openPack,
                    onFavoriteChanged: setFavorite,
                    onNotForMe: notForMe,
                  ),
                  const SizedBox(height: gmSpaceLg),
                ],

                // Suggested packs section
                DailyPacksSection(
                  packs: state.suggestedPacks,
                  onPackTap: openPack,
                  // Never offered over a record that could not be read.
                  onFavoriteChanged: choices ? setFavorite : null,
                  onNotForMe: choices ? notForMe : null,
                  hiddenCount: hidden.length,
                  favoriteCount: favorites.length,
                  onShowOther: state.hasOtherSuggestions
                      ? cubit.showOtherSuggestions
                      : null,
                ),
                const SizedBox(height: gmSpaceLg),
              ],

              // Library section
              LibrarySection(
                categories: state.libraryPacks,
                eligiblePackCounts: ready ? state.eligiblePackCounts : null,
                onCategoryTap: (category) {
                  Navigator.of(parentContext).push(
                    MaterialPageRoute<void>(
                      builder: (context) => PackPage(
                        categoryId: category.id,
                        categoryName: category.name,
                        library: cubit,
                      ),
                    ),
                  );
                },
              ),

              if (ready && hidden.isNotEmpty) ...[
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

/// One plain sentence under the title: what this place holds and that it
/// works offline. No welcome banner: the person has already arrived.
class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    return Text(
      'Picture matching at your own pace. Every pack is included and works '
      'offline.',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
