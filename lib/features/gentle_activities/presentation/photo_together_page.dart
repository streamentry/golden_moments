import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/widgets/gm_bottom_bar.dart';

/// The note shown after Hide, kept as a reason so it follows the language.
enum _HideStatus { failed, hiddenForVisit, hiddenSaved }

/// Looking and talking are optional: this is not a recall or recognition test.
///
/// Nothing moves on its own: there is no slideshow, sound or timed
/// transition. Previous, Next and Done for now stay in a fixed bar so they
/// remain reachable at large text sizes (GM-002, GM-008).
class PhotoTogetherPage extends StatefulWidget {
  const new({required this.pictures, this.onHide, super.key});
  final List<ActivityPicture> pictures;

  /// Saves hiding a family photo so later activities skip it too. Returns
  /// whether it was saved. Without it, hiding lasts for this visit only.
  final Future<bool> Function(ActivityPicture picture)? onHide;

  @override
  State<PhotoTogetherPage> createState() => _PhotoTogetherPageState();
}

class _PhotoTogetherPageState extends State<PhotoTogetherPage> {
  late List<ActivityPicture> _pictures = widget.pictures;
  int _index = 0;
  bool _showPrompt = false;
  bool _showCaption = false;
  bool _hiding = false;
  bool _usingIncluded = false;
  _HideStatus? _status;

  /// When the picture changes, the view returns to it: at large text the
  /// person may have scrolled down to the buttons, and a new picture
  /// appearing out of sight looks as if nothing happened.
  final _scroll = ScrollController();
  final GmMoreBelow _moreBelow = GmMoreBelow();

  /// When three stacked buttons would take much of a small screen (large
  /// text), only Done for now stays fixed and Previous/Next sit directly
  /// under the picture, so the picture itself is never crowded out.
  bool _compactBar = false;

  @override
  void dispose() {
    _scroll.dispose();
    _moreBelow.dispose();
    super.dispose();
  }

  void _showPicture() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
    // The note above the picture is inserted in the next layout, which can
    // apply a scroll-offset correction; return to the top once more after it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients && _scroll.offset != 0) {
        _scroll.jumpTo(0);
      }
    });
  }

  /// Open-ended conversation prompts, never a recall question.
  static List<String> _prompts(AppLocalizations l10n) => [
    l10n.togetherPromptLike,
    l10n.togetherPromptCatchesEye,
    l10n.togetherPromptTalkOrMove,
  ];

  String _statusText(AppLocalizations l10n, _HideStatus status) =>
      switch (status) {
        _HideStatus.failed => l10n.togetherHideFailed,
        _HideStatus.hiddenForVisit => l10n.togetherHiddenForVisit,
        _HideStatus.hiddenSaved => l10n.togetherHiddenSaved,
      };

  void _move(int step) {
    setState(() {
      _index = (_index + step).clamp(0, _pictures.length - 1);
      _status = null;
    });
    _showPicture();
  }

  Future<void> _hide() async {
    if (_hiding || _pictures.isEmpty) return;
    final picture = _pictures[_index];
    final save = _usingIncluded ? null : widget.onHide;
    setState(() => _hiding = true);
    var saved = true;
    if (save != null) {
      try {
        saved = await save(picture);
      } on Object {
        saved = false;
      }
    }
    if (!mounted) return;
    setState(() {
      _hiding = false;
      if (!saved) {
        _status = _HideStatus.failed;
        return;
      }
      _pictures = [
        for (final p in _pictures)
          if (p.id != picture.id) p,
      ];
      _index = math.min(_index, math.max(0, _pictures.length - 1));
      _status = save == null
          // Short, so it never pushes the picture out of sight at
          // large text; it sits directly above the next picture.
          ? _HideStatus.hiddenForVisit
          : _HideStatus.hiddenSaved;
    });
    if (saved) _showPicture();
  }

  void _useIncluded() => setState(() {
    _pictures = ActivityPicture.samples;
    _usingIncluded = true;
    _index = 0;
    _showPicture();
    _status = null;
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    _compactBar =
        gmTargetPrimary * scale * 3 + gmSpaceLg * 2 >
        MediaQuery.sizeOf(context).height * 0.4;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: GmTitle(context.l10n.commonLookTogether),
      ),
      body: _moreBelow.watch(
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
              child: _pictures.isEmpty ? _empty(context) : _viewer(context),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _controls(),
    );
  }

  Widget _empty(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.all(gmSpaceLg),
      children: [
        Text(l10n.togetherEmptyTitle, style: textTheme.headlineSmall),
        if (_status != null) ...[
          const SizedBox(height: gmSpaceMd),
          Text(_statusText(l10n, _status!), style: textTheme.bodyLarge),
        ],
        const SizedBox(height: gmSpaceMd),
        Text(l10n.togetherEmptyBody, style: textTheme.bodyLarge),
        const SizedBox(height: gmSpaceLg),
        FilledButton.icon(
          onPressed: _useIncluded,
          icon: const Icon(Icons.collections_outlined),
          label: Text(l10n.togetherUseIncluded),
        ),
      ],
    );
  }

  Widget _viewer(BuildContext context) {
    final picture = _pictures[_index];
    return LayoutBuilder(
      builder: (context, viewport) {
        // A stable picture that always fits the visible area above the
        // fixed controls, so it is in sight together with Next and Done
        // even at large text on a small phone; never wider than the column.
        final side = math.max<double>(
          math.min(
            viewport.maxWidth - 2 * gmSpaceLg,
            viewport.maxHeight - 2 * gmSpaceLg,
          ),
          gmTileMin,
        );
        return _viewerList(context, picture, side);
      },
    );
  }

  Widget _viewerList(
    BuildContext context,
    ActivityPicture picture,
    double side,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l10n = context.l10n;
    final label = picture.localizedLabel(l10n);
    final prompts = _prompts(l10n);
    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.all(gmSpaceLg),
      children: [
        // Feedback sits where the eye lands after the view returns to the
        // picture, so it is seen even at large text.
        if (_status != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              _statusText(l10n, _status!),
              style: textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: gmSpaceMd),
        ],
        Center(
          child: Semantics(
            image: true,
            label: picture.description.isEmpty
                ? label
                : l10n.photosLabelWithDescription(label, picture.description),
            child: SizedBox.square(
              dimension: math.min(side, gmContentMaxWidth),
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: theme.colorScheme.surface,
                  shape: gmTileShape(theme.colorScheme),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(gmSpaceSm),
                  child: PictureView(picture: picture),
                ),
              ),
            ),
          ),
        ),
        if (_compactBar) ...[const SizedBox(height: gmSpaceMd), _navPair()],
        if (_showCaption && picture.caption.isNotEmpty) ...[
          const SizedBox(height: gmSpaceMd),
          Text(
            picture.caption,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
        ],
        const SizedBox(height: gmSpaceMd),
        Text(
          l10n.togetherPosition(_index + 1, _pictures.length),
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        if (_showPrompt) ...[
          const SizedBox(height: gmSpaceMd),
          Text(
            prompts[_index % prompts.length],
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
        ],
        const SizedBox(height: gmSpaceMd),
        if (_pictures.any((p) => p.caption.isNotEmpty))
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: GmTitle(l10n.togetherShowCaptions),
            value: _showCaption,
            onChanged: (value) => setState(() => _showCaption = value),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: GmTitle(l10n.togetherShowPrompt),
          value: _showPrompt,
          onChanged: (value) => setState(() => _showPrompt = value),
        ),
        const SizedBox(height: gmSpaceSm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            // Never disabled while saving (a disabled button drops focus
            // and its scroll position); a second tap is ignored in _hide.
            onPressed: () => unawaited(_hide()),
            icon: const Icon(Icons.visibility_off_outlined),
            label: Text(l10n.togetherHidePicture),
          ),
        ),
        const SizedBox(height: gmSpaceSm),
        Text(
          l10n.togetherJustLooking,
          style: textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _navPair() => GmButtonPair(
    first: OutlinedButton.icon(
      onPressed: _index == 0 ? null : () => _move(-1),
      // Material arrows mirror on their own in right-to-left languages.
      icon: const Icon(Icons.arrow_back),
      label: Text(context.l10n.togetherPrevious),
    ),
    second: FilledButton.icon(
      onPressed: _index >= _pictures.length - 1 ? null : () => _move(1),
      icon: const Icon(Icons.arrow_forward),
      label: Text(context.l10n.togetherNext),
    ),
    labels: (context.l10n.togetherPrevious, context.l10n.togetherNext),
    iconWidth: 24 + gmSpaceSm,
    secondOnTop: true,
  );

  Widget _controls() {
    final done = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(context.l10n.commonDoneForNow),
    );
    final navInBar = _pictures.isNotEmpty && !_compactBar;
    return GmBottomBar(
      moreBelow: _moreBelow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (navInBar) ...[_navPair(), const SizedBox(height: gmSpaceSm)],
          done,
        ],
      ),
    );
  }
}
