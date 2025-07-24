import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/download_manager/cubit/downloaded_packs_cubit.dart';
import 'package:golden_moments/features/download_manager/cubit/downloaded_packs_state.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';

/// Enum for filter options
enum PackFilterOption { all, downloaded, notDownloaded }

/// Download manager page for managing active downloads
class DownloadManagerPage extends StatelessWidget {
  const DownloadManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DownloadedPacksCubit()..initialize(),
      child: const DownloadManagerView(),
    );
  }
}

/// Download manager view widget
class DownloadManagerView extends StatefulWidget {
  const DownloadManagerView({super.key});

  @override
  State<DownloadManagerView> createState() => _DownloadManagerViewState();
}

typedef PackSelectionCallback =
    void Function(Pack pack, bool isSelected); // Custom callback type

class _DownloadManagerViewState extends State<DownloadManagerView> {
  PackFilterOption _selectedFilter = PackFilterOption.all;
  final Set<Pack> _selectedPacks = <Pack>{}; // Explicitly typed as Set<Pack>
  bool _isSelectionMode = false; // Track selection mode

  void _showDownloadAllDialog(BuildContext parentContext) {
    final notDownloadedPacks = parentContext
        .read<DownloadedPacksCubit>()
        .state
        .notDownloadedPacks;

    showDialog<void>(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Download All Packs'),
          content: notDownloadedPacks.isEmpty
              ? const Text('All packs are already downloaded.')
              : const Text('Are you sure you want to download all packs?'),
          actions: [
            TextButton(
              onPressed: () {
                SoundService().playTap();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            if (notDownloadedPacks.isNotEmpty)
              TextButton(
                onPressed: () {
                  SoundService().playTap();
                  Navigator.of(context).pop(); // Close the dialog
                  parentContext
                      .read<DownloadedPacksCubit>()
                      .downloadAllPacks(); // Trigger download all logic
                },
                child: const Text('Accept'),
              ),
          ],
        );
      },
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedPacks.clear(); // Clear selections when exiting selection mode
      }
    });
  }

  void _deleteSelectedPacks(BuildContext parentContext) {
    if (_selectedPacks.isNotEmpty) {
      showDialog<void>(
        context: parentContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Selected Packs'),
            content: const Text(
              'Are you sure you want to delete the selected packs?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  SoundService().playTap();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  SoundService().playTap();
                  Navigator.of(context).pop(); // Close the dialog
                  parentContext.read<DownloadedPacksCubit>().deletePacks(
                    _selectedPacks.toList(),
                  ); // Trigger delete logic
                  _toggleSelectionMode(); // Exit selection mode
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    } else {
      _toggleSelectionMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadedPacksCubit, DownloadedPacksState>(
      builder: (context, state) {
        Widget body;
        switch (state.status) {
          case DownloadedPacksPageStatus.initial:
          case DownloadedPacksPageStatus.loading:
            body = const _LoadingView();
          case DownloadedPacksPageStatus.error:
            body = _ErrorView(
              onRetry: () => context.read<DownloadedPacksCubit>().initialize(),
            );
          case DownloadedPacksPageStatus.loaded:
            final filteredPacks = _filterPacks(state);
            body = _LoadedView(
              state: state.copyWith(downloadedPacks: filteredPacks),
              isSelectionMode: _isSelectionMode,
              selectedPacks: _selectedPacks,
              onPackSelected: (Pack pack, bool isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedPacks.add(pack);
                  } else {
                    _selectedPacks.remove(pack);
                  }
                });
              },
            );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Library'),
            actions: [
              if (_isSelectionMode)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close), // New icon added
                      onPressed: () {
                        SoundService().playTap();
                        _toggleSelectionMode();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _selectedPacks.isEmpty
                          ? null
                          : () {
                              SoundService().playTap();
                              _deleteSelectedPacks(context);
                            },
                    ),
                  ],
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    SoundService().playTap();
                    // Handle menu item selection
                    if (value == 'DOWNLOAD') {
                      _showDownloadAllDialog(
                        context,
                      ); // Show the download dialog
                    } else if (value == 'DELETE') {
                      setState(() {
                        _selectedFilter = PackFilterOption.downloaded;
                      });
                      _toggleSelectionMode();
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'DOWNLOAD',
                          child: Text('Download all packs'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'DELETE',
                          child: Text('Select packs to delete'),
                        ),
                      ],
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Trigger the cubit to reload data
              await context.read<DownloadedPacksCubit>().initialize();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(gmSpaceMd),
                    child: Padding(
                      padding: const EdgeInsets.only(right: gmSpaceLg),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: DropdownButton<PackFilterOption>(
                          value: _selectedFilter,
                          onChanged: _isSelectionMode
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedFilter = value;
                                    });
                                  }
                                },
                          items: const [
                            DropdownMenuItem(
                              value: PackFilterOption.all,
                              child: Text('All'),
                            ),
                            DropdownMenuItem(
                              value: PackFilterOption.downloaded,
                              child: Text('Downloaded'),
                            ),
                            DropdownMenuItem(
                              value: PackFilterOption.notDownloaded,
                              child: Text('Not Downloaded'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  body,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Pack> _filterPacks(DownloadedPacksState state) {
    switch (_selectedFilter) {
      case PackFilterOption.downloaded:
        return state.downloadedPacks;
      case PackFilterOption.notDownloaded:
        return state.notDownloadedPacks;
      case PackFilterOption.all:
        return state.packs;
    }
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
    required this.onRetry,
  });

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
              'An error occurred while loading downloads.',
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
  const _LoadedView({
    required this.state,
    required this.onPackSelected,
    this.isSelectionMode = false,
    this.selectedPacks = const {},
  });

  final DownloadedPacksState state;
  final bool isSelectionMode;
  final Set<Pack> selectedPacks;
  final PackSelectionCallback onPackSelected;

  @override
  Widget build(BuildContext context) {
    if (state.downloadedPacks.isEmpty) {
      return const _EmptyView();
    }

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: gmSpaceSm),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: gmSpaceSm,
          mainAxisSpacing: gmSpaceSm,
        ),
        itemCount: state.downloadedPacks.length,
        itemBuilder: (context, index) {
          final pack = state.downloadedPacks[index];
          return GestureDetector(
            onTap: () {
              SoundService().playTap();
              if (isSelectionMode) {
                final isSelected = selectedPacks.contains(pack);
                onPackSelected(pack, !isSelected);
              }
            },
            child: AbsorbPointer(
              absorbing: isSelectionMode,
              child: Stack(
                children: [
                  PackCard(
                    pack: pack,
                  ),
                  // Selection checkbox
                  if (isSelectionMode)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Checkbox(
                        checkColor: Colors.green,
                        value: selectedPacks.contains(pack),
                        onChanged: null,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
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
              'No Downloaded Packs',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'Download some packs to see them here',
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
