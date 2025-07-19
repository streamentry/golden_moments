import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';

/// Search bar widget for pack discovery
class PackSearchBar extends StatefulWidget {
  const PackSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    this.onFilterTap,
    this.hasActiveFilters = false,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  @override
  State<PackSearchBar> createState() => _PackSearchBarState();
}

class _PackSearchBarState extends State<PackSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PackSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Search field
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(gmRadiusMd),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search packs...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        onPressed: () {
                          _controller.clear();
                          widget.onSearchChanged('');
                        },
                        tooltip: 'Clear search',
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: gmSpaceMd,
                  vertical: gmSpaceMd,
                ),
              ),
              style: theme.textTheme.bodyMedium,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _focusNode.unfocus();
              },
            ),
          ),
        ),

        // Filter button
        if (widget.onFilterTap != null) ...[
          const SizedBox(width: gmSpaceMd),
          Container(
            decoration: BoxDecoration(
              color: widget.hasActiveFilters
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(gmRadiusMd),
              border: Border.all(
                color: widget.hasActiveFilters
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: IconButton(
              onPressed: widget.onFilterTap,
              icon: Stack(
                children: [
                  Icon(
                    Icons.tune,
                    color: widget.hasActiveFilters
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  if (widget.hasActiveFilters)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Filter packs',
            ),
          ),
        ],
      ],
    );
  }
}

/// Search suggestions widget
class PackSearchSuggestions extends StatelessWidget {
  const PackSearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: gmSpaceSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(gmRadiusMd),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: suggestions.map((suggestion) {
          return InkWell(
            onTap: () => onSuggestionTap(suggestion),
            borderRadius: BorderRadius.circular(gmRadiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: gmSpaceMd,
                vertical: gmSpaceSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: gmSpaceSm),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Icon(
                    Icons.north_west,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Recent searches widget
class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.recentSearches,
    required this.onSearchTap,
    required this.onClearAll,
  });

  final List<String> recentSearches;
  final ValueChanged<String> onSearchTap;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            TextButton(
              onPressed: onClearAll,
              child: Text(
                'Clear All',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: gmSpaceSm),
        Wrap(
          spacing: gmSpaceSm,
          runSpacing: gmSpaceSm,
          children: recentSearches.map((search) {
            return InkWell(
              onTap: () => onSearchTap(search),
              borderRadius: BorderRadius.circular(gmRadiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: gmSpaceSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(gmRadiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      search,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
