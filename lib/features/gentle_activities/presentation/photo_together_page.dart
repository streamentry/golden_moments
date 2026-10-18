import 'package:flutter/material.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';

/// Looking and talking are optional: this is not a recall or recognition test.
class PhotoTogetherPage extends StatefulWidget {
  const PhotoTogetherPage({required this.pictures, super.key});
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
    if (widget.pictures.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Look together')),
          body: const Center(child: Text('Add a photo first.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Look together')),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
        Semantics(
          label: widget.pictures[_index].label,
          child: AspectRatio(aspectRatio: 1, child: PictureView(
            picture: widget.pictures[_index],
          )),
        ),
        const SizedBox(height: 16),
        Text('Picture ${_index + 1} of ${widget.pictures.length}',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 12),
        Wrap(alignment: WrapAlignment.center, spacing: 16, runSpacing: 8, children: [
          OutlinedButton.icon(
            onPressed: _index == 0 ? null : () => setState(() => _index--),
            icon: const Icon(Icons.arrow_back), label: const Text('Previous'),
          ),
          FilledButton.icon(
            onPressed: _index == widget.pictures.length - 1
                ? null : () => setState(() => _index++),
            icon: const Icon(Icons.arrow_forward), label: const Text('Next'),
          ),
        ]),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show a conversation prompt'),
          value: _showPrompt,
          onChanged: (value) => setState(() => _showPrompt = value),
        ),
        if (_showPrompt) Text(_prompts[_index % _prompts.length],
            style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 12),
        const Text('Just looking is enough. There is no need to remember a name or answer a question.'),
      ])),
    );
  }
}
