import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_lane/home/cubit/home_cubit.dart';
import 'package:memory_lane/home/cubit/home_state.dart';
import 'package:memory_lane/home/view/widgets/daily_packs_section.dart';
import 'package:memory_lane/home/view/widgets/library_section.dart';
import 'package:memory_lane/shared/constants/app_constants.dart';

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
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
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
          SizedBox(height: AppConstants.defaultPadding),
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
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              message ?? AppConstants.genericErrorMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton(
              onPressed: () {
                context.read<HomeCubit>().initialize();
              },
              child: const Text('Try Again'),
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
      onRefresh: () => context.read<HomeCubit>().refreshDailyPacks(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            _WelcomeSection(),
            const SizedBox(height: AppConstants.largePadding),
            
            // Daily packs section
            DailyPacksSection(
              packs: state.dailyPacks,
              onPackTap: (pack) {
                // TODO: Navigate to game
                _showPackDialog(context, pack.title);
              },
            ),
            const SizedBox(height: AppConstants.largePadding),
            
            // Library section
            LibrarySection(
              packs: state.libraryPacks,
              userPreferences: state.userPreferences,
              onPackTap: (pack) {
                // TODO: Navigate to game or show premium dialog
                if (pack.isPremium && !state.userPreferences.isPremiumUser) {
                  _showPremiumDialog(context);
                } else {
                  _showPackDialog(context, pack.title);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPackDialog(BuildContext context, String packTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Starting $packTitle'),
        content: const Text('Game will start here!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Content'),
        content: const Text(AppConstants.premiumRequiredMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to premium purchase
            },
            child: const Text('Upgrade'),
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
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Memory Lane!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
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
