import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/game/cubit/game_cubit.dart';
import 'package:golden_moments/game/cubit/game_state.dart';
import 'package:golden_moments/game/view/widgets/game_board.dart';
import 'package:golden_moments/game/view/widgets/game_header.dart';
import 'package:golden_moments/shared/utils/string_util.dart';
import 'package:provider/provider.dart';

/// Game page for playing memory matching games
class GamePage extends StatefulWidget {
  const GamePage({
    required this.gamePack,
    super.key,
  });

  final Pack gamePack;

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void _startTimer() {
    if (_timer?.isActive == true) return; // Don't start if already running
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isPaused) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
    _startTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsedSeconds = 0;
      _isPaused = false;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameCubit()..startNewGame(widget.gamePack),
      child: BlocListener<GameCubit, GameState>(
        listener: (context, state) {
          // Handle timer based on game status
          if (state.status == GameStatus.paused) {
            _pauseTimer();
          } else if (state.status == GameStatus.playing) {
            _resumeTimer();
          } else if (state.status == GameStatus.completed) {
            _pauseTimer();
          }
        },
        child: GameView(
          currentTime: formatTime(_elapsedSeconds),
          onRestart: _resetTimer,
        ),
      ),
    );
  }
}

/// Game view widget
class GameView extends StatelessWidget {
  const GameView({
    required this.currentTime,
    required this.onRestart,
    super.key,
  });

  final String currentTime;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext parentContext) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        SoundService().playTap();
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<GameCubit, GameState>(
            builder: (context, state) {
              return Text(state.currentPack.title);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () {
                SoundService().playTap();
                parentContext.read<GameCubit>().pauseGame();
                _showPauseDialog(parentContext);
              },
              tooltip: 'Pause Game',
            ),
            IconButton(
              icon: const Icon(Icons.replay_outlined),
              onPressed: () {
                SoundService().playTap();
                parentContext.read<GameCubit>().resetGame();
                onRestart();
              },
              tooltip: 'Replay',
            ),
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () {
                SoundService().playTap();
                parentContext.read<GameCubit>().showHint();
              },
              tooltip: 'Show Hint',
            ),
          ],
        ),
        body: Stack(
          children: [
            BlocListener<GameCubit, GameState>(
              listener: (context, state) {
                if (state.status == GameStatus.completed) {
                  _showCompletionDialog(context, state);
                  SoundService().playWinner();
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
                      return _GamePlayView(
                        state: state,
                        currentTime: currentTime,
                      );
                    case GameStatus.completed:
                      return _GamePlayView(
                        state: state,
                        currentTime: currentTime,
                      );
                    case GameStatus.failed:
                      return _ErrorView(state: state);
                    case GameStatus.requiresDownload:
                      return _RequiresDownloadView(state: state);
                  }
                },
              ),
            ),
            // Confetti overlay for celebrations
            BlocBuilder<GameCubit, GameState>(
              builder: (context, state) {
                return GmConfettiOverlay(
                  show: state.status == GameStatus.completed,
                );
              },
            ),
          ],
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
          title: const Text('Game Paused'),
          content: Consumer<SoundSettings>(
            builder: (_, settings, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Take your time! The game will resume when you're ready.",
                ),
                const SizedBox(height: gmSpaceMd),
                Row(
                  children: [
                    Icon(
                      settings.isMusicOn ? Icons.volume_up : Icons.volume_off,
                    ),
                    const SizedBox(width: gmSpaceSm),
                    const Text('Music'),
                    const Spacer(),
                    Switch(
                      value: settings.isMusicOn,
                      onChanged: (value) {
                        setState(() {
                          settings.toggleMusic();
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      settings.isSoundOn ? Icons.music_note : Icons.music_off,
                    ),
                    const SizedBox(width: gmSpaceSm),
                    const Text('Sound'),
                    const Spacer(),
                    Switch(
                      value: settings.isSoundOn,
                      onChanged: (value) {
                        setState(() {
                          settings.toggleSound();
                        });
                      },
                    ),
                  ],
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
              child: const Text('Quit Game'),
            ),
            TextButton(
              onPressed: () {
                SoundService().playTap();
                Navigator.of(dialogContext).pop();
                parentContext.read<GameCubit>().resumeGame();
              },
              child: const Text('Resume'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext parentContext, GameState state) {
    // Use the current formatted time from the stopwatch
    final timeText = currentTime;

    showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('🎉 Congratulations!')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You completed the memory game!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceMd),
            Text(
              'Moves: ${state.moves}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Time: $timeText',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: gmSpaceMd),
            const Text(
              'Did this bring back any memories?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          GmOutlineButton(
            label: 'Play Again',
            onTap: () {
              Navigator.of(context).pop();
              parentContext.read<GameCubit>().resetGame();
              onRestart();
            },
          ),
          const SizedBox(height: gmSpaceSm),
          GmPrimaryButton(
            label: 'New Packs',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
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
          Text(
            'Preparing your memory game...',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

/// Game play view
class _GamePlayView extends StatelessWidget {
  const _GamePlayView({
    required this.state,
    required this.currentTime,
  });

  final GameState state;
  final String currentTime;

  @override
  Widget build(BuildContext parentContext) {
    return Column(
      children: [
        // Game header with stats
        GameHeader(
          state: state,
          currentTime: currentTime,
        ),

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

/// Requires download view
class _RequiresDownloadView extends StatelessWidget {
  const _RequiresDownloadView({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(gmSpaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_download,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: gmSpaceMd),
            Text(
              'Download Required',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'This pack needs to be downloaded before you can play.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceLg),
            GmPrimaryButton(
              label: 'Download Pack',
              onTap: () {
                // Navigate to pack details or start download
                Navigator.of(parentContext).pop();
              },
            ),
            const SizedBox(height: gmSpaceMd),
            GmOutlineButton(
              label: 'Go Back',
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: gmSpaceMd),
            Text(
              'Game Error',
              style: Theme.of(parentContext).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceSm),
            const Text(
              'Something went wrong with the game. Please try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceLg),
            GmPrimaryButton(
              label: 'Try Again',
              onTap: () {
                parentContext.read<GameCubit>().resetGame();
              },
            ),
            const SizedBox(height: gmSpaceSm),
            GmOutlineButton(
              label: 'Go Back',
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
