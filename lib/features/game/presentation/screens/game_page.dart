import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/game_cubit.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_exit_bar.dart';
import 'package:golden_moments/features/game/presentation/widgets/game_play_view.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/l10n/pack_text.dart';
import 'package:golden_moments/shared/rating/review_request.dart';
import 'package:golden_moments/shared/sharing/share_invitation.dart';
import 'package:golden_moments/shared/widgets/gm_bottom_bar.dart';
import 'package:provider/provider.dart';

/// Picture-pack matching game.
///
/// Like the gentle board (GM-002), "Done for now" is always visible in a
/// bottom bar, Start again asks before clearing found pairs, and the finish
/// message never asks for a rating (Home may, later: DESIGN.md › Ratings).
/// No clock, move count or score is shown.
class GamePage extends StatefulWidget {
  const new({required this.gamePack, super.key});

  final Pack gamePack;

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GmMoreBelow _moreBelow = GmMoreBelow();

  @override
  void dispose() {
    _moreBelow.dispose();
    super.dispose();
  }

  /// Records the finished game; returns whether to suggest sharing.
  Future<bool> _recordCompletion() async {
    bool invite;
    try {
      invite = await (await ShareInvitationStore.load()).recordCompletedGame();
    } on Object {
      invite = false;
    }
    unawaited(recordFinishedGameForReview(suggestedSharing: invite));
    return invite;
  }

  Future<void> _onCompleted(BuildContext context) async {
    // The chime is optional; the dialog carries the message.
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
        child: BlocConsumer<GameCubit, GameState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == GameStatus.completed) {
              unawaited(_onCompleted(context));
            }
          },
          builder: (context, state) {
            final playing = switch (state.status) {
              GameStatus.playing ||
              GameStatus.paused ||
              GameStatus.completed => true,
              _ => false,
            };
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: gmToolbarHeight(context),
                title: GmTitle(
                  playing
                      ? context.packText.packTitle(state.currentPack)
                      : context.l10n.gameTitleFallback,
                ),
                actions: playing
                    ? [
                        IconButton(
                          icon: const Icon(Icons.lightbulb_outline),
                          onPressed: () {
                            unawaited(SoundService().playTap());
                            context.read<GameCubit>().showHint();
                          },
                          tooltip: context.l10n.gameHintTooltip,
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: () {
                            unawaited(SoundService().playTap());
                            unawaited(_showOptions(context));
                          },
                          tooltip: context.l10n.gameOptionsTooltip,
                        ),
                      ]
                    : null,
              ),
              body: switch (state.status) {
                GameStatus.initial ||
                GameStatus.loading => const _LoadingView(),
                GameStatus.playing ||
                GameStatus.paused ||
                GameStatus.completed => _moreBelow.watch(
                  GamePlayView(state: state),
                ),
                GameStatus.failed ||
                GameStatus.requiresDownload => const _ErrorView(),
              },
              bottomNavigationBar: playing
                  ? GameExitBar(
                      moreBelow: _moreBelow,
                      onDone: () => Navigator.of(context).pop(),
                      onStartAgain: () => unawaited(_startAgain(context)),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }

  /// Found pairs are only cleared after a yes; "Keep this board" leaves the
  /// exact board as it was (GM-002).
  Future<void> _startAgain(BuildContext context) async {
    final cubit = context.read<GameCubit>();
    final state = cubit.state;
    // One turned-over picture is not progress; found pairs are.
    final hasProgress =
        state.status != GameStatus.completed && state.matchedPairs > 0;
    if (hasProgress) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          title: GmTitle(dialogContext.l10n.gameStartAgainTitle),
          content: Text(dialogContext.l10n.gameStartAgainBody),
          // Keeping the board is the safe choice, so it is the primary one.
          actions: gmDialogActions(
            other: TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                dialogContext.l10n.commonStartAgain,
                textAlign: TextAlign.center,
              ),
            ),
            primary: FilledButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                dialogContext.l10n.commonKeepThisBoard,
                textAlign: TextAlign.center,
              ),
            ),
            labels: (
              dialogContext.l10n.commonStartAgain,
              dialogContext.l10n.commonKeepThisBoard,
            ),
          ),
        ),
      );
      if (ok != true || cubit.isClosed) return;
    }
    cubit.resetGame();
  }

  /// Sound and stop choices. Closing the dialog in any way, including the
  /// system Back, returns to the same board.
  Future<void> _showOptions(BuildContext parentContext) async {
    final cubit = parentContext.read<GameCubit>()..pauseGame();
    await showDialog<void>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: GmTitle(dialogContext.l10n.gameOptionsTitle),
        scrollable: true,
        content: Consumer<SoundSettings>(
          builder: (_, settings, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(dialogContext.l10n.gameOptionsBody),
              const SizedBox(height: gmSpaceMd),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  settings.isMusicOn ? Icons.music_note : Icons.music_off,
                ),
                title: GmTitle(dialogContext.l10n.settingsMusic),
                subtitle: GmTitle(dialogContext.l10n.settingsMusicSubtitle),
                value: settings.isMusicOn,
                onChanged: (_) => settings.toggleMusic(),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  settings.isSoundOn ? Icons.volume_up : Icons.volume_off,
                ),
                title: GmTitle(dialogContext.l10n.settingsSounds),
                subtitle: GmTitle(dialogContext.l10n.settingsSoundsSubtitle),
                value: settings.isSoundOn,
                onChanged: (_) => settings.toggleSound(),
              ),
            ],
          ),
        ),
        actions: gmDialogActions(
          other: TextButton(
            onPressed: () {
              unawaited(SoundService().playTap());
              Navigator.of(dialogContext).pop();
              Navigator.of(parentContext).pop();
            },
            child: Text(
              dialogContext.l10n.commonDoneForNow,
              textAlign: TextAlign.center,
            ),
          ),
          primary: FilledButton(
            onPressed: () {
              unawaited(SoundService().playTap());
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              dialogContext.l10n.gameKeepPlaying,
              textAlign: TextAlign.center,
            ),
          ),
          labels: (
            dialogContext.l10n.commonDoneForNow,
            dialogContext.l10n.gameKeepPlaying,
          ),
        ),
      ),
    );
    if (!cubit.isClosed) cubit.resumeGame();
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
            title: GmTitle(context.l10n.gameFinishTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.gameFinishBody),
                if (invite && !shared) ...[
                  const SizedBox(height: gmSpaceMd),
                  ShareInvitation(
                    onShare: () async {
                      if (await shareAndRemember(context.l10n) &&
                          context.mounted) {
                        setDialogState(() => shared = true);
                      }
                    },
                  ),
                ],
                if (shared) ...[
                  const SizedBox(height: gmSpaceMd),
                  Text(context.l10n.commonThankYouForSharing),
                ],
              ],
            ),
            // As on the gentle board, Play again is the one primary action.
            actions: gmDialogActions(
              other: OutlinedButton(
                onPressed: () {
                  unawaited(SoundService().playTap());
                  unawaited(close());
                  Navigator.of(context).pop();
                  Navigator.of(parentContext).pop();
                },
                child: Text(
                  context.l10n.gameChooseAnotherPack,
                  textAlign: TextAlign.center,
                ),
              ),
              primary: FilledButton(
                onPressed: () {
                  unawaited(SoundService().playTap());
                  unawaited(close());
                  Navigator.of(context).pop();
                  parentContext.read<GameCubit>().resetGame();
                },
                child: Text(
                  context.l10n.commonPlayAgain,
                  textAlign: TextAlign.center,
                ),
              ),
              labels: (
                context.l10n.gameChooseAnotherPack,
                context.l10n.commonPlayAgain,
              ),
            ),
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(gmSpaceLg),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: gmSpaceMd),
            Text(parentContext.l10n.gameLoading, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Error state view
class _ErrorView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(gmSpaceLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: gmSpaceMd),
              Text(
                parentContext.l10n.gameErrorTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: gmSpaceSm),
              Text(
                parentContext.l10n.gameErrorBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: gmSpaceLg),
              GmOutlineButton(
                label: parentContext.l10n.gameGoBack,
                onTap: () {
                  Navigator.of(parentContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
