import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';

/// Looking and talking are optional: this is not a recall or recognition test.
class PhotoTogetherPage extends StatefulWidget {
  const new({required this.pictures, super.key});
  final List<ActivityPicture> pictures;

  @override
  State<PhotoTogetherPage> createState() => _PhotoTogetherPageState();
}

class _PhotoTogetherPageState extends State<PhotoTogetherPage> {
  int _index = 0;
  bool _showPrompt = false;
  static const _prompts = [
    'What do you like about this picture?',
    'What catches your eye?',
    'Would you like to talk about this, or look at another picture?',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (widget.pictures.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Look together')),
        body: const Center(child: Text('Add a photo first.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Look together')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Semantics(
                  label: widget.pictures[_index].label,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: gmTileShape(Theme.of(context).colorScheme),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(gmSpaceSm),
                        child: PictureView(picture: widget.pictures[_index]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: gmSpaceMd),
                Text(
                  'Picture ${_index + 1} of ${widget.pictures.length}',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: gmSpaceMd),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: gmSpaceMd,
                  runSpacing: gmSpaceSm,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _index == 0
                          ? null
                          : () => setState(() => _index--),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                    FilledButton.icon(
                      onPressed: _index == widget.pictures.length - 1
                          ? null
                          : () => setState(() => _index++),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show a conversation prompt'),
                  value: _showPrompt,
                  onChanged: (value) => setState(() => _showPrompt = value),
                ),
                if (_showPrompt)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _prompts[_index % _prompts.length],
                      style: textTheme.headlineSmall,
                    ),
                  ),
                const SizedBox(height: gmSpaceMd),
                Text(
                  'Just looking is enough. There is no need to remember a name '
                  'or answer a question.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: gmSpaceSm),
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
