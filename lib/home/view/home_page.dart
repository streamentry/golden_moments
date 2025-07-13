import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/game/view/game_page.dart';
import 'package:golden_moments/home/cubit/home_cubit.dart';
import 'package:golden_moments/home/cubit/home_state.dart';
import 'package:golden_moments/home/view/widgets/daily_packs_section.dart';
import 'package:golden_moments/home/view/widgets/library_section.dart';

/// Home page of the Memory Lane app
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..initialize(),
      child: const HomeView(),
    );
  }
}

/// Home view widget
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golden Moments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute<void>(
              //     builder: (context) => DownloadManagerPage(),
              //   ),
              // );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          switch (state.status) {
            case HomeStatus.initial:
            case HomeStatus.loading:
              return const _LoadingView();
            case HomeStatus.error:
              return _ErrorView(message: state.errorMessage);
            case HomeStatus.loaded:
              return _LoadedView(state: state);
          }
        },
      ),
    );
  }
}

/// Loading state view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: gmSpaceMd),
          Text(
            'Loading your memory games...',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

/// Error state view
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: gmSpaceMd),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              message ?? 'Something went wrong. Please try again.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceLg),
            GmPrimaryButton(
              label: 'Try Again',
              onTap: () {
                context.read<HomeCubit>().initialize();
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
  const _LoadedView({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      // onRefresh: () => context.read<HomeCubit>().refreshDailyPacks(),
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(gmSpaceMd),
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
                Navigator.of(context).push(
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
              userPreferences: state.userPreferences,
              onPackTap: (pack) {
                // if (pack.isPremium && !state.userPreferences.isPremiumUser) {
                //   _showPremiumDialog(context);
                // } else
                // {
                //   Navigator.of(context).push(
                //     MaterialPageRoute<void>(
                //       builder: (context) => GamePage(gamePack: pack),
                //     ),
                //   );
                // }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Content'),
        content: const Text('This content requires a premium subscription.'),
        actions: [
          GmOutlineButton(
            label: 'Cancel',
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: gmSpaceSm),
          GmPrimaryButton(
            label: 'Upgrade',
            onTap: () {
              Navigator.of(context).pop();
              // Navigate to premium purchase would go here
            },
          ),
        ],
      ),
    );
  }
}

/// Welcome section widget
class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Golden Moments!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'Take a nostalgic journey through the past with our memory matching games. Choose from daily featured packs or explore our full library.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
