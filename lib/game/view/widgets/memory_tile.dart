import 'package:flutter/material.dart';
import 'package:memory_lane/game/models/models.dart';
import 'package:memory_lane/shared/constants/app_constants.dart';

/// Individual memory tile widget
class MemoryTile extends StatefulWidget {
  const MemoryTile({
    super.key,
    required this.tile,
    required this.onTap,
  });

  final GameTile tile;
  final VoidCallback onTap;

  @override
  State<MemoryTile> createState() => _MemoryTileState();
}

class _MemoryTileState extends State<MemoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.tileFlipDuration,
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(MemoryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate flip when tile state changes
    if (oldWidget.tile.isRevealed != widget.tile.isRevealed) {
      if (widget.tile.isRevealed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: isShowingFront
                ? _buildBackSide(theme)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildFrontSide(theme),
                  ),
          );
        },
      ),
    );
  }

  /// Build the back side of the tile (hidden state)
  Widget _buildBackSide(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.help_outline,
          size: 32,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  /// Build the front side of the tile (revealed state)
  Widget _buildFrontSide(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: widget.tile.isMatched
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: widget.tile.isMatched
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
          width: widget.tile.isMatched ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getIconForTheme(widget.tile.caption),
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          
          // Caption
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.tile.caption,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: widget.tile.isMatched
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Matched indicator
          if (widget.tile.isMatched)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 12,
                color: theme.colorScheme.onPrimary,
              ),
            ),
        ],
      ),
    );
  }

  /// Get icon based on tile caption/theme
  IconData _getIconForTheme(String caption) {
    final lowerCaption = caption.toLowerCase();
    
    if (lowerCaption.contains('car') || lowerCaption.contains('vehicle')) {
      return Icons.directions_car;
    } else if (lowerCaption.contains('movie') || lowerCaption.contains('film')) {
      return Icons.movie;
    } else if (lowerCaption.contains('toy') || lowerCaption.contains('game')) {
      return Icons.toys;
    } else if (lowerCaption.contains('kitchen') || lowerCaption.contains('household')) {
      return Icons.kitchen;
    } else if (lowerCaption.contains('tv') || lowerCaption.contains('television')) {
      return Icons.tv;
    } else if (lowerCaption.contains('fashion') || lowerCaption.contains('clothing')) {
      return Icons.checkroom;
    } else if (lowerCaption.contains('music') || lowerCaption.contains('song')) {
      return Icons.music_note;
    } else if (lowerCaption.contains('food') || lowerCaption.contains('drink')) {
      return Icons.restaurant;
    } else {
      return Icons.photo;
    }
  }
}
