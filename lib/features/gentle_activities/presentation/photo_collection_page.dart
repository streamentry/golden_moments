import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_importer.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhotoCollectionPage extends StatefulWidget {
  const PhotoCollectionPage({super.key});

  @override
  State<PhotoCollectionPage> createState() => _PhotoCollectionPageState();
}

class _PhotoCollectionPageState extends State<PhotoCollectionPage> {
  final _importer = PhotoImporter();
  FamilyPhotoStore? _store;
  List<String> _ids = [];
  bool _busy = true;
  String? _error;

  List<ActivityPicture> get _pictures => [
    for (var i = 0; i < _ids.length; i++)
      ActivityPicture(
        id: _ids[i],
        label: 'Family photo ${i + 1}',
        path: _store!.fileFor(_ids[i]).path,
      ),
  ];

  @override
  void initState() {
    super.initState();
    _load(recover: true);
  }

  Future<bool> _confirm(String title, String message) async {
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _load({bool recover = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final root = await getApplicationSupportDirectory();
      final store = FamilyPhotoStore(
        Directory('${root.path}/family_photos_v1'),
      );
      final ids = await store.load();
      if (!mounted) return;
      setState(() {
        _store = store;
        _ids = ids;
      });
      if (recover) {
        final recovered = await _importer.recover();
        if (recovered.isNotEmpty &&
            await _confirm(
              'Finish adding photos?',
              'The system recovered photos you selected before the app restarted. Add them to this device?',
            )) {
          await _saveFiles(recovered);
        }
      }
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'Could not open the photo collection. Your original photos have not been changed. Please try again.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveFiles(List<XFile> files) async {
    if (files.isEmpty) return;
    if (files.length > FamilyPhotoStore.maxPhotos - _ids.length) {
      throw const FormatException('Choose fewer photos.');
    }
    final images = <Uint8List>[];
    for (final file in files) {
      images.add(await _importer.normalize(file));
    }
    final ids = await _store!.add(images);
    if (mounted) setState(() => _ids = ids);
  }

  Future<void> _add() async {
    if (_busy || _store == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final files = await _importer.choose(
        FamilyPhotoStore.maxPhotos - _ids.length,
      );
      await _saveFiles(files);
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'Could not add these photos. Try fewer or smaller images, and check free space. Your existing collection is unchanged.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete({String? id}) async {
    if (_busy || _store == null) return;
    final confirmed = await _confirm(
      id == null ? 'Remove all photo copies?' : 'Remove this photo copy?',
      'This removes copies saved by Golden Moments. Originals in your photo library are not deleted.',
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (id == null) {
        await _store!.clear();
      } else {
        await _store!.remove(id);
      }
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'Some copies could not be removed. Please try again.',
        );
    } finally {
      try {
        final ids = await _store!.load();
        if (mounted) setState(() => _ids = ids);
      } catch (_) {
        if (mounted)
          setState(
            () => _error =
                'Could not refresh the collection. Please reopen this screen.',
          );
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pictures = _store == null ? <ActivityPicture>[] : _pictures;
    return Scaffold(
      appBar: AppBar(title: const Text('Your family photos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Choose photos you would enjoy looking at together.',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 12),
            const Text(
              'Only selected photos are copied into this app. No account or family-sync server. Copies may be included in your device backup.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  _busy ||
                      _store == null ||
                      _ids.length >= FamilyPhotoStore.maxPhotos
                  ? null
                  : _add,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Choose photos'),
            ),
            Text('${_ids.length} of ${FamilyPhotoStore.maxPhotos} photos'),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
            if (_error != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              TextButton(
                onPressed: _busy ? null : _load,
                child: const Text('Try again'),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy || pictures.length < 2
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => GentleGamePage(pictures: pictures),
                      ),
                    ),
              child: const Text('Play with these photos'),
            ),
            if (pictures.length < 2)
              const Text('Add at least two photos to make a matching game.'),
            OutlinedButton(
              onPressed: _busy || pictures.isEmpty
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PhotoTogetherPage(pictures: pictures),
                      ),
                    ),
              child: const Text('Look at photos together'),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pictures.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) => Card(
                child: Column(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: pictures[index].label,
                        child: PictureView(picture: pictures[index]),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove photo ${index + 1}',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _busy
                          ? null
                          : () => _delete(id: pictures[index].id),
                    ),
                  ],
                ),
              ),
            ),
            if (_ids.isNotEmpty)
              TextButton(
                onPressed: _busy ? null : _delete,
                child: const Text('Remove all photo copies'),
              ),
          ],
        ),
      ),
    );
  }
}
