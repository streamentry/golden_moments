import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/game_cubit.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_board.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_header.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// Game page for playing memory matching games
class GamePage extends StatefulWidget {
  const GamePage({required this.gamePack, super.key});

  final Pack gamePack;

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _completePlayCount = 1;

  void _playAgain() {
    setState(() {
      if (_completePlayCount == 3) {
        _completePlayCount = 1;
      } else {
        _completePlayCount++;
      }
    });
  }

  void _shareAppLink() {
    const link =
        'https://play.google.com/store/apps/details?id=com.mindfulness.golden_moments';

    unawaited(
      SharePlus.instance.share(
        ShareParams(
          text: 'A gentle picture game we enjoy together:\n$link',
          subject: 'Golden Moments',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext parentContext) {
    return BlocProvider(
      create: (context) => GameCubit()..loadAndStartGame(widget.gamePack.id),
      child: PopScope(
        onPopInvokedWithResult: (_, _) {
          SoundService().playTap();
        },
        child: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: BlocBuilder<GameCubit, GameState>(
                  builder: (_, state) {
                    return Text(state.currentPack.title);
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.lightbulb_outline),
                    onPressed: () {
                      SoundService().playTap();
                      context.read<GameCubit>().showHint();
                    },
                    tooltip: 'Show a matching pair',
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay_outlined),
                    onPressed: () {
                      SoundService().playTap();
                      context.read<GameCubit>().resetGame();
                    },
                    tooltip: 'Start again',
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      SoundService().playTap();
                      context.read<GameCubit>().pauseGame();
                      _showPauseDialog(context);
                    },
                    tooltip: 'Sound and options',
                  ),
                ],
              ),
              body: BlocListener<GameCubit, GameState>(
                listenWhen: (previous, current) =>
                    previous.status != current.status,
                listener: (context, state) {
                  if (state.status == GameStatus.completed) {
                    _showCompletionDialog(context);
                    SoundService().playWinner();
                    if (_completePlayCount == 3) {
                      _showInviteFriendDialog(context);
                    }
                  }
                },
                child: BlocBuilder<GameCubit, GameState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case GameStatus.initial:
                      case GameStatus.loading:
                        return const _LoadingView();
                      case GameStatus.playing:
                      case GameStatus.paused:
                      case GameStatus.completed:
                        return _GamePlayView(state: state);
                      case GameStatus.failed:
                        return _ErrorView(state: state);
                      case GameStatus.requiresDownload:
                        return _ErrorView(state: state);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext parentContext) {
    showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Options'),
          scrollable: true,
          content: Consumer<SoundSettings>(
            builder: (_, settings, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Take your time. Nothing changes while you rest.'),
                const SizedBox(height: gmSpaceMd),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    settings.isMusicOn ? Icons.volume_up : Icons.volume_off,
                  ),
                  title: const Text('Music'),
                  value: settings.isMusicOn,
                  onChanged: (value) {
                    setState(settings.toggleMusic);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    settings.isSoundOn ? Icons.music_note : Icons.music_off,
                  ),
                  title: const Text('Sounds'),
                  value: settings.isSoundOn,
                  onChanged: (value) {
                    setState(settings.toggleSound);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SoundService().playTap();
                Navigator.of(dialogContext).pop();
                Navigator.of(dialogContext).pop(); // Go back to home
              },
              child: const Text('Done for now'),
            ),
            FilledButton(
              onPressed: () {
                SoundService().playTap();
                Navigator.of(dialogContext).pop();
                parentContext.read<GameCubit>().resumeGame();
              },
              child: const Text('Keep playing'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext parentContext) {
    showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('All pairs together'),
        content: const Text(
          'Play again, choose another pack, or take a break. Is there a '
          'picture you would like to talk about?',
        ),
        actions: [
          GmOutlineButton(
            label: 'Play again',
            onTap: () {
              Navigator.of(context).pop();
              parentContext.read<GameCubit>().resetGame();
              _playAgain();
            },
          ),
          const SizedBox(height: gmSpaceSm),
          GmPrimaryButton(
            label: 'Choose another pack',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// A gentle, dismissible share suggestion. It never counts down or closes
  /// on its own (DESIGN.md › Interaction & Game Feel).
  void _showInviteFriendDialog(BuildContext parentContext) {
    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          scrollable: true,
          icon: Icon(Icons.group_add_outlined, size: 48, color: scheme.primary),
          title: const Text('Share Golden Moments?'),
          content: const Text(
            'If you enjoy these pictures together, other families might too.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () {
                _shareAppLink();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }
}

/// Loading state view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext parentContext) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: gmSpaceMd),
          Text('Getting the pictures ready…'),
        ],
      ),
    );
  }
}

/// Game play view
class _GamePlayView extends StatelessWidget {
  const _GamePlayView({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext parentContext) {
    return Column(
      children: [
        // Game header with stats
        GameHeader(state: state),

        // Game board
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(gmSpaceMd),
            child: GameBoard(
              tiles: state.tiles,
              difficulty: state.currentPack.difficulty,
              packId: state.currentPack.id,
              onTileTap: (tileId) {
                parentContext.read<GameCubit>().onTileTap(tileId);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Error state view
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext parentContext) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(parentContext).colorScheme.error,
            ),
            const SizedBox(height: gmSpaceMd),
            Text(
              'This pack could not open',
              style: Theme.of(parentContext).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            const Text(
              'Please choose another pack. Your other packs and '
              'activities still work.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceLg),
            GmOutlineButton(
              label: 'Go back',
              onTap: () {
                Navigator.of(parentContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
