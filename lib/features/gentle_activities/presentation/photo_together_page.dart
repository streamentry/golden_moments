import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';
import 'package:golden_moments/shared/widgets/gm_bottom_bar.dart';

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
  String? _status;

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

  static const _prompts = [
    'What do you like about this picture?',
    'What catches your eye?',
    'Would you like to talk about this, or look at another picture?',
  ];

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
        _status =
            'Could not hide this picture. Nothing has changed. You can '
            'move to another picture or stop here.';
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
          ? 'Hidden for this visit.'
          : 'Hidden. You can show it again in Your family photos.';
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
        title: const GmTitle('Look together'),
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
    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.all(gmSpaceLg),
      children: [
        Text(
          'There are no pictures to look at here right now.',
          style: textTheme.headlineSmall,
        ),
        if (_status != null) ...[
          const SizedBox(height: gmSpaceMd),
          Text(_status!, style: textTheme.bodyLarge),
        ],
        const SizedBox(height: gmSpaceMd),
        Text(
          'You can look at the pictures included with the app, or stop '
          'here.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: gmSpaceLg),
        FilledButton.icon(
          onPressed: _useIncluded,
          icon: const Icon(Icons.collections_outlined),
          label: const Text('Look at the included pictures'),
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
    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.all(gmSpaceLg),
      children: [
        // Feedback sits where the eye lands after the view returns to the
        // picture, so it is seen even at large text.
        if (_status != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(_status!, style: textTheme.bodyLarge),
          ),
          const SizedBox(height: gmSpaceMd),
        ],
        Center(
          child: Semantics(
            image: true,
            label: [
              picture.label,
              if (picture.description.isNotEmpty) picture.description,
            ].join('. '),
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
          'Picture ${_index + 1} of ${_pictures.length}',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        if (_showPrompt) ...[
          const SizedBox(height: gmSpaceMd),
          Text(
            _prompts[_index % _prompts.length],
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
        ],
        const SizedBox(height: gmSpaceMd),
        if (_pictures.any((p) => p.caption.isNotEmpty))
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const GmTitle('Show captions'),
            value: _showCaption,
            onChanged: (value) => setState(() => _showCaption = value),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const GmTitle('Show a conversation prompt'),
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
            label: const Text('Hide this picture'),
          ),
        ),
        const SizedBox(height: gmSpaceSm),
        Text(
          'Just looking is enough. There is no need to remember a name '
          'or answer a question.',
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
      icon: const Icon(Icons.arrow_back),
      label: const Text('Previous'),
    ),
    second: FilledButton.icon(
      onPressed: _index >= _pictures.length - 1 ? null : () => _move(1),
      icon: const Icon(Icons.arrow_forward),
      label: const Text('Next'),
    ),
    labels: ('Previous', 'Next'),
    iconWidth: 24 + gmSpaceSm,
    secondOnTop: true,
  );

  Widget _controls() {
    final done = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Done for now'),
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
