import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/game/models/models.dart';

/// Header widget showing game statistics and progress
class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.state,
  });

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = state.currentPack.difficulty.pairCount > 0
        ? state.matchedPairs / state.currentPack.difficulty.pairCount
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(gmSpaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                'Progress:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: gmSpaceSm),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.outline.withValues(
                    alpha: 0.3,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: gmSpaceSm),
              Text(
                '${state.matchedPairs}/${state.currentPack.difficulty.pairCount}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: gmSpaceMd),

          // Game stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(
                icon: Icons.touch_app,
                label: 'Moves',
                value: state.moves.toString(),
                theme: theme,
              ),
              _StatCard(
                icon: Icons.timer,
                label: 'Time',
                value: _formatTime(state.startTime),
                theme: theme,
              ),
              _StatCard(
                icon: Icons.stars,
                label: 'Difficulty',
                value: state.currentPack.difficulty.displayName,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? startTime) {
    if (startTime == null) return '0:00';

    final elapsed = DateTime.now().difference(startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Individual stat card widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: gmSpaceMd,
        vertical: gmSpaceSm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(gmRadiusMd),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
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
