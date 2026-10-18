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
import 'package:golden_moments/shared/sharing/share_invitation.dart';
import 'package:provider/provider.dart';

/// Game page for playing memory matching games
class GamePage extends StatefulWidget {
  const new({required this.gamePack, super.key});

  final Pack gamePack;

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  /// Records the finished game; returns whether to suggest sharing.
  Future<bool> _recordCompletion() async {
    try {
      return await (await ShareInvitationStore.load()).recordCompletedGame();
    } on Object {
      return false;
    }
  }

  Future<void> _onCompleted(BuildContext context) async {
    unawaited(SoundService().playWinner());
    final invite = await _recordCompletion();
    if (!mounted || !context.mounted) return;
    _showCompletionDialog(context, invite: invite);
  }

  @override
  Widget build(BuildContext parentContext) {
    return BlocProvider(
      create: (context) {
        final cubit = GameCubit();
        unawaited(cubit.loadAndStartGame(widget.gamePack.id));
        return cubit;
      },
      child: PopScope(
        onPopInvokedWithResult: (_, _) {
          unawaited(SoundService().playTap());
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
                      unawaited(SoundService().playTap());
                      context.read<GameCubit>().showHint();
                    },
                    tooltip: 'Show a matching pair',
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay_outlined),
                    onPressed: () {
                      unawaited(SoundService().playTap());
                      context.read<GameCubit>().resetGame();
                    },
                    tooltip: 'Start again',
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      unawaited(SoundService().playTap());
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
                    unawaited(_onCompleted(context));
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
    unawaited(
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
                  unawaited(SoundService().playTap());
                  Navigator.of(dialogContext).pop();
                  Navigator.of(dialogContext).pop(); // Go back to home
                },
                child: const Text('Done for now'),
              ),
              FilledButton(
                onPressed: () {
                  unawaited(SoundService().playTap());
                  Navigator.of(dialogContext).pop();
                  parentContext.read<GameCubit>().resumeGame();
                },
                child: const Text('Keep playing'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog(
    BuildContext parentContext, {
    required bool invite,
  }) {
    var shared = false;
    Future<void> close() async {
      // Carrying on without sharing is a complete answer, never a nag.
      if (invite && !shared) {
        try {
          await (await ShareInvitationStore.load()).markDeclined();
        } on Object {
          // Sharing suggestions are optional; never block play on storage.
        }
      }
    }

    unawaited(
      showDialog<void>(
        context: parentContext,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            scrollable: true,
            title: const Text('All pairs together'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Play again, choose another pack, or take a break. Is there '
                  'a picture you would like to talk about?',
                ),
                if (invite && !shared) ...[
                  const SizedBox(height: gmSpaceMd),
                  ShareInvitation(
                    onShare: () async {
                      if (await shareAndRemember() && context.mounted) {
                        setDialogState(() => shared = true);
                      }
                    },
                  ),
                ],
                if (shared) ...[
                  const SizedBox(height: gmSpaceMd),
                  const Text('Thank you for sharing.'),
                ],
              ],
            ),
            actions: [
              GmOutlineButton(
                label: 'Play again',
                onTap: () {
                  unawaited(close());
                  Navigator.of(context).pop();
                  parentContext.read<GameCubit>().resetGame();
                },
              ),
              const SizedBox(height: gmSpaceSm),
              GmPrimaryButton(
                label: 'Choose another pack',
                onTap: () {
                  unawaited(close());
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading state view
class _LoadingView extends StatelessWidget {
  const new();

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
  const new({required this.state});

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
  const new({required this.state});

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
