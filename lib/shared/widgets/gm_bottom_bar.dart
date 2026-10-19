import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:golden_moments/design_system.dart';

/// Whether a page's content continues below its fixed [GmBottomBar].
///
/// Wrap the page body with [watch] to follow its main vertical scroll view.
/// A scroll view that is removed sends no final notice, so a page that
/// switches to a layout without one sets [value] to false itself.
class GmMoreBelow extends ValueNotifier<bool> {
  new() : super(false);

  bool? _pending;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool _onMetrics(ScrollMetrics metrics, int depth) {
    if (depth == 0 && metrics.axis == Axis.vertical) {
      _set(metrics.extentAfter > 0.5);
    }
    return false;
  }

  /// Scroll positions can report during layout; listeners rebuild after it.
  void _set(bool more) {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase != SchedulerPhase.persistentCallbacks) {
      _pending = null;
      value = more;
      return;
    }
    final scheduled = _pending != null;
    _pending = more;
    if (scheduled) return;
    scheduler.addPostFrameCallback((_) {
      final latest = _pending;
      _pending = null;
      // The page may have closed during that frame.
      if (latest != null && !_disposed) value = latest;
    });
  }

  /// [body], reporting whether its content reaches below the visible area.
  Widget watch(Widget body) => NotificationListener<ScrollMetricsNotification>(
    onNotification: (notice) => _onMetrics(notice.metrics, notice.depth),
    child: NotificationListener<ScrollNotification>(
      onNotification: (notice) => _onMetrics(notice.metrics, notice.depth),
      child: body,
    ),
  );
}

/// The fixed action area under a page, in the centered content column.
///
/// While content continues beneath it, a 1px Driftwood line separates the
/// bar from the page, so words cut off at its edge read as "scroll for more"
/// rather than as clipped (DESIGN.md › Elevation: tone and borders, not
/// shadows). The line is painted, never laid out, so the bar does not move.
class GmBottomBar extends StatelessWidget {
  const new({required this.child, this.moreBelow, super.key});

  final Widget child;

  /// Usually a [GmMoreBelow] watching the page body; no line when null.
  final ValueListenable<bool>? moreBelow;

  @override
  Widget build(BuildContext context) {
    final bar = SafeArea(
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
            child: child,
          ),
        ),
      ),
    );
    final listenable = moreBelow;
    if (listenable == null) return bar;
    final line = Theme.of(context).colorScheme.outline;
    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (context, more, bar) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: more ? line : Colors.transparent),
          ),
        ),
        child: bar,
      ),
      child: bar,
    );
  }
}
