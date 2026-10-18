import 'dart:math';

import 'package:flutter/material.dart';
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
    final choices = List<ActivityPicture>.of(widget.pictures)..shuffle(Random());
    if (choices.length >= _pairs) {
      _board = GentleBoard(choices.take(_pairs).map((p) => p.id).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final board = _board;
    return Scaffold(
      appBar: AppBar(title: const Text('Gentle photo match')),
      body: board == null
          ? const Center(child: Text('Choose at least two photos to play.'))
          : SafeArea(child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Tap two pictures that match. Take your time.',
                    style: TextStyle(fontSize: 20)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final pairs in [2, 3, 4, 6])
                    if (pairs <= widget.pictures.length)
                      ChoiceChip(
                        label: Text('${pairs * 2} tiles'), selected: _pairs == pairs,
                        onSelected: (_) => setState(() { _pairs = pairs; _start(); }),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                ]),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Keep pictures visible'),
                  subtitle: const Text('Turn off only when you prefer hidden tiles.'),
                  value: _keepVisible,
                  onChanged: (value) => setState(() => _keepVisible = value),
                ),
                LayoutBuilder(builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 600 && _pairs >= 3 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemCount: board.cards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns, crossAxisSpacing: 12,
                      mainAxisSpacing: 12, childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final picture = widget.pictures.firstWhere(
                        (p) => p.id == board.cards[index],
                      );
                      final visible = board.isVisible(index, keepVisible: _keepVisible);
                      final matched = board.isMatched(index);
                      return Semantics(
                        button: true, enabled: !matched,
                        onTap: matched ? null : () => setState(() { board.tap(index); }),
                        label: visible ? '${picture.label}, tile ${index + 1}'
                            : 'Hidden picture, tile ${index + 1}',
                        value: matched ? 'Matched' : board.isSelected(index) ? 'Selected' : '',
                        child: ExcludeSemantics(child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              width: matched || board.isSelected(index) ? 4 : 1,
                              color: matched || board.isSelected(index)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: matched ? null : () => setState(() { board.tap(index); }),
                            child: Stack(fit: StackFit.expand, children: [
                              Padding(padding: const EdgeInsets.all(8), child: visible
                                  ? PictureView(picture: picture)
                                  : const Icon(Icons.photo_outlined, size: 56)),
                              if (matched) const Positioned(
                                top: 8, right: 8, child: Icon(Icons.check_circle, size: 32),
                              ),
                            ]),
                          ),
                        )),
                      );
                    },
                  );
                }),
                const SizedBox(height: 20),
                Semantics(liveRegion: true, child: Text(
                  board.complete ? 'All pairs together. Play again or take a break.'
                      : board.waitingForNextTurn
                          ? 'Take your time. Tap a picture to continue.'
                          : 'There is no time limit.',
                  style: const TextStyle(fontSize: 20),
                )),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => setState(_start),
                  child: Text(board.complete ? 'Play again' : 'Start again'),
                ),
                TextButton(onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done for now')),
              ],
            )),
    );
  }
}
