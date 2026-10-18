import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/download_manager.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/game.dart';
import 'package:golden_moments/shared/widgets/pressable.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

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

  /// Height of a [PackCard] in a grid whose columns are [cardWidth] wide.
  ///
  /// The text area grows with the system text size, so nothing clips at
  /// 200% text.
  static double gridExtent(BuildContext context, double cardWidth) =>
      cardWidth * 2 / 3 + 176 * MediaQuery.textScalerOf(context).scale(1);

  @override
  State<PackCard> createState() => _PackCardState();
}

class _PackCardState extends State<PackCard> {
  PackStatus? _downloadStatus;
  double _downloadProgress = 0;
  bool _isLoading = true;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _checkPackStatus();
    DownloadManager().addListener(_onStatusChange);
  }

  @override
  void dispose() {
    DownloadManager().removeListener(_onStatusChange);
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPackStatus() async {
    setState(() {
      _downloadStatus = DownloadManager().getPackStatus(widget.pack.id);
    });
    _isLoading = false;
  }

  void _onStatusChange() {
    final status = DownloadManager().getPackStatus(widget.pack.id);
    setState(() {
      _downloadStatus = status;
    });
    if (status == PackStatus.downloading) {
      _calculateDownloadProgress(widget.pack.id);
    }
  }

  void _startDownloadPack(String packId) {
    unawaited(
      DownloadManager().downloadPack(packId).catchError((Object error) {
        if (!mounted) return;
        _progressTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed. Please try again.')),
        );
      }),
    );
    _calculateDownloadProgress(packId);
  }

  void _calculateDownloadProgress(String packId) {
    _progressTimer?.cancel(); // Cancel any existing timer
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _downloadProgress = DownloadManager().getPackDownloadProgress(packId);
      });
      if (DownloadManager().getPackStatus(packId) == PackStatus.completed) {
        timer.cancel();
      }
    });
  }

  void _showDownloadConfirmationDialog(Pack pack) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Download pack'),
        content: Text(
          'Do you want to download the "${pack.title}" pack?'
          ' This may consume data.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              unawaited(SoundService().playTap());
              Navigator.of(dialogContext).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              unawaited(SoundService().playTap());
              Navigator.of(dialogContext).pop(); // Close dialog
              _startDownloadPack(pack.id); // Start download

              try {
                await FirebaseAnalytics.instance.logEvent(
                  name: 'download_pack',
                  parameters: {'Id': pack.id, 'Title': pack.title},
                );
              } on Object catch (_) {
                // Analytics is optional when Firebase is not configured.
              }
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
          switch (_downloadStatus) {
            case PackStatus.completed:
              {
                if (widget.onTap == null) {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => GamePage(gamePack: widget.pack),
                    ),
                  );
                } else {
                  widget.onTap?.call();
                }

                try {
                  await FirebaseAnalytics.instance.logScreenView(
                    screenName: 'Game',
                  );
                } on Object catch (_) {
                  // Analytics must not interrupt gameplay.
                }
              }
            case PackStatus.notStarted:
            case null:
              _showDownloadConfirmationDialog(widget.pack);
            case PackStatus.downloading:
          }
        },
        child: _buildLayout(theme),
      ),
    );
  }

  Widget _buildLayout(ThemeData theme) {
    // Status is an icon, a word and a color, never color alone.
    Widget getStatus() {
      final Widget indicator;
      final String word;
      final Color color;
      switch (_downloadStatus) {
        case PackStatus.completed:
          color = gmGreen600;
          word = 'Ready';
          indicator = Icon(Icons.download_done, size: 24, color: color);
        case PackStatus.notStarted:
        case null:
          color = theme.colorScheme.primary;
          word = 'Download';
          indicator = Icon(Icons.download, size: 24, color: color);
        case PackStatus.downloading:
          color = theme.colorScheme.primary;
          word = 'Downloading';
          indicator = CircularPercentIndicator(
            radius: 12,
            lineWidth: 4,
            percent: _downloadProgress.clamp(0, 1).toDouble(),
            progressColor: color,
            backgroundColor: gmSurf200,
          );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(width: gmSpaceXs),
          Flexible(
            child: Text(
              word,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
      );
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
                decoration: const BoxDecoration(
                  color: gmSurf200,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(gmRadiusLg),
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 3 / 2, // width / height
                  child: CachedNetworkImage(
                    imageUrl: widget.pack.thumbnailUrl,
                    errorWidget: (context, url, error) => Icon(
                      Icons.photo_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: gmSpaceSm),
                Wrap(
                  spacing: gmSpaceSm,
                  runSpacing: gmSpaceXs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildDifficultyChip(theme),
                    if (_isLoading)
                      const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    else
                      getStatus(),
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
          padding: const EdgeInsets.symmetric(
            horizontal: gmSpaceSm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(gmRadiusMd),
          ),
          child: Text(
            'Daily',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondary,
            ),
          ),
        ),
      );
    }

    if (widget.showPremiumBadge) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: gmSpaceSm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(gmRadiusMd),
          ),
          child: Text(
            'Premium',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiary,
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
              padding: const EdgeInsets.only(bottom: gmSpaceXs),
              child: badge,
            ),
          )
          .toList(),
    );
  }

  // Difficulty is not a status, so the chip stays neutral: "hard" is not
  // "danger" (DESIGN.md › Colors).
  Widget _buildDifficultyChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: gmSpaceSm,
        vertical: gmSpaceXs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(gmRadiusMd),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        widget.pack.difficulty.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
