import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/game/models/models.dart';

/// Header widget showing game statistics and progress
class GameHeader extends StatelessWidget {
  const GameHeader({
    required this.state,
    required this.currentTime,
    super.key,
  });

  final GameState state;
  final String currentTime;

  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);

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
          // Game stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(
                icon: Icons.touch_app,
                value: state.moves.toString(),
                theme: theme,
              ),
              const SizedBox(
                width: gmSpaceSm,
              ),
              _StatCard(
                icon: Icons.timer,
                value: currentTime,
                theme: theme,
              ),
              const SizedBox(
                width: gmSpaceSm,
              ),
              _StatCard(
                icon: Icons.stars,
                value: state.currentPack.difficulty.displayName,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual stat card widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext parentContext) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: gmSpaceSm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(gmRadiusMd),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(
              width: gmSpaceSm,
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
