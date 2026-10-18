import 'dart:async';

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
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = DownloadedPacksCubit();
        unawaited(cubit.initialize());
        return cubit;
      },
      child: const DownloadManagerView(),
    );
  }
}

/// Download manager view widget
class DownloadManagerView extends StatefulWidget {
  const new({super.key});

  @override
  State<DownloadManagerView> createState() => _DownloadManagerViewState();
}

typedef PackSelectionCallback = void Function(
  Pack pack, {
  required bool isSelected,
}); // Custom callback type

class _DownloadManagerViewState extends State<DownloadManagerView> {
  PackFilterOption _selectedFilter = PackFilterOption.all;
  final Set<Pack> _selectedPacks = <Pack>{}; // Explicitly typed as Set<Pack>
  bool _isSelectionMode = false; // Track selection mode
  bool _isSelectedAll = false;

  void _showDownloadAllDialog(BuildContext parentContext) {
    final notDownloadedPacks = parentContext
        .read<DownloadedPacksCubit>()
        .state
        .notDownloadedPacks;

    unawaited(
      showDialog<void>(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            title: const Text('Download all packs'),
            content: notDownloadedPacks.isEmpty
                ? const Text('All packs are already downloaded.')
                : const Text('Are you sure you want to download all packs?'),
            actions: [
              TextButton(
                onPressed: () {
                  unawaited(SoundService().playTap());
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
              if (notDownloadedPacks.isNotEmpty)
                FilledButton(
                  onPressed: () {
                    unawaited(SoundService().playTap());
                    Navigator.of(context).pop(); // Close the dialog
                    unawaited(
                      parentContext
                          .read<DownloadedPacksCubit>()
                          .downloadAllPacks(),
                    ); // Trigger download all logic
                  },
                  child: const Text('Download all'),
                ),
            ],
          );
        },
      ),
    );
  }

  void _toggleSelectedAll(List<Pack> downloadedPacks) {
    setState(() {
      _isSelectedAll = !_isSelectedAll;
      _selectedPacks.clear();
      if (_isSelectedAll) {
        _selectedPacks.addAll(downloadedPacks);
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedPacks.clear(); // Clear selections when exiting selection mode
        _isSelectedAll = false;
      }
    });
  }

  void _deleteSelectedPacks(BuildContext parentContext) {
    if (_selectedPacks.isNotEmpty) {
      unawaited(
        showDialog<void>(
          context: parentContext,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete selected packs'),
              content: const Text(
                'Delete the selected packs from this device? You can '
                'download them again later.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    unawaited(SoundService().playTap());
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: () {
                    unawaited(SoundService().playTap());
                    Navigator.of(context).pop(); // Close the dialog
                    unawaited(
                      parentContext.read<DownloadedPacksCubit>().deletePacks(
                        _selectedPacks.toList(),
                      ),
                    ); // Trigger delete logic
                    _toggleSelectionMode(); // Exit selection mode
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ),
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
            body = _LoadedView(
              state: state,
              packFilterOption: _selectedFilter,
              onLongPress: _toggleSelectionMode,
              isSelectionMode: _isSelectionMode,
              selectedPacks: _selectedPacks,
              onPackSelected: (pack, {required isSelected}) {
                setState(() {
                  if (isSelected) {
                    _selectedPacks.add(pack);
                    if (state.downloadedPacks.length == _selectedPacks.length) {
                      _isSelectedAll = true;
                    }
                  } else {
                    _selectedPacks.remove(pack);
                    _isSelectedAll = false;
                  }
                });
              },
            );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Download'),
            actions: [
              if (_isSelectionMode)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close), // New icon added
                      tooltip: 'Stop selecting',
                      onPressed: () {
                        unawaited(SoundService().playTap());
                        _toggleSelectionMode();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete selected packs',
                      onPressed: _selectedPacks.isEmpty
                          ? null
                          : () {
                              unawaited(SoundService().playTap());
                              _deleteSelectedPacks(context);
                            },
                    ),
                  ],
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More options',
                  onSelected: (value) {
                    unawaited(SoundService().playTap());
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
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: gmContentMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: gmSpaceLg,
                          right: gmSpaceLg,
                          bottom: gmSpaceSm,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: gmSpaceMd,
                          children: [
                            DropdownButton<PackFilterOption>(
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
                                  child: Text('Not downloaded'),
                                ),
                              ],
                            ),
                            if (_isSelectionMode)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _isSelectedAll,
                                    onChanged: (newValue) {
                                      _toggleSelectedAll(state.downloadedPacks);
                                    },
                                  ),
                                  const Text('Select all'),
                                ],
                              ),
                          ],
                        ),
                      ),
                      body,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Loading state view
class _LoadingView extends StatelessWidget {
  const new();

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
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Error state view
class _ErrorView extends StatelessWidget {
  const new({required this.onRetry});

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
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: gmSpaceMd),
            Text(
              'Downloads could not load',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'An error occurred while loading downloads.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceLg),
            GmPrimaryButton(label: 'Try again', onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

/// Loaded state view
class _LoadedView extends StatelessWidget {
  const new({
    required this.state,
    required this.onPackSelected,
    required this.packFilterOption,
    required this.onLongPress,
    this.isSelectionMode = false,
    this.selectedPacks = const {},
  });

  final DownloadedPacksState state;
  final bool isSelectionMode;
  final Set<Pack> selectedPacks;
  final PackSelectionCallback onPackSelected;
  final PackFilterOption packFilterOption;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext parentContext) {
    late var packs = <Pack>[];
    switch (packFilterOption) {
      case PackFilterOption.all:
        packs = state.packs;
      case PackFilterOption.downloaded:
        packs = state.downloadedPacks;
      case PackFilterOption.notDownloaded:
        packs = state.notDownloadedPacks;
    }

    if (packs.isEmpty) {
      return const _EmptyView();
    }

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: gmSpaceSm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - gmSpaceSm) / 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              // Grows with the text size instead of a fixed aspect ratio.
              mainAxisExtent: PackCard.gridExtent(context, cardWidth),
              crossAxisSpacing: gmSpaceSm,
              mainAxisSpacing: gmSpaceSm,
            ),
            itemCount: packs.length,
            itemBuilder: (context, index) {
              final pack = packs[index];
              return GestureDetector(
                key: ValueKey(pack.id),
                onTap: () {
                  unawaited(SoundService().playTap());
                  if (isSelectionMode) {
                    final isSelected = selectedPacks.contains(pack);
                    onPackSelected(pack, isSelected: !isSelected);
                  }
                },
                onLongPress: () {
                  if (!isSelectionMode &&
                      packFilterOption == PackFilterOption.downloaded) {
                    final isSelected = selectedPacks.contains(pack);
                    onPackSelected(pack, isSelected: !isSelected);
                    onLongPress();
                  }
                },
                child: AbsorbPointer(
                  absorbing: isSelectionMode,
                  child: Stack(
                    children: [
                      PackCard(pack: pack),
                      // Selection checkbox
                      if (isSelectionMode)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Checkbox(
                            value: selectedPacks.contains(pack),
                            onChanged: null,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Empty state view
class _EmptyView extends StatelessWidget {
  const new();

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
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: gmSpaceMd),
            Text(
              'No packs',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'Download some packs or update to new version to see them here',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
