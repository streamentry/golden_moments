import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/download_progress.dart';
import 'package:golden_moments/design_system.dart';

/// Card widget displaying download progress for a pack
class DownloadProgressCard extends StatelessWidget {
  const DownloadProgressCard({
    required this.progress,
    super.key,
    this.onCancel,
    this.onPause,
    this.onResume,
    this.showControls = true,
  });

  final DownloadProgress progress;
  final VoidCallback? onCancel;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final bool showControls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: gmSpaceMd,
        vertical: gmSpaceSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with pack info and status
            Row(
              children: [
                // Status icon
                Container(
                  padding: const EdgeInsets.all(gmSpaceSm),
                  decoration: BoxDecoration(
                    color: _getStatusColor(theme).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(gmRadiusMd),
                  ),
                  child: Text(
                    progress.statusIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: gmSpaceMd),

                // Pack info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pack: ${progress.packId}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        progress.statusText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getStatusColor(theme),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Controls
                if (showControls) _buildControls(theme),
              ],
            ),

            const SizedBox(height: gmSpaceMd),

            // Progress details
            if (progress.isActive) ...[
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress.progressPercentage,
                      backgroundColor: theme.colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(theme),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: gmSpaceMd),
                  Text(
                    '${progress.progressPercent}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(theme),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: gmSpaceSm),

              // Progress stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progress.progressText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  if (progress.speedText.isNotEmpty)
                    Text(
                      progress.speedText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                ],
              ),

              if (progress.etaText.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'ETA: ${progress.etaText}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],

            // Error message
            if (progress.isFailed && progress.error != null) ...[
              const SizedBox(height: gmSpaceSm),
              Container(
                padding: const EdgeInsets.all(gmSpaceSm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(gmRadiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: gmSpaceSm),
                    Expanded(
                      child: Text(
                        progress.error!.userMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (progress.isActive) ...[
          // Pause button
          IconButton(
            onPressed: onPause,
            icon: const Icon(Icons.pause),
            tooltip: 'Pause Download',
            iconSize: 20,
          ),
        ] else if (progress.status == DownloadProgressStatus.failed) ...[
          // Retry button
          IconButton(
            onPressed: onResume,
            icon: const Icon(Icons.refresh),
            tooltip: 'Retry Download',
            iconSize: 20,
          ),
        ],

        // Cancel button
        IconButton(
          onPressed: onCancel,
          icon: const Icon(Icons.close),
          tooltip: 'Cancel Download',
          iconSize: 20,
        ),
      ],
    );
  }

  Color _getStatusColor(ThemeData theme) {
    switch (progress.status) {
      case DownloadProgressStatus.downloading:
        return theme.colorScheme.primary;
      case DownloadProgressStatus.completed:
        return gmGreen600;
      case DownloadProgressStatus.failed:
        return theme.colorScheme.error;
      case DownloadProgressStatus.cancelled:
        return theme.colorScheme.outline;
      case DownloadProgressStatus.paused:
        throw UnimplementedError();
    }
  }
}

/// Compact download status badge for pack cards
class DownloadStatusBadge extends StatelessWidget {
  const DownloadStatusBadge({
    required this.status,
    super.key,
    this.progress,
    this.size = DownloadBadgeSize.normal,
  });

  final PackDownloadStatus status;
  final double? progress;
  final DownloadBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmall = size == DownloadBadgeSize.small;

    return Container(
      padding: EdgeInsets.all(isSmall ? 4 : 6),
      decoration: BoxDecoration(
        color: _getStatusColor(theme),
        borderRadius: BorderRadius.circular(isSmall ? 4 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: isSmall ? 12 : 16,
            color: _getIconColor(theme),
          ),
          if (!isSmall && _getStatusText().isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              _getStatusText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getIconColor(theme),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case PackDownloadStatus.available:
        return Icons.cloud_download_outlined;
      case PackDownloadStatus.downloading:
        return Icons.download;
      case PackDownloadStatus.cached:
        return Icons.offline_pin;
      case PackDownloadStatus.expired:
        return Icons.refresh;
      case PackDownloadStatus.failed:
        return Icons.error_outline;
    }
  }

  String _getStatusText() {
    switch (status) {
      case PackDownloadStatus.available:
        return 'DOWNLOAD';
      case PackDownloadStatus.downloading:
        return progress != null
            ? '${(progress! * 100).round()}%'
            : 'DOWNLOADING';
      case PackDownloadStatus.cached:
        return 'CACHED';
      case PackDownloadStatus.expired:
        return 'UPDATE';
      case PackDownloadStatus.failed:
        return 'RETRY';
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (status) {
      case PackDownloadStatus.available:
        return theme.colorScheme.primary;
      case PackDownloadStatus.downloading:
        return gmGold600;
      case PackDownloadStatus.cached:
        return gmGreen600;
      case PackDownloadStatus.expired:
        return gmOrange600;
      case PackDownloadStatus.failed:
        return theme.colorScheme.error;
    }
  }

  Color _getIconColor(ThemeData theme) {
    switch (status) {
      case PackDownloadStatus.available:
      case PackDownloadStatus.downloading:
      case PackDownloadStatus.cached:
      case PackDownloadStatus.expired:
        return Colors.white;
      case PackDownloadStatus.failed:
        return theme.colorScheme.onError;
    }
  }
}

/// Pack download status enumeration
enum PackDownloadStatus {
  available, // Available for download
  downloading, // Currently downloading
  cached, // Downloaded and cached
  expired, // Cache expired, needs update
  failed, // Download failed
}

/// Download badge size options
enum DownloadBadgeSize { small, normal }
