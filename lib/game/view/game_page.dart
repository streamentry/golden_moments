import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/game/cubit/game_cubit.dart';
import 'package:golden_moments/game/models/models.dart';
import 'package:golden_moments/game/view/widgets/game_board.dart';
import 'package:golden_moments/game/view/widgets/game_header.dart';

/// Game page for playing memory matching games
class GamePage extends StatelessWidget {
  const GamePage({
    required this.gamePack,
    super.key,
  });

  final Pack gamePack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameCubit()..startGame(gamePack),
      child: const GameView(),
    );
  }
}

/// Game view widget
class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              context.read<GameCubit>().pauseGame();
              _showPauseDialog(context);
            },
            tooltip: 'Pause Game',
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
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
                    return _GamePlayView(state: state);
                  case GameStatus.completed:
                    return _GamePlayView(state: state);
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
  }

  void _showPauseDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Paused'),
        content: const Text(
          "Take your time! The game will resume when you're ready.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<GameCubit>().resumeGame();
            },
            child: const Text('Resume'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to home
            },
            child: const Text('Quit Game'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, GameState state) {
    final completionTime = state.completionTime;
    final timeText = completionTime != null
        ? '${completionTime.inMinutes}:${(completionTime.inSeconds % 60).toString().padLeft(2, '0')}'
        : 'Unknown';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Congratulations!'),
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
              context.read<GameCubit>().resetGame();
            },
          ),
          const SizedBox(width: gmSpaceSm),
          GmPrimaryButton(
            label: 'Continue',
            onTap: () {
              Navigator.of(context).pop(); // Go back to home
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
  Widget build(BuildContext context) {
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
  const _GamePlayView({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
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
                context.read<GameCubit>().onTileTap(tileId);
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: gmSpaceMd),
            GmOutlineButton(
              label: 'Go Back',
              onTap: () {
                Navigator.of(context).pop();
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
  Widget build(BuildContext context) {
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
              style: Theme.of(context).textTheme.headlineSmall,
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
                context.read<GameCubit>().resetGame();
              },
            ),
            const SizedBox(height: gmSpaceSm),
            GmOutlineButton(
              label: 'Go Back',
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
