import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
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
              'The system recovered photos you selected before the app '
                  'restarted. Add them to this device?',
            )) {
          await _saveFiles(recovered);
        }
      }
    } on Object catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not open the photo collection. '
              'Your original photos have not been changed. Please try again.',
        );
      }
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
    } on Object catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not add these photos. Try fewer or smaller images, '
              'and check free space. Your existing collection is unchanged.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete({String? id}) async {
    if (_busy || _store == null) return;
    final confirmed = await _confirm(
      id == null ? 'Remove all photo copies?' : 'Remove this photo copy?',
      'This removes copies saved by Golden Moments. Originals '
      'in your photo library are not deleted.',
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
    } on Object catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Some copies could not be removed. Please try again.',
        );
      }
    } finally {
      try {
        final ids = await _store!.load();
        if (mounted) setState(() => _ids = ids);
      } on Object catch (_) {
        if (mounted) {
          setState(
            () => _error =
                'Could not refresh the collection. Please reopen this screen.',
          );
        }
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pictures = _store == null ? <ActivityPicture>[] : _pictures;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // One filled button per screen: adding photos until a game is possible,
    // then playing.
    final canPlay = pictures.length >= 2;
    final onChoose =
        _busy || _store == null || _ids.length >= FamilyPhotoStore.maxPhotos
        ? null
        : _add;
    const chooseIcon = Icon(Icons.add_photo_alternate_outlined);
    const chooseLabel = Text('Choose photos');
    final onPlay = _busy || !canPlay
        ? null
        : () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => GentleGamePage(pictures: pictures),
            ),
          );
    return Scaffold(
      appBar: AppBar(title: const Text('Your family photos')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                Text(
                  'Choose photos you would enjoy looking at together.',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: gmSpaceMd),
                Text(
                  'Only selected photos are copied into this app. No account '
                  'or family-sync server. Copies may be included in your '
                  'device backup.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: gmSpaceLg),
                if (canPlay)
                  OutlinedButton.icon(
                    onPressed: onChoose,
                    icon: chooseIcon,
                    label: chooseLabel,
                  )
                else
                  FilledButton.icon(
                    onPressed: onChoose,
                    icon: chooseIcon,
                    label: chooseLabel,
                  ),
                const SizedBox(height: gmSpaceSm),
                Text(
                  '${_ids.length} of ${FamilyPhotoStore.maxPhotos} photos',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.all(gmSpaceMd),
                    child: LinearProgressIndicator(),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: gmSpaceMd),
                  Semantics(
                    liveRegion: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: scheme.error),
                        const SizedBox(width: gmSpaceSm),
                        Expanded(
                          child: Text(
                            _error!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _load,
                    child: const Text('Try again'),
                  ),
                ],
                const SizedBox(height: gmSpaceLg),
                if (canPlay)
                  FilledButton.icon(
                    onPressed: onPlay,
                    icon: const Icon(Icons.grid_view),
                    label: const Text('Play with these photos'),
                  )
                else
                  Text(
                    'Add at least two photos to make a matching game.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: gmSpaceMd),
                OutlinedButton.icon(
                  onPressed: _busy || pictures.isEmpty
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PhotoTogetherPage(pictures: pictures),
                          ),
                        ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Look at photos together'),
                ),
                const SizedBox(height: gmSpaceLg),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pictures.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: gmTileGap,
                    mainAxisSpacing: gmTileGap,
                  ),
                  itemBuilder: (context, index) => Card(
                    elevation: 0,
                    shape: gmTileShape(scheme),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(gmSpaceSm),
                            child: Semantics(
                              label: pictures[index].label,
                              child: PictureView(picture: pictures[index]),
                            ),
                          ),
                        ),
                        // Scales down rather than overflowing a narrow card at
                        // very large text sizes.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: TextButton.icon(
                            onPressed: _busy
                                ? null
                                : () => _delete(id: pictures[index].id),
                            icon: const Icon(Icons.delete_outline),
                            label: Text(
                              'Remove',
                              semanticsLabel: 'Remove photo ${index + 1}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_ids.isNotEmpty) ...[
                  const SizedBox(height: gmSpaceMd),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: scheme.error),
                    onPressed: _busy ? null : _delete,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Remove all photo copies'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
