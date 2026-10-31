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
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/utils/experiments.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> _supportDirectory() async {
  final root = await getApplicationSupportDirectory();
  return Directory('${root.path}/family_photos_v1');
}

/// What went wrong, kept as a reason rather than as text so the message
/// follows the reader's language.
enum _Problem {
  newerVersion,
  unreadable,
  cannotOpen,
  cannotCheck,
  cannotAdd,
  cannotRemove,
  cannotRefresh,
  cannotSaveDetails,
}

String _problemText(AppLocalizations l10n, _Problem problem) =>
    switch (problem) {
      _Problem.newerVersion => l10n.photosErrorNewerVersion,
      _Problem.unreadable => l10n.photosErrorUnreadable,
      _Problem.cannotOpen => l10n.photosErrorCannotOpen,
      _Problem.cannotCheck => l10n.photosErrorCannotCheck,
      _Problem.cannotAdd => l10n.photosErrorCannotAdd,
      _Problem.cannotRemove => l10n.photosErrorCannotRemove,
      _Problem.cannotRefresh => l10n.photosErrorCannotRefresh,
      _Problem.cannotSaveDetails => l10n.photosErrorCannotSaveDetails,
    };

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
  _Problem? _error;

  /// The photo list is damaged in a way the person may choose to recover
  /// from by setting it aside (never automatic).
  bool _canRecover = false;

  bool _isFavorite(String id) => _notes[id]?.favorite ?? false;
  bool _isHidden(String id) => _notes[id]?.hidden ?? false;

  /// Favorites come first so an enjoyed picture is easy to find. Hidden
  /// pictures stay in the collection; activities skip them.
  List<ActivityPicture> get _pictures {
    final l10n = context.l10n;
    final ordered = [
      ..._ids.where(_isFavorite),
      ..._ids.where((id) => !_isFavorite(id)),
    ];
    return [
      for (var i = 0; i < ordered.length; i++)
        ActivityPicture(
          id: ordered[i],
          label: (_notes[ordered[i]]?.caption ?? '').isEmpty
              ? l10n.photosFamilyPhotoNumber(i + 1)
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

  /// Asks before acting. For a [destructive] step, keeping things as they
  /// are is the safe choice and so the primary action (DESIGN.md › Dialogs).
  Future<bool> _confirm(
    String title,
    String message, {
    String? confirmLabel,
    String? keepLabel,
    bool destructive = false,
  }) async {
    if (!mounted) return false;
    final keep = keepLabel ?? context.l10n.commonCancel;
    final confirmText = confirmLabel ?? context.l10n.commonContinue;
    final confirm = Text(confirmText, textAlign: TextAlign.center);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            title: Text(title),
            content: Text(message),
            actions: destructive
                ? gmDialogActions(
                    other: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: confirm,
                    ),
                    primary: FilledButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(keep, textAlign: TextAlign.center),
                    ),
                    labels: (confirmText, keep),
                  )
                : gmDialogActions(
                    other: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(keep, textAlign: TextAlign.center),
                    ),
                    primary: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: confirm,
                    ),
                    labels: (keep, confirmText),
                  ),
          ),
        ) ??
        false;
  }

  Future<void> _load({bool recover = false}) async {
    setState(() {
      _busy = true;
      _error = null;
      _canRecover = false;
    });
    try {
      final directory = await widget.directoryProvider();
      final store = FamilyPhotoStore(directory);
      final ids = await store.load();
      // Optional details never block the photos. Only details of photos the
      // collection no longer lists are dropped, never those of a photo that
      // merely cannot be shown right now.
      final annotations = PhotoAnnotationStore(directory);
      final notes = await annotations.keepOnly((await store.listed()).toSet());
      if (!mounted) return;
      setState(() {
        _store = store;
        _annotations = annotations;
        _notes = notes;
        _ids = ids;
      });
      if (recover) {
        final recovered = await _importer.recover();
        if (recovered.isNotEmpty && mounted) {
          final l10n = context.l10n;
          if (await _confirm(
            l10n.photosRecoveredTitle,
            l10n.photosRecoveredMessage,
          )) {
            await _saveFiles(recovered);
          }
        }
      }
    } on UnreadablePhotoList catch (problem) {
      if (mounted) {
        setState(() {
          _error = problem.fromNewerVersion
              ? _Problem.newerVersion
              : _Problem.unreadable;
          _canRecover = problem.canSetAside;
        });
      }
    } on Object catch (_) {
      if (mounted) {
        setState(() => _error = _Problem.cannotOpen);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The error, then its way forward: the recovery when the list is
  /// damaged, and always Try again.
  List<Widget> _problem(ThemeData theme) {
    final scheme = theme.colorScheme;
    return [
      Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: scheme.error),
            const SizedBox(width: gmSpaceSm),
            Expanded(
              child: Text(
                _problemText(context.l10n, _error!),
                style: theme.textTheme.bodyLarge?.copyWith(color: scheme.error),
              ),
            ),
          ],
        ),
      ),
      if (_canRecover) ...[
        const SizedBox(height: gmSpaceSm),
        OutlinedButton.icon(
          onPressed: _busy ? null : _recover,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(context.l10n.photosShowMyPhotos),
        ),
      ],
      TextButton(
        onPressed: _busy ? null : _load,
        child: Text(context.l10n.commonTryAgain),
      ),
    ];
  }

  /// Only at the person's request: keeps the unreadable list aside and shows
  /// every copy that can be checked, with its details. The dialog says
  /// exactly what happens to a copy that cannot be checked.
  Future<void> _recover() async {
    final l10n = context.l10n;
    final ok = await _confirm(
      l10n.photosRecoverTitle,
      l10n.photosRecoverMessage,
      confirmLabel: l10n.photosRecoverConfirm,
      keepLabel: l10n.photosNotNow,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      final directory = await widget.directoryProvider();
      await FamilyPhotoStore(directory).setAsideDamagedList();
    } on Object catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _Problem.cannotCheck;
        });
      }
      return;
    }
    if (mounted) await _load();
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
        setState(() => _error = _Problem.cannotAdd);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete({String? id}) async {
    if (_busy || _store == null) return;
    final l10n = context.l10n;
    final confirmed = await _confirm(
      id == null ? l10n.photosRemoveAllTitle : l10n.photosRemoveOneTitle,
      l10n.photosRemoveMessage,
      // Say what the button does; a destructive step is never 'Continue'.
      confirmLabel: id == null
          ? l10n.photosRemoveAllConfirm
          : l10n.photosRemoveOneConfirm,
      destructive: true,
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
        setState(() => _error = _Problem.cannotRemove);
      }
    } finally {
      try {
        final ids = await _store!.load();
        final notes = await _annotations!.keepOnly(
          (await _store!.listed()).toSet(),
        );
        if (mounted) {
          setState(() {
            _ids = ids;
            _notes = notes;
          });
        }
      } on Object catch (_) {
        if (mounted) {
          setState(() => _error = _Problem.cannotRefresh);
        }
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _photoCard(ActivityPicture picture, ColorScheme scheme) {
    final l10n = context.l10n;
    final favorite = _isFavorite(picture.id);
    final hidden = _isHidden(picture.id);
    // A print in a family album: the photo cropped to a square and mounted
    // in the linen card, with its state and Options in a caption strip.
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(gmSpaceSm),
            child: AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                label: picture.description.isEmpty
                    ? picture.label
                    : l10n.photosLabelWithDescription(
                        picture.label,
                        picture.description,
                      ),
                child: Opacity(
                  opacity: hidden ? 0.45 : 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(gmRadiusMd),
                    child: ColoredBox(
                      color: gmSurf200,
                      child: PictureView(picture: picture, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            indent: gmSpaceSm,
            endIndent: gmSpaceSm,
          ),
          // Words as well as icons: state is never colour or an icon alone.
          if (favorite || hidden)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                gmSpaceMd,
                gmSpaceSm,
                gmSpaceMd,
                0,
              ),
              child: Wrap(
                spacing: gmSpaceMd,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (favorite)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 20),
                        const SizedBox(width: gmSpaceXs),
                        Text(l10n.photosFavoriteBadge),
                      ],
                    ),
                  if (hidden)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_off, size: 20),
                        const SizedBox(width: gmSpaceXs),
                        Text(l10n.photosHiddenBadge),
                      ],
                    ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: _busy ? null : () => _editPhoto(picture),
            icon: const Icon(Icons.tune),
            // Short enough to stay on one line in two columns on a large
            // phone; the photo above and the spoken label give the context.
            label: Text(
              l10n.photosOptions,
              semanticsLabel: l10n.photosOptionsFor(picture.label),
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
    setState(() {
      _busy = true;
      _error = null;
    });
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
        setState(() => _error = _Problem.cannotSaveDetails);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
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
    final l10n = context.l10n;
    // One filled button per screen: adding photos until a game is possible,
    // then playing.
    final canPlay = playable.length >= 2;
    final onChoose =
        _busy || _store == null || _ids.length >= FamilyPhotoStore.maxPhotos
        ? null
        : _add;
    const chooseIcon = Icon(Icons.add_photo_alternate_outlined);
    final chooseLabel = Text(l10n.photosChoosePhotos);
    final onPlay = _busy || !canPlay
        ? null
        : () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  GentleGamePage(pictures: playable, sessionKey: 'family'),
            ),
          );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: GmTitle(l10n.commonYourFamilyPhotos),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(gmSpaceLg),
              children: [
                // The collection could not open: say so first, with the way
                // forward, rather than below an intro and a dead button.
                if (_error != null && _store == null) ...[
                  ..._problem(theme),
                  const SizedBox(height: gmSpaceLg),
                ],
                Text(l10n.photosIntro, style: theme.textTheme.headlineSmall),
                const SizedBox(height: gmSpaceMd),
                Text(
                  l10n.photosPrivacyNote,
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
                  l10n.photosCount(_ids.length, FamilyPhotoStore.maxPhotos),
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
                // An error about an action stays beside it; one that kept the
                // collection from opening is shown first (above).
                if (_error != null && _store != null) ...[
                  const SizedBox(height: gmSpaceMd),
                  ..._problem(theme),
                ],
                const SizedBox(height: gmSpaceLg),
                if (canPlay)
                  FilledButton.icon(
                    onPressed: onPlay,
                    icon: const Icon(Icons.grid_view),
                    label: Text(l10n.photosPlay),
                  )
                else
                  Text(
                    hiddenCount > 0
                        ? l10n.photosNeedTwoShowHidden(hiddenCount)
                        : l10n.photosNeedTwoAdd,
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
                    label: Text(l10n.photosTryPuzzle),
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
                    label: Text(l10n.photosPlayFavorites),
                  ),
                ],
                // Offered once there is something to look at, rather than
                // shown greyed out, which can read as broken.
                if (playable.isNotEmpty) ...[
                  const SizedBox(height: gmSpaceMd),
                  OutlinedButton.icon(
                    onPressed: _busy
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
                    label: Text(l10n.photosLookTogether),
                  ),
                ],
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
                    label: Text(l10n.photosRemoveAll),
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
    final l10n = context.l10n;
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
            Text(l10n.photosOptionsTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: gmSpaceSm),
            Text(
              l10n.photosOptionsIntro,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: gmSpaceMd),
            TextField(
              controller: _caption,
              maxLength: PhotoAnnotation.maxCaption,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.photosCaptionLabel,
                helperText: l10n.photosCaptionHelper,
                // Wraps instead of being cut off beside the counter.
                helperMaxLines: 3,
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            TextField(
              controller: _description,
              maxLength: PhotoAnnotation.maxDescription,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.photosDescriptionLabel,
                helperText: l10n.photosDescriptionHelper,
                // Wraps instead of being cut off beside the counter.
                helperMaxLines: 3,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: GmTitle(l10n.photosFavoriteSwitchTitle),
              subtitle: GmTitle(l10n.photosFavoriteSwitchSubtitle),
              value: _favorite,
              onChanged: (value) => setState(() => _favorite = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: GmTitle(l10n.photosHideSwitchTitle),
              subtitle: Text(l10n.photosHideSwitchSubtitle),
              value: _hidden,
              onChanged: (value) => setState(() => _hidden = value),
            ),
            const SizedBox(height: gmSpaceSm),
            // Full width like every sheet's actions; Save is the primary.
            GmButtonPair(
              first: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonCancel, textAlign: TextAlign.center),
              ),
              second: FilledButton(
                onPressed: _save,
                child: Text(l10n.commonSave, textAlign: TextAlign.center),
              ),
              labels: (l10n.commonCancel, l10n.commonSave),
              secondOnTop: true,
            ),
            const SizedBox(height: gmSpaceSm),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () =>
                  Navigator.pop(context, const _PhotoOptionsResult.remove()),
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.photosRemoveThisCopy),
            ),
          ],
        ),
      ),
    );
  }
}
