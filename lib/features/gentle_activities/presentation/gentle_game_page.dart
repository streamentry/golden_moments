import 'dart:math';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/models/gentle_board.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';

class GentleGamePage extends StatefulWidget {
  const GentleGamePage({required this.pictures, super.key});
  final List<ActivityPicture> pictures;

  @override
  State<GentleGamePage> createState() => _GentleGamePageState();
}

class _GentleGamePageState extends State<GentleGamePage> {
  GentleBoard? _board;
  int _pairs = 2;
  bool _keepVisible = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    final choices = List<ActivityPicture>.of(widget.pictures)
      ..shuffle(Random());
    if (choices.length >= _pairs) {
      _board = GentleBoard(choices.take(_pairs).map((p) => p.id).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final board = _board;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Gentle photo match')),
      body: board == null
          ? const Center(child: Text('Choose at least two photos to play.'))
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: gmContentMaxWidth,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(gmSpaceLg),
                    children: [
                      Text(
                        'Tap two pictures that match. Take your time.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: gmSpaceMd),
                      Wrap(
                        spacing: gmSpaceSm,
                        runSpacing: gmSpaceSm,
                        children: [
                          for (final pairs in [2, 3, 4, 6])
                            if (pairs <= widget.pictures.length)
                              ChoiceChip(
                                label: Text('${pairs * 2} tiles'),
                                selected: _pairs == pairs,
                                onSelected: (_) => setState(() {
                                  _pairs = pairs;
                                  _start();
                                }),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                              ),
                        ],
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Keep pictures visible'),
                        subtitle: const Text(
                          'Turn off only when you prefer hidden tiles.',
                        ),
                        value: _keepVisible,
                        onChanged: (value) =>
                            setState(() => _keepVisible = value),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns =
                              constraints.maxWidth >= 600 && _pairs >= 3
                              ? 3
                              : 2;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: board.cards.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: gmTileGap,
                                  mainAxisSpacing: gmTileGap,
                                  childAspectRatio: 1.1,
                                ),
                            itemBuilder: (context, index) {
                              final picture = widget.pictures.firstWhere(
                                (p) => p.id == board.cards[index],
                              );
                              final visible = board.isVisible(
                                index,
                                keepVisible: _keepVisible,
                              );
                              final matched = board.isMatched(index);
                              final emphasized =
                                  matched || board.isSelected(index);
                              return Semantics(
                                button: true,
                                enabled: !matched,
                                onTap: matched
                                    ? null
                                    : () => setState(() {
                                        board.tap(index);
                                      }),
                                label: visible
                                    ? '${picture.label}, tile ${index + 1}'
                                    : 'Hidden picture, tile ${index + 1}',
                                value: matched
                                    ? 'Matched'
                                    : board.isSelected(index)
                                    ? 'Selected'
                                    : '',
                                child: ExcludeSemantics(
                                  child: Material(
                                    color: visible ? scheme.surface : gmSurf200,
                                    shape: gmTileShape(
                                      scheme,
                                      emphasized: emphasized,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: matched
                                          ? null
                                          : () => setState(() {
                                              board.tap(index);
                                            }),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(
                                              gmSpaceSm,
                                            ),
                                            child: visible
                                                ? PictureView(picture: picture)
                                                : Icon(
                                                    Icons.photo_outlined,
                                                    size: 56,
                                                    color:
                                                        scheme.onSurfaceVariant,
                                                  ),
                                          ),
                                          if (matched)
                                            const Positioned(
                                              top: gmSpaceSm,
                                              right: gmSpaceSm,
                                              child: GmMatchBadge(),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: gmSpaceLg),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          board.complete
                              ? 'All pairs together. '
                                    'Play again or take a break.'
                              : board.waitingForNextTurn
                              ? 'Take your time. Tap a picture to continue.'
                              : 'There is no time limit.',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: gmSpaceMd),
                      FilledButton(
                        onPressed: () => setState(_start),
                        child: Text(
                          board.complete ? 'Play again' : 'Start again',
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Done for now'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
