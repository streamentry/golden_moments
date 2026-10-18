import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';

/// "Done for now" and "Start again", fixed below the board so the exit is
/// always on screen (GM-002).
///
/// The two buttons sit side by side whenever their labels fit on one line
/// at the current text size; they stack only when they genuinely do not, so
/// the bar never takes more height than it needs (GM-012/GM-016).
class GameExitBar extends StatelessWidget {
  const new({required this.onDone, required this.onStartAgain, super.key});

  final VoidCallback onDone;
  final VoidCallback onStartAgain;

  static const doneLabel = 'Done for now';
  static const startAgainLabel = 'Start again';

  /// Matches the outlined-button padding and 2px border in `gmBuildTheme`.
  static const double _buttonChrome = gmSpaceLg * 2 + 2 * 2;

  /// Width a button needs to keep [label] on one line.
  static double _neededWidth(BuildContext context, String label) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width + _buttonChrome;
  }

  @override
  Widget build(BuildContext context) {
    final done = OutlinedButton(
      onPressed: onDone,
      child: const Text(doneLabel, textAlign: TextAlign.center),
    );
    final again = OutlinedButton(
      onPressed: onStartAgain,
      child: const Text(startAgainLabel, textAlign: TextAlign.center),
    );
    return SafeArea(
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              gmSpaceLg,
              gmSpaceSm,
              gmSpaceLg,
              gmSpaceMd,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final half = (constraints.maxWidth - gmSpaceMd) / 2;
                final sideBySide =
                    _neededWidth(context, doneLabel) <= half &&
                    _neededWidth(context, startAgainLabel) <= half;
                if (sideBySide) {
                  return Row(
                    children: [
                      Expanded(child: done),
                      const SizedBox(width: gmSpaceMd),
                      Expanded(child: again),
                    ],
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    done,
                    const SizedBox(height: gmSpaceSm),
                    again,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
