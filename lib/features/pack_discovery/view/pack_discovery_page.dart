import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_lane/design_system.dart';
import 'package:memory_lane/features/pack_discovery/cubit/pack_discovery_cubit.dart';
import 'package:memory_lane/features/pack_discovery/view/widgets/pack_category_grid.dart';
import 'package:memory_lane/features/pack_discovery/view/widgets/pack_search_bar.dart';
import 'package:memory_lane/shared/widgets/download_progress_card.dart';

/// Pack discovery page for browsing available packs
class PackDiscoveryPage extends StatelessWidget {
  const PackDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PackDiscoveryCubit()..initialize(),
      child: const PackDiscoveryView(),
    );
  }
}

/// Pack discovery view widget
class PackDiscoveryView extends StatelessWidget {
  const PackDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Packs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PackDiscoveryCubit>().refreshPacks();
            },
            tooltip: 'Refresh Packs',
          ),
        ],
      ),
      body: BlocBuilder<PackDiscoveryCubit, PackDiscoveryState>(
        builder: (context, state) {
          switch (state.status) {
            case PackDiscoveryStatus.initial:
            case PackDiscoveryStatus.loading:
              return const _LoadingView();
            case PackDiscoveryStatus.error:
              return _ErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<PackDiscoveryCubit>().refreshPacks(),
              );
            case PackDiscoveryStatus.loaded:
              return _LoadedView(state: state);
          }
        },
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
            'Discovering new packs...',
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
              Icons.cloud_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: gmSpaceMd),
            Text(
              'Unable to discover packs',
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

  final PackDiscoveryState state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<PackDiscoveryCubit>().refreshPacks(),
      child: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(gmSpaceMd),
              child: PackSearchBar(
                searchQuery: state.searchQuery,
                onSearchChanged: (query) {
                  context.read<PackDiscoveryCubit>().searchPacks(query);
                },
                onFilterTap: () {
                  _showFilterBottomSheet(context);
                },
              ),
            ),
          ),

          // Featured packs section
          if (state.featuredPacks.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: gmSpaceMd),
                child: _SectionHeader(
                  title: 'Featured Packs',
                  icon: Icons.star,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: gmSpaceMd),
                  itemCount: state.featuredPacks.length,
                  itemBuilder: (context, index) {
                    final pack = state.featuredPacks[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: gmSpaceMd),
                      child: _FeaturedPackCard(pack: pack),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: gmSpaceLg),
            ),
          ],

          // Categories section
          if (state.categories.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: gmSpaceMd),
                child: _SectionHeader(
                  title: 'Browse by Category',
                  icon: Icons.category,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: PackCategoryGrid(
                categories: state.categories,
                selectedCategory: state.selectedCategory,
                onCategorySelected: (category) {
                  context.read<PackDiscoveryCubit>().selectCategory(category);
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: gmSpaceLg),
            ),
          ],

          // All packs section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: gmSpaceMd),
              child: _SectionHeader(
                title: state.searchQuery.isNotEmpty 
                    ? 'Search Results (${state.filteredPacks.length})'
                    : 'All Packs',
                icon: Icons.grid_view,
              ),
            ),
          ),

          // Packs grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: gmSpaceMd),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: gmSpaceMd,
                mainAxisSpacing: gmSpaceMd,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pack = state.filteredPacks[index];
                  return _PackDiscoveryCard(pack: pack);
                },
                childCount: state.filteredPacks.length,
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: gmSpaceLg),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _FilterBottomSheet(
        currentState: context.read<PackDiscoveryCubit>().state,
        onFiltersChanged: (filters) {
          context.read<PackDiscoveryCubit>().applyFilters(filters);
        },
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
      padding: const EdgeInsets.only(bottom: gmSpaceMd),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: gmSpaceSm),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Featured pack card widget
class _FeaturedPackCard extends StatelessWidget {
  const _FeaturedPackCard({required this.pack});

  final dynamic pack; // GitHubPackInfo

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pack image placeholder
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(gmRadiusMd),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.photo_library,
                      size: 32,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  // Featured badge
                  Positioned(
                    top: gmSpaceSm,
                    right: gmSpaceSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: gmGold600,
                        borderRadius: BorderRadius.circular(gmRadiusMd),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Pack info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(gmSpaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Pack', // pack.title
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  DownloadStatusBadge(
                    status: PackDownloadStatus.available,
                    size: DownloadBadgeSize.small,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pack discovery card widget
class _PackDiscoveryCard extends StatelessWidget {
  const _PackDiscoveryCard({required this.pack});

  final dynamic pack; // GitHubPackInfo

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(gmRadiusMd),
        onTap: () {
          // Navigate to pack details
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pack image placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(gmRadiusMd),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.photo_library,
                    size: 40,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            
            // Pack info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(gmSpaceSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Pack', // pack.title
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Category', // pack.category
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '10 images', // ${pack.imageCount} images
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        DownloadStatusBadge(
                          status: PackDownloadStatus.available,
                          size: DownloadBadgeSize.small,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter bottom sheet widget
class _FilterBottomSheet extends StatelessWidget {
  const _FilterBottomSheet({
    required this.currentState,
    required this.onFiltersChanged,
  });

  final PackDiscoveryState currentState;
  final void Function(PackDiscoveryFilters filters) onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(gmSpaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Packs',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: gmSpaceMd),
          
          // Difficulty filter
          Text(
            'Difficulty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: gmSpaceSm),
          // Add difficulty filter chips here
          
          const SizedBox(height: gmSpaceMd),
          
          // Premium filter
          Text(
            'Content Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: gmSpaceSm),
          // Add premium filter chips here
          
          const SizedBox(height: gmSpaceLg),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: GmPrimaryButton(
              label: 'Apply Filters',
              onTap: () {
                Navigator.of(context).pop();
                // Apply filters
              },
            ),
          ),
        ],
      ),
    );
  }
}
