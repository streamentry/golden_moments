import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/presentation/screens/game_page.dart';
import 'package:golden_moments/features/home/cubit/home_cubit.dart';
import 'package:golden_moments/features/home/cubit/home_state.dart';
import 'package:golden_moments/features/home/presentation/widgets/daily_packs_section.dart';
import 'package:golden_moments/features/home/presentation/widgets/library_section.dart';
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
            title: const Text('Golden Moments'),
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
            'Loading your memory games...',
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

/// Loaded state view
class _LoadedView extends StatelessWidget {
  const new({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext parentContext) {
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
              const SizedBox(height: gmSpaceLg),

              // Daily packs section
              DailyPacksSection(
                packs: state.dailyPacks,
                onPackTap: (pack) {
                  Navigator.of(parentContext).push(
                    MaterialPageRoute<void>(
                      builder: (context) => GamePage(gamePack: pack),
                    ),
                  );
                },
              ),
              const SizedBox(height: gmSpaceLg),

              // Library section
              LibrarySection(
                categories: state.libraryPacks,
                onCategoryTap: (category) {
                  Navigator.of(parentContext).push(
                    MaterialPageRoute<void>(
                      builder: (context) => PackPage(
                        categoryId: category.id,
                        categoryName: category.name,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Welcome section widget
class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Golden Moments',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'Picture matching games to enjoy at your own pace. Choose '
              "one of today's packs or explore the full library. Every "
              'pack is included and works offline.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
