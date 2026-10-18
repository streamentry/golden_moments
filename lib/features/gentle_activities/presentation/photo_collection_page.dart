import 'dart:async';

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_annotations.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_importer.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_puzzle_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';
import 'package:golden_moments/shared/utils/experiments.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> _supportDirectory() async {
  final root = await getApplicationSupportDirectory();
  return Directory('${root.path}/family_photos_v1');
}

class PhotoCollectionPage extends StatefulWidget {
  /// The directory and importer can be replaced so the whole journey (choose,
  /// personalize, play, delete) runs in tests without a real photo picker.
  const new({
    this.directoryProvider = _supportDirectory,
    this.importer,
    super.key,
  });

  final Future<Directory> Function() directoryProvider;
  final PhotoImporter? importer;

  @override
  State<PhotoCollectionPage> createState() => _PhotoCollectionPageState();
}

class _PhotoCollectionPageState extends State<PhotoCollectionPage> {
  late final PhotoImporter _importer = widget.importer ?? PhotoImporter();
  FamilyPhotoStore? _store;
  PhotoAnnotationStore? _annotations;
  Map<String, PhotoAnnotation> _notes = {};
  List<String> _ids = [];
  bool _busy = true;
  String? _error;

  bool _isFavorite(String id) => _notes[id]?.favorite ?? false;
  bool _isHidden(String id) => _notes[id]?.hidden ?? false;

  /// Favorites come first so an enjoyed picture is easy to find. Hidden
  /// pictures stay in the collection; activities skip them.
  List<ActivityPicture> get _pictures {
    final ordered = [
      ..._ids.where(_isFavorite),
      ..._ids.where((id) => !_isFavorite(id)),
    ];
    return [
      for (var i = 0; i < ordered.length; i++)
        ActivityPicture(
          id: ordered[i],
          label: (_notes[ordered[i]]?.caption ?? '').isEmpty
              ? 'Family photo ${i + 1}'
              : _notes[ordered[i]]!.caption,
          caption: _notes[ordered[i]]?.caption ?? '',
          description: _notes[ordered[i]]?.description ?? '',
          path: _store!.fileFor(ordered[i]).path,
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load(recover: true));
  }

  Future<bool> _confirm(String title, String message) async {
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
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
      final directory = await widget.directoryProvider();
      final store = FamilyPhotoStore(directory);
      final ids = await store.load();
      // Optional details never block the photos; stale ones are dropped.
      final annotations = PhotoAnnotationStore(directory);
      final notes = await annotations.keepOnly(ids.toSet());
      if (!mounted) return;
      setState(() {
        _store = store;
        _annotations = annotations;
        _notes = notes;
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
      'This removes copies saved by Golden Moments on this device. '
      'Originals in your photo library are not deleted, and earlier '
      'device backups are not changed.',
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
        final notes = await _annotations!.keepOnly(ids.toSet());
        if (mounted) {
          setState(() {
            _ids = ids;
            _notes = notes;
          });
        }
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

  Widget _photoCard(ActivityPicture picture, ColorScheme scheme) {
    final favorite = _isFavorite(picture.id);
    final hidden = _isHidden(picture.id);
    return Card(
      elevation: 0,
      shape: gmTileShape(scheme),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(gmSpaceSm),
            child: AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                label: [
                  picture.label,
                  if (picture.description.isNotEmpty) picture.description,
                ].join('. '),
                child: Opacity(
                  opacity: hidden ? 0.45 : 1,
                  child: PictureView(picture: picture),
                ),
              ),
            ),
          ),
          // Words as well as icons: state is never colour or an icon alone.
          if (favorite || hidden)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: gmSpaceSm),
              child: Wrap(
                spacing: gmSpaceMd,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (favorite)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 20),
                        SizedBox(width: gmSpaceXs),
                        Text('Favorite'),
                      ],
                    ),
                  if (hidden)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_off, size: 20),
                        SizedBox(width: gmSpaceXs),
                        Text('Hidden'),
                      ],
                    ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: _busy ? null : () => _editPhoto(picture),
            icon: const Icon(Icons.tune),
            label: Text(
              'Photo options',
              semanticsLabel: 'Options for ${picture.label}',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPhoto(ActivityPicture picture) async {
    if (_busy || _annotations == null) return;
    final result = await showModalBottomSheet<_PhotoOptionsResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PhotoOptionsSheet(
        picture: picture,
        note: _notes[picture.id] ?? const PhotoAnnotation(),
      ),
    );
    if (result == null || !mounted) return;
    if (result.remove) {
      await _delete(id: picture.id);
      return;
    }
    try {
      final notes = await _annotations!.update(picture.id, result.note!);
      if (mounted) {
        setState(() {
          _notes = notes;
          _error = null;
        });
      }
    } on Object catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not save these details. Your photos have not been '
              'changed. Please try again.',
        );
      }
    }
  }

  /// Hiding from Look together is the same reversible Hide as in the photo
  /// options: the copy stays, and the game and later viewing skip it.
  Future<bool> _hideFromViewing(ActivityPicture picture) async {
    final annotations = _annotations;
    if (annotations == null) return false;
    final note = (_notes[picture.id] ?? const PhotoAnnotation()).copyWith(
      hidden: true,
    );
    try {
      final notes = await annotations.update(picture.id, note);
      if (mounted) setState(() => _notes = notes);
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pictures = _store == null ? <ActivityPicture>[] : _pictures;
    final playable = [
      for (final picture in pictures)
        if (!_isHidden(picture.id)) picture,
    ];
    final hiddenCount = pictures.length - playable.length;
    final favorites = [
      for (final picture in playable)
        if (_isFavorite(picture.id)) picture,
    ];
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // One filled button per screen: adding photos until a game is possible,
    // then playing.
    final canPlay = playable.length >= 2;
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
              builder: (_) =>
                  GentleGamePage(pictures: playable, sessionKey: 'family'),
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
                    hiddenCount > 0
                        ? 'Show at least two photos to make a matching game. '
                              '$hiddenCount hidden.'
                        : 'Add at least two photos to make a matching game.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                if (experimentsEnabled && playable.isNotEmpty) ...[
                  const SizedBox(height: gmSpaceMd),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  PicturePuzzlePage(pictures: playable),
                            ),
                          ),
                    icon: const Icon(Icons.extension_outlined),
                    label: const Text('Try a picture puzzle (experiment)'),
                  ),
                ],
                if (favorites.length >= 2) ...[
                  const SizedBox(height: gmSpaceMd),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => GentleGamePage(
                                pictures: favorites,
                                sessionKey: 'family-favorites',
                              ),
                            ),
                          ),
                    icon: const Icon(Icons.star_outline),
                    label: const Text('Play with favorites'),
                  ),
                ],
                const SizedBox(height: gmSpaceMd),
                OutlinedButton.icon(
                  onPressed: _busy || playable.isEmpty
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PhotoTogetherPage(
                              pictures: playable,
                              onHide: _hideFromViewing,
                            ),
                          ),
                        ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Look at photos together'),
                ),
                const SizedBox(height: gmSpaceLg),
                // Cards grow with the text instead of shrinking it: one column
                // at large text, otherwise as many 180+ wide cards as fit.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final largeText =
                        MediaQuery.textScalerOf(context).scale(16) / 16 > 1.5;
                    final columns = largeText
                        ? 1
                        : ((constraints.maxWidth + gmTileGap) /
                                  (180 + gmTileGap))
                              .floor()
                              .clamp(1, 3);
                    final width =
                        (constraints.maxWidth - gmTileGap * (columns - 1)) /
                        columns;
                    return Wrap(
                      spacing: gmTileGap,
                      runSpacing: gmTileGap,
                      children: [
                        for (final picture in pictures)
                          SizedBox(
                            width: width,
                            child: _photoCard(picture, scheme),
                          ),
                      ],
                    );
                  },
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

class _PhotoOptionsResult {
  const new save(PhotoAnnotation this.note) : remove = false;
  const new remove() : note = null, remove = true;
  final PhotoAnnotation? note;
  final bool remove;
}

/// Everything here is optional. Hiding keeps the copy and is undone by turning
/// the switch off; removing deletes the app's copy and is a separate action.
class _PhotoOptionsSheet extends StatefulWidget {
  const new({required this.picture, required this.note});
  final ActivityPicture picture;
  final PhotoAnnotation note;

  @override
  State<_PhotoOptionsSheet> createState() => _PhotoOptionsSheetState();
}

class _PhotoOptionsSheetState extends State<_PhotoOptionsSheet> {
  late final _caption = TextEditingController(text: widget.note.caption);
  late final _description = TextEditingController(
    text: widget.note.description,
  );
  late bool _favorite = widget.note.favorite;
  late bool _hidden = widget.note.hidden;

  @override
  void dispose() {
    _caption.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.pop(
      context,
      _PhotoOptionsResult.save(
        PhotoAnnotation(
          caption: PhotoAnnotation.normalizeText(
            _caption.text,
            PhotoAnnotation.maxCaption,
          ),
          description: PhotoAnnotation.normalizeText(
            _description.text,
            PhotoAnnotation.maxDescription,
          ),
          favorite: _favorite,
          hidden: _hidden,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          gmSpaceLg,
          0,
          gmSpaceLg,
          gmSpaceLg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Photo options', style: theme.textTheme.headlineSmall),
            const SizedBox(height: gmSpaceSm),
            Text(
              'All of this is optional and stays on this device.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: gmSpaceMd),
            TextField(
              controller: _caption,
              maxLength: PhotoAnnotation.maxCaption,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Caption (optional)',
                helperText: 'Shown only when you choose to show captions.',
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            TextField(
              controller: _description,
              maxLength: PhotoAnnotation.maxDescription,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description for screen readers (optional)',
                helperText: 'Read aloud while the picture is showing.',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Favorite'),
              subtitle: const Text('Shows this photo first.'),
              value: _favorite,
              onChanged: (value) => setState(() => _favorite = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hide from activities'),
              subtitle: const Text(
                'Keeps the copy on this device. Turn off to bring it back.',
              ),
              value: _hidden,
              onChanged: (value) => setState(() => _hidden = value),
            ),
            const SizedBox(height: gmSpaceSm),
            FilledButton(onPressed: _save, child: const Text('Save')),
            const SizedBox(height: gmSpaceSm),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(height: gmSpaceSm),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () =>
                  Navigator.pop(context, const _PhotoOptionsResult.remove()),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove this copy'),
            ),
          ],
        ),
      ),
    );
  }
}
