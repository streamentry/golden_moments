import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/download_manager.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/game/game.dart';
import 'package:golden_moments/shared/utils/string_util.dart';
import 'package:golden_moments/shared/widgets/download_progress_card.dart';
import 'package:golden_moments/shared/widgets/pressable.dart';

/// Card widget for displaying a game pack
class PackCard extends StatefulWidget {
  const PackCard({
    required this.pack,
    this.onTap,
    this.showDailyBadge = false,
    this.showPremiumBadge = false,
    this.downloadProgress,
    super.key,
  });

  final Pack pack;
  final VoidCallback? onTap;
  final bool showDailyBadge;
  final bool showPremiumBadge;
  final double? downloadProgress;

  @override
  State<PackCard> createState() => _PackCardState();
}

class _PackCardState extends State<PackCard> {
  PackDownloadStatus? _downloadStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPackCacheStatus();
  }

  Future<void> _checkPackCacheStatus() async {
    try {
      final isCached = await JsonCacheService().isPackCached(widget.pack.id);
      if (mounted) {
        setState(() {
          _downloadStatus = isCached
              ? PackDownloadStatus.cached
              : PackDownloadStatus.available;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _downloadStatus = PackDownloadStatus.available;
        });
      }
    } finally {
      _isLoading = false;
    }
  }

  void _updateDownloadStatus(PackDownloadStatus status) {
    setState(() {
      _downloadStatus = status;
    });
  }

  void _startDownloadPack(Pack pack) {
    _updateDownloadStatus(PackDownloadStatus.downloading);
    unawaited(DownloadManager().downloadPack(pack.id));
    DownloadManager()
        .getDownloadProgress(
          generateDownloadId(
            pack.id,
            pack.images[pack.images.length - 1].id,
          ),
        )
        .listen((progress) {
          if (progress.isCompleted) {
            _updateDownloadStatus(PackDownloadStatus.cached);
          }
        });
  }

  void _showDownloadConfirmationDialog(Pack pack) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Download Pack'),
        content: Text(
          'Do you want to download the "${pack.title}" pack? This may consume data.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              SoundService().playTap();
              Navigator.of(dialogContext).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              SoundService().playTap();
              Navigator.of(dialogContext).pop(); // Close dialog
              _startDownloadPack(pack); // Start download

              FirebaseAnalytics.instance.logEvent(
                name: 'download_pack',
                parameters: {'Id': pack.id, 'Title': pack.title},
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Pressable(
        onPressed: () async {
          // Wait for ripple animation before calling onPressed
          await Future<void>.delayed(const Duration(milliseconds: 180));
          switch (_downloadStatus) {
            case PackDownloadStatus.cached:
              {
                if (widget.onTap == null) {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => GamePage(
                        gamePack: widget.pack,
                      ),
                    ),
                  );
                } else {
                  widget.onTap?.call();
                }

                await FirebaseAnalytics.instance.logScreenView(
                  screenName: 'Game',
                );
              }
            case PackDownloadStatus.available:
            case PackDownloadStatus.expired:
            case PackDownloadStatus.failed:
            case null:
              _showDownloadConfirmationDialog(widget.pack);
            case PackDownloadStatus.downloading:
          }
        },
        child: _buildLayout(theme),
      ),
    );
  }

  Widget _buildLayout(ThemeData theme) {
    IconData getIcon() {
      switch (_downloadStatus) {
        case PackDownloadStatus.cached:
          return Icons.download_done;
        case PackDownloadStatus.available:
        case PackDownloadStatus.expired:
        case PackDownloadStatus.failed:
        case null:
          return Icons.download;
        case PackDownloadStatus.downloading:
          return Icons.downloading;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder
        Padding(
          padding: EdgeInsetsGeometry.zero,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(gmRadiusMd),
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 3 / 2, // width / height
                  child: CachedNetworkImage(
                    imageUrl: widget.pack.thumbnailUrl,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.cover,
                    width: double.infinity, // match parent
                  ),
                ),
              ),
              // Badges
              Positioned(
                top: gmSpaceSm,
                right: gmSpaceSm,
                child: _buildBadges(theme),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(gmSpaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.pack.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  widget.pack.theme,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: gmSpaceSm,
                ),
                Row(
                  children: [
                    _buildDifficultyChip(theme),
                    const Spacer(),
                    if (_isLoading)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    else
                      Icon(
                        getIcon(),
                        size: 24,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(ThemeData theme) {
    final badges = <Widget>[];

    if (widget.showDailyBadge) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'DAILY',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (widget.showPremiumBadge) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'PREMIUM',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: badges
          .map(
            (badge) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: badge,
            ),
          )
          .toList(),
    );
  }

  Widget _buildDifficultyChip(ThemeData theme) {
    final Color chipColor;
    switch (widget.pack.difficulty) {
      case GameDifficulty.easy:
        chipColor = Colors.green;
      case GameDifficulty.medium:
        chipColor = Colors.orange;
      case GameDifficulty.hard:
        chipColor = Colors.red;
      case GameDifficulty.brainy:
        chipColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        widget.pack.difficulty.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
