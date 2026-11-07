import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';
import 'package:golden_moments/features/wellbeing/data/moment_history.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// The Daily moment: three pictures to look at and talk about, one at a time,
/// about 5 to 10 minutes if the person wants that long. There is no clock,
/// no step count and no score, and the person can stop at any time. Finishing
/// it records today's date in My progress, on this phone only.
class DailyMomentPage extends StatefulWidget {
  const new({
    required this.pictures,
    this.store = const MomentHistoryStore(),
    this.clock = DateTime.now,
    super.key,
  });

  /// Pictures to choose from. At least one is needed; three steps repeat them
  /// when there are fewer than three.
  final List<ActivityPicture> pictures;
  final MomentHistoryStore store;
  final DateTime Function() clock;

  static const steps = 3;

  @override
  State<DailyMomentPage> createState() => _DailyMomentPageState();
}

class _DailyMomentPageState extends State<DailyMomentPage> {
  int _step = 0;
  bool _saving = false;
  bool _saved = false;
  bool _saveFailed = false;

  /// Picks the picture and prompt for the current step. The day of the
  /// year moves the starting point, so the same moment does not come up
  /// every day.
  int _offset(DateTime now) =>
      now.difference(DateTime(now.year)).inDays + _step;

  Future<void> _finish() async {
    setState(() => _saving = true);
    final ok = await widget.store.markDone(widget.clock());
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved = ok;
      _saveFailed = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final now = widget.clock();
    final pictures = widget.pictures;
    final picture = pictures.isEmpty
        ? null
        : pictures[_offset(now) % pictures.length];
    final prompts = [
      l10n.togetherPromptLike,
      l10n.togetherPromptCatchesEye,
      l10n.togetherPromptTalkOrMove,
    ];
    final prompt = prompts[_offset(now) % prompts.length];
    final lastStep = _step == DailyMomentPage.steps - 1;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wellbeingHomeDailyMoment)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: Padding(
              padding: const EdgeInsets.all(gmSpaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.wellbeingDailyMomentIntro,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: gmSpaceLg),
                  Expanded(
                    child: picture == null
                        ? const SizedBox.shrink()
                        : Semantics(
                            label: picture.localizedLabel(l10n),
                            image: true,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(gmRadiusLg),
                              child: ColoredBox(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: PictureView(picture: picture),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: gmSpaceLg),
                  Text(
                    prompt,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: gmSpaceLg),
                  if (_saved)
                    Text(
                      l10n.wellbeingDailyMomentSaved,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    )
                  else if (_saveFailed)
                    Text(
                      l10n.wellbeingDailyMomentSaveFailed,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  if (!_saved) ...[
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(gmTargetPrimary),
                      ),
                      onPressed: pictures.isEmpty || _saving
                          ? null
                          : () {
                              if (lastStep) {
                                unawaited(_finish());
                              } else {
                                setState(() => _step += 1);
                              }
                            },
                      child: Text(
                        lastStep
                            ? l10n.commonDoneForNow
                            : l10n.dailyMomentShowNextStep,
                      ),
                    ),
                  ],
                  const SizedBox(height: gmSpaceMd),
                  // Back is always here: to the previous picture, or out of the
                  // page once it is saved. It never saves anything itself.
                  Align(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(gmTargetMin, gmTargetMin),
                      ),
                      onPressed: _saving
                          ? null
                          : _saved || _step == 0
                          ? () => Navigator.of(context).maybePop()
                          : () => setState(() => _step -= 1),
                      child: Text(l10n.commonBack),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
