import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_lane/design_system.dart';
import 'package:memory_lane/features/download_manager/cubit/download_manager_cubit.dart';
import 'package:memory_lane/shared/widgets/download_progress_card.dart';

/// Download manager page for managing active downloads
class DownloadManagerPage extends StatelessWidget {
  const DownloadManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DownloadManagerCubit()..initialize(),
      child: const DownloadManagerView(),
    );
  }
}

/// Download manager view widget
class DownloadManagerView extends StatelessWidget {
  const DownloadManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.pause_circle_outline),
                onPressed: state.hasActiveDownloads
                    ? () => context.read<DownloadManagerCubit>().pauseAllDownloads()
                    : null,
                tooltip: 'Pause All Downloads',
              );
            },
          ),
          BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: state.hasCompletedDownloads
                    ? () => _showClearCompletedDialog(context)
                    : null,
                tooltip: 'Clear Completed',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
        builder: (context, state) {
          switch (state.status) {
            case DownloadManagerStatus.initial:
            case DownloadManagerStatus.loading:
              return const _LoadingView();
            case DownloadManagerStatus.error:
              return _ErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<DownloadManagerCubit>().initialize(),
              );
            case DownloadManagerStatus.loaded:
              return _LoadedView(state: state);
          }
        },
      ),
    );
  }

  void _showClearCompletedDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Downloads'),
        content: const Text(
          'This will remove all completed downloads from the list. '
          'Downloaded packs will remain cached.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DownloadManagerCubit>().clearCompletedDownloads();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
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
    required this.message,
    required this.onRetry,
  });

  final String message;
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
              message,
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

  final DownloadManagerState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasAnyDownloads) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<DownloadManagerCubit>().refreshDownloads(),
      child: CustomScrollView(
        slivers: [
          // Download statistics
          SliverToBoxAdapter(
            child: _DownloadStats(state: state),
          ),

          // Active downloads section
          if (state.activeDownloads.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Active Downloads (${state.activeDownloads.length})',
                icon: Icons.download,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final progress = state.activeDownloads[index];
                  return DownloadProgressCard(
                    progress: progress,
                    onCancel: () => context
                        .read<DownloadManagerCubit>()
                        .cancelDownload(progress.id),
                    onPause: () => context
                        .read<DownloadManagerCubit>()
                        .pauseDownload(progress.id),
                    onResume: () => context
                        .read<DownloadManagerCubit>()
                        .resumeDownload(progress.id),
                  );
                },
                childCount: state.activeDownloads.length,
              ),
            ),
          ],

          // Queued downloads section
          if (state.queuedDownloads.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Queued Downloads (${state.queuedDownloads.length})',
                icon: Icons.queue,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final progress = state.queuedDownloads[index];
                  return DownloadProgressCard(
                    progress: progress,
                    onCancel: () => context
                        .read<DownloadManagerCubit>()
                        .cancelDownload(progress.id),
                    showControls: false,
                  );
                },
                childCount: state.queuedDownloads.length,
              ),
            ),
          ],

          // Completed downloads section
          if (state.completedDownloads.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Completed Downloads (${state.completedDownloads.length})',
                icon: Icons.check_circle,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final progress = state.completedDownloads[index];
                  return DownloadProgressCard(
                    progress: progress,
                    showControls: false,
                  );
                },
                childCount: state.completedDownloads.length,
              ),
            ),
          ],

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: gmSpaceLg),
          ),
        ],
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
              'No Downloads',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'Start downloading packs to see them here',
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

/// Download statistics widget
class _DownloadStats extends StatelessWidget {
  const _DownloadStats({required this.state});

  final DownloadManagerState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(gmSpaceMd),
      padding: const EdgeInsets.all(gmSpaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(gmRadiusMd),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.download,
            label: 'Active',
            value: state.activeDownloads.length.toString(),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: gmSpaceLg),
          _StatItem(
            icon: Icons.queue,
            label: 'Queued',
            value: state.queuedDownloads.length.toString(),
            color: gmGold600,
          ),
          const SizedBox(width: gmSpaceLg),
          _StatItem(
            icon: Icons.check_circle,
            label: 'Completed',
            value: state.completedDownloads.length.toString(),
            color: gmGreen600,
          ),
        ],
      ),
    );
  }
}

/// Individual stat item widget
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: gmSpaceSm),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(gmSpaceMd, gmSpaceLg, gmSpaceMd, gmSpaceSm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: gmSpaceSm),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
