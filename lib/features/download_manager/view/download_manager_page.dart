import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/download_manager/cubit/downloaded_packs_cubit.dart';
import 'package:golden_moments/features/download_manager/cubit/downloaded_packs_state.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';

/// Download manager page for managing active downloads
class DownloadManagerPage extends StatelessWidget {
  const DownloadManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DownloadedPacksCubit()..initialize(),
      child: const DownloadManagerView(),
    );
  }
}

/// Download manager view widget
class DownloadManagerView extends StatelessWidget {
  const DownloadManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadedPacksCubit, DownloadedPacksState>(
      builder: (context, state) {
        Widget body;
        switch (state.status) {
          case DownloadedPacksPageStatus.initial:
          case DownloadedPacksPageStatus.loading:
            body = const _LoadingView();
          case DownloadedPacksPageStatus.error:
            body = _ErrorView(
              onRetry: () => context.read<DownloadedPacksCubit>().initialize(),
            );
          case DownloadedPacksPageStatus.loaded:
            body = _LoadedView(state: state);
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Downloaded Packs'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Trigger the cubit to reload data
              await context.read<DownloadedPacksCubit>().initialize();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: body,
            ),
          ),
        );
      },
    );
  }
}

/// Loading state view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: gmSpaceMd),
          Text(
            'Loading downloads...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state view
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: gmSpaceMd),
            Text(
              'Download Manager Error',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'An error occurred while loading downloads.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceLg),
            GmPrimaryButton(
              label: 'Try Again',
              onTap: onRetry,
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

  final DownloadedPacksState state;

  @override
  Widget build(BuildContext context) {
    if (state.downloadedPacks.isEmpty) {
      return const _EmptyView();
    }

    return Padding(
      padding: const EdgeInsetsGeometry.all(gmSpaceSm),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: gmSpaceSm,
          mainAxisSpacing: gmSpaceSm,
        ),
        itemCount: state.downloadedPacks.length,
        itemBuilder: (context, index) {
          final pack = state.downloadedPacks[index];
          return PackCard(
            pack: pack,
          );
        },
      ),
    );
  }
}

/// Empty state view
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_done,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: gmSpaceMd),
            Text(
              'No Downloaded Packs',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'Download some packs to see them here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
