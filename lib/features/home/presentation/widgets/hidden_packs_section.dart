import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// The lasting way back from "Not for me" (GM-020, GM-026).
///
/// Lists every hidden pack with a "Show again" action. It stays on screen for
/// as long as anything is hidden: there is no countdown, and nothing is
/// unhidden automatically. Hiding never deletes a pack.
class HiddenPacksSection extends StatelessWidget {
  const new({
    required this.packs,
    required this.onShowAgain,
    this.favoriteIds = const {},
    super.key,
  });

  final List<Pack> packs;
  final ValueChanged<Pack> onShowAgain;

  /// Hidden packs that are also favorites, so the person knows showing one
  /// again returns it to their favorites.
  final Set<String> favoriteIds;

  @override
  Widget build(BuildContext context) {
    if (packs.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 32,
              color: scheme.primary,
            ),
            const SizedBox(width: gmSpaceSm),
            Expanded(
              child: Text(
                context.l10n.libraryHiddenTitle(packs.length),
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: gmSpaceSm),
        Text(
          context.l10n.libraryHiddenBody,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: gmSpaceSm),
        for (final pack in packs)
          Card(
            key: ValueKey('hidden-${pack.id}'),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                gmSpaceMd,
                gmSpaceSm,
                gmSpaceSm,
                gmSpaceSm,
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: gmSpaceSm,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(pack.title, style: theme.textTheme.titleMedium),
                      if (favoriteIds.contains(pack.id))
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 20, color: scheme.primary),
                            const SizedBox(width: gmSpaceXs),
                            Flexible(
                              child: Text(
                                context.l10n.libraryHiddenInFavorites,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  TextButton.icon(
                    key: ValueKey('show-again-${pack.id}'),
                    onPressed: () => onShowAgain(pack),
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(
                      context.l10n.libraryShowAgain,
                      semanticsLabel: context.l10n.libraryShowPackAgain(
                        pack.title,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The lasting note after "Not for me" (GM-026): says what happened and where
/// to undo it, with a "Show again" button. It never closes on a timer; it
/// goes when the pack is shown again or another pack is hidden. It is a
/// polite live region, and keyboard or switch focus moves to it, since the
/// button that was pressed has gone.
class HiddenNotice extends StatefulWidget {
  const new({required this.pack, required this.onShowAgain, super.key});

  final Pack pack;
  final VoidCallback onShowAgain;

  @override
  State<HiddenNotice> createState() => _HiddenNoticeState();
}

class _HiddenNoticeState extends State<HiddenNotice> {
  final FocusNode _focus = FocusNode(debugLabel: 'hidden-notice');

  @override
  void initState() {
    super.initState();
    _focusSoon();
  }

  @override
  void didUpdateWidget(HiddenNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pack.id != widget.pack.id) _focusSoon();
  }

  void _focusSoon() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Focus(
      focusNode: _focus,
      child: Semantics(
        container: true,
        liveRegion: true,
        child: DecoratedBox(
          key: ValueKey('hidden-notice-${widget.pack.id}'),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(gmRadiusLg),
            border: Border.all(color: scheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              gmSpaceMd,
              gmSpaceSm,
              gmSpaceSm,
              gmSpaceSm,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: gmSpaceSm,
              runSpacing: gmSpaceSm,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_off_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: gmSpaceSm),
                    Flexible(
                      child: Text(
                        context.l10n.libraryPackHiddenNotice(widget.pack.title),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  key: ValueKey('undo-hide-${widget.pack.id}'),
                  onPressed: widget.onShowAgain,
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(
                    context.l10n.libraryShowAgain,
                    semanticsLabel: context.l10n.libraryShowPackAgain(
                      widget.pack.title,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
