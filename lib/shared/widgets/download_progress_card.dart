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
                  // A Material icon instead of the model's emoji glyph.
                  child: Icon(
                    _getStatusIcon(),
                    size: 28,
                    color: _getStatusColor(theme),
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
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(theme),
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
                      backgroundColor: gmSurf200,
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
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: gmSpaceMd,
                children: [
                  Text(
                    progress.progressText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (progress.speedText.isNotEmpty)
                    Text(
                      progress.speedText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),

              if (progress.etaText.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Time left: ${progress.etaText}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
                      size: 24,
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
            tooltip: 'Pause download',
          ),
        ] else if (progress.status == DownloadProgressStatus.failed) ...[
          // Retry button
          IconButton(
            onPressed: onResume,
            icon: const Icon(Icons.refresh),
            tooltip: 'Try again',
          ),
        ],

        // Cancel button
        IconButton(
          onPressed: onCancel,
          icon: const Icon(Icons.close),
          tooltip: 'Cancel download',
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
      case DownloadProgressStatus.paused:
        // Driftwood (outline) is below 4.5:1 for text; use Walnut.
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  IconData _getStatusIcon() {
    switch (progress.status) {
      case DownloadProgressStatus.downloading:
        return Icons.download;
      case DownloadProgressStatus.completed:
        return Icons.download_done;
      case DownloadProgressStatus.failed:
        return Icons.error_outline;
      case DownloadProgressStatus.cancelled:
        return Icons.cancel_outlined;
      case DownloadProgressStatus.paused:
        return Icons.pause_circle_outline;
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

    // Status is always an icon, a word and a color (DESIGN.md › Status
    // badges); the small size only tightens the padding and icon.
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? gmSpaceXs : gmSpaceSm,
        vertical: isSmall ? 2 : gmSpaceXs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(theme),
        borderRadius: BorderRadius.circular(gmRadiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: isSmall ? 16 : 20,
            color: _getIconColor(theme),
          ),
          if (_getStatusText().isNotEmpty) ...[
            const SizedBox(width: gmSpaceXs),
            Flexible(
              child: Text(
                _getStatusText(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getIconColor(theme),
                ),
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
        return 'Download';
      case PackDownloadStatus.downloading:
        return progress != null
            ? 'Downloading ${(progress! * 100).round()}%'
            : 'Downloading';
      case PackDownloadStatus.cached:
        return 'Ready';
      case PackDownloadStatus.expired:
        return 'Update';
      case PackDownloadStatus.failed:
        return 'Try again';
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (status) {
      case PackDownloadStatus.available:
        return theme.colorScheme.primary;
      case PackDownloadStatus.downloading:
        // Bright gold fails contrast behind white text; use Antique Gold.
        return theme.colorScheme.primary;
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
        return theme.colorScheme.onPrimary;
      case PackDownloadStatus.cached:
      case PackDownloadStatus.expired:
        // on-success / on-warning (DESIGN.md › Colors)
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
