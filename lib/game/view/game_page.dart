import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_lane/game/cubit/game_cubit.dart';
import 'package:memory_lane/game/models/models.dart';
import 'package:memory_lane/game/view/widgets/game_board.dart';
import 'package:memory_lane/game/view/widgets/game_header.dart';
import 'package:memory_lane/shared/constants/app_constants.dart';

/// Game page for playing memory matching games
class GamePage extends StatelessWidget {
  const GamePage({
    super.key,
    required this.gamePack,
  });

  final GamePack gamePack;

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
      body: BlocListener<GameCubit, GameState>(
        listener: (context, state) {
          if (state.status == GameStatus.completed) {
            _showCompletionDialog(context, state);
          }
        },
        child: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            switch (state.status) {
              case GameStatus.initial:
                return const _LoadingView();
              case GameStatus.playing:
              case GameStatus.paused:
                return _GamePlayView(state: state);
              case GameStatus.completed:
                return _GamePlayView(state: state);
              case GameStatus.failed:
                return _ErrorView(state: state);
            }
          },
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Paused'),
        content: const Text('Take your time! The game will resume when you\'re ready.'),
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
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Moves: ${state.moves}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Time: $timeText',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'Did this bring back any memories?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<GameCubit>().resetGame();
            },
            child: const Text('Play Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to home
            },
            child: const Text('Continue'),
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
          SizedBox(height: AppConstants.defaultPadding),
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
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: GameBoard(
              tiles: state.tiles,
              difficulty: state.currentPack.difficulty,
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

/// Error state view
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Game Error',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            const Text(
              'Something went wrong with the game. Please try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton(
              onPressed: () {
                context.read<GameCubit>().resetGame();
              },
              child: const Text('Try Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
