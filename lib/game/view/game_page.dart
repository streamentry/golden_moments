import 'dart:async';
import 'dart:io';

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
import 'package:share_plus/share_plus.dart';

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
  int _completePlayCount = 3;

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

  void _reset() {
    _resetTimer();
  }

  void _playAgain() {
    _timer?.cancel();
    setState(() {
      if (_completePlayCount == 3) {
        _completePlayCount = 1;
      } else {
        _completePlayCount++;
      }
      _elapsedSeconds = 0;
      _isPaused = false;
    });
    _startTimer();
  }

  void _shareAppLink() {
    final link = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.mindfulness.golden_moments'
        // Change to ios later
        : 'https://play.google.com/store/apps/details?id=com.mindfulness.golden_moments';

    Share.share(
      'Check out this app!\n$link',
      subject: 'Try this app!',
    );
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
  Widget build(BuildContext parentContext) {
    return BlocProvider(
      create: (context) => GameCubit()..loadAndStartGame(widget.gamePack.id),
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
                      icon: const Icon(Icons.pause),
                      onPressed: () {
                        SoundService().playTap();
                        context.read<GameCubit>().pauseGame();
                        _showPauseDialog(context);
                      },
                      tooltip: 'Pause Game',
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_outlined),
                      onPressed: () {
                        SoundService().playTap();
                        context.read<GameCubit>().resetGame();
                        _reset();
                      },
                      tooltip: 'Replay',
                    ),
                    IconButton(
                      icon: const Icon(Icons.lightbulb_outline),
                      onPressed: () {
                        SoundService().playTap();
                        context.read<GameCubit>().showHint();
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
                              return _GamePlayView(
                                state: state,
                                currentTime: formatTime(_elapsedSeconds),
                              );
                            case GameStatus.completed:
                              return _GamePlayView(
                                state: state,
                                currentTime: formatTime(_elapsedSeconds),
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
              );
            },
          ),
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
    final timeText = formatTime(_elapsedSeconds);

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
              _playAgain();
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

  void _showInviteFriendDialog(BuildContext parentContext) {
    Timer? autoCloseTimer;
    final remainingTime = ValueNotifier<int>(15);

    showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        autoCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (remainingTime.value > 0) {
            remainingTime.value--;
          } else {
            timer.cancel();
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          }
        });

        return ValueListenableBuilder<int>(
          valueListenable: remainingTime,
          builder: (context, timeLeft, child) {
            return Dialog(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(gmSpaceLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title section with progress bar
                    Column(
                      children: [
                        const Text(
                          'Invite a Friend',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: gmSpaceMd),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 1,
                            end: timeLeft / 15,
                          ),
                          duration: const Duration(seconds: 1),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: gmSpaceSm),
                        Text(
                          'Auto-closing in $timeLeft seconds',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: gmSpaceLg),

                    // Icon
                    Container(
                      padding: const EdgeInsets.all(gmSpaceMd),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.group_add,
                        size: 48,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: gmSpaceLg),

                    // Content
                    const Text(
                      'Share the Golden Moments!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: gmSpaceMd),
                    const Text(
                      "You've completed 3 memory games! 🎉\n\nWhy not invite your friends and family to join the fun? Share precious memories together and challenge each other in this delightful memory game.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: gmSpaceLg),

                    // Buttons
                    GmPrimaryButton(
                      label: 'Invite Friends',
                      onTap: () {
                        _shareAppLink();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      autoCloseTimer?.cancel();
      remainingTime.dispose();
    });
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
              'Something went wrong with the pack. Please reinstall this pack or play another pack.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: gmSpaceLg),
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
