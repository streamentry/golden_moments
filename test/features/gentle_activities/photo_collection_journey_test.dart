import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/data/family_photo_store.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_annotations.dart';
import 'package:golden_moments/features/gentle_activities/data/photo_importer.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_collection_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Replaces only the system picker and image decoder; storage, annotations
/// and every screen are the real ones working on a real temporary directory.
class _FakeImporter extends PhotoImporter {
  new(this.batches);
  final List<List<int>> batches;
  Exception? failWith;

  @override
  Future<List<XFile>> choose(int remaining) async {
    if (failWith != null) throw failWith!;
    return [
      for (final value in batches.removeAt(0))
        XFile.fromData(Uint8List.fromList([value])),
    ];
  }

  @override
  Future<Uint8List> normalize(XFile file) async => Uint8List.fromList([
    137, 80, 78, 71, 13, 10, 26, 10, // PNG signature, as the store requires
    ...await file.readAsBytes(),
  ]);

  @override
  Future<List<XFile>> recover() async => [];
}

Widget _app(Directory directory, PhotoImporter importer) => MaterialApp(
  theme: gmBuildTheme(),
  home: PhotoCollectionPage(
    directoryProvider: () async => directory,
    importer: importer,
  ),
);

/// Real file I/O needs real time and each awaited step resumes on a pump, so
/// alternate short real waits with frames. The page shows a progress bar
/// while it is working, so wait until that has been gone for a while rather
/// than for a fixed time (which is flaky under load).
Future<void> _settle(WidgetTester tester) async {
  var quiet = 0;
  for (var i = 0; i < 1500 && quiet < 40; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 8)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    quiet = find.byType(LinearProgressIndicator).evaluate().isEmpty
        ? quiet + 1
        : 0;
  }
}

/// Taps [text], then waits for the work to finish. Saving photo details
/// shows no progress bar, so a quiet screen alone does not prove the write
/// is done; when the outcome is visible, wait for that [until] condition
/// instead of guessing from time (which fails on a busy machine).
Future<void> _tapText(
  WidgetTester tester,
  String text, {
  bool Function()? until,
}) async {
  final finder = find.text(text).hitTestable();
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  if (until != null) {
    for (var i = 0; i < 2000 && !until(); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 8)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(until(), isTrue, reason: 'Gave up waiting after tapping "$text".');
  }
  await _settle(tester);
}

/// Presses a confirmation dialog's filled button, whatever its label, then
/// waits for [until] like [_tapText].
Future<void> _confirmDialog(
  WidgetTester tester, {
  required bool Function() until,
}) async {
  await tester.tap(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(FilledButton),
    ),
  );
  for (var i = 0; i < 2000 && !until(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 8)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(until(), isTrue, reason: 'Gave up waiting after confirming.');
  await _settle(tester);
}

bool _shows(Finder finder, [int count = 1]) =>
    finder.evaluate().length == count;

Future<void> _openOptions(WidgetTester tester, int index) async {
  final button = find.textContaining('Photo options').at(index);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await _settle(tester);
}

Future<void> _toggle(WidgetTester tester, String title) async {
  final tile = find.widgetWithText(SwitchListTile, title);
  await tester.ensureVisible(tile);
  await tester.tap(tile);
  await tester.pump();
}

void main() {
  late Directory directory;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('golden-journey-');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  testWidgets('choose, personalize, play, hide, restart and delete', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final importer = _FakeImporter([
      [1, 2, 3],
    ]);
    await tester.pumpWidget(_app(directory, importer));
    await _settle(tester);

    // Nothing is needed first: an empty collection explains itself.
    expect(find.textContaining('Add at least two photos'), findsOneWidget);
    expect(find.text('Play with these photos'), findsNothing);

    // Choose three photos through the picker; originals are never touched.
    await _tapText(tester, 'Choose photos');
    expect(find.textContaining('Photo options'), findsNWidgets(3));
    expect(find.text('3 of 24 photos'), findsOneWidget);
    expect(find.text('Play with these photos'), findsOneWidget);

    // Personalize the first photo: caption, description, favorite.
    await _openOptions(tester, 0);
    await tester.enterText(
      find.widgetWithText(TextField, 'Caption (optional)'),
      '  Lake   day ',
    );
    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Description for screen readers (optional)',
      ),
      'Two people on a wooden dock.',
    );
    await _toggle(tester, 'Favorite');
    await _tapText(tester, 'Save', until: () => _shows(find.text('Favorite')));
    expect(find.text('Favorite'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Lake day. Two people on a wooden dock.')),
      findsOneWidget,
    );

    // Hiding is reversible and visible; the copy stays.
    await _openOptions(tester, 1);
    await _toggle(tester, 'Hide from activities');
    await _tapText(tester, 'Save', until: () => _shows(find.text('Hidden')));
    expect(find.text('Hidden'), findsOneWidget);
    expect(find.text('Play with these photos'), findsOneWidget);
    await _openOptions(tester, 2);
    await _toggle(tester, 'Hide from activities');
    await _tapText(tester, 'Save', until: () => _shows(find.text('Hidden'), 2));
    // Only one photo is left to play with: no silent un-hiding.
    expect(find.text('Play with these photos'), findsNothing);
    expect(find.textContaining('Show at least two photos'), findsOneWidget);
    expect(find.text('3 of 24 photos'), findsOneWidget);
    await _openOptions(tester, 2);
    await _toggle(tester, 'Hide from activities');
    await _tapText(tester, 'Save', until: () => _shows(find.text('Hidden')));
    expect(find.text('Hidden'), findsOneWidget);

    // A restart keeps photos, captions, favorites and hidden state.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(directory, importer));
    await _settle(tester);
    expect(find.text('3 of 24 photos'), findsOneWidget);
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('Hidden'), findsOneWidget);

    // Remove is separate from Hide and cleans up what was written about it.
    final before = await tester.runAsync(
      () => FamilyPhotoStore(directory).load(),
    );
    expect(before!.length, 3);
    await _openOptions(tester, 0);
    await _tapText(tester, 'Remove this copy');
    expect(find.text('Remove this photo copy?'), findsOneWidget);
    await _tapText(
      tester,
      'Continue',
      until: () => _shows(find.text('2 of 24 photos')),
    );
    expect(find.text('2 of 24 photos'), findsOneWidget);
    final after = await tester.runAsync(
      () => FamilyPhotoStore(directory).load(),
    );
    expect(after!.length, 2);
    final notes = await tester.runAsync(
      () => PhotoAnnotationStore(directory).load(),
    );
    expect(notes!.keys.every(after.contains), isTrue);
  });

  testWidgets('a hidden photo never reaches the game', (tester) async {
    await tester.binding.setSurfaceSize(const Size(480, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final importer = _FakeImporter([
      [1, 2, 3],
    ]);
    await tester.pumpWidget(_app(directory, importer));
    await _settle(tester);
    await _tapText(tester, 'Choose photos');
    await _openOptions(tester, 1);
    await _toggle(tester, 'Hide from activities');
    await _tapText(tester, 'Save', until: () => _shows(find.text('Hidden')));

    await _tapText(tester, 'Play with these photos');
    expect(find.text('Gentle photo match'), findsOneWidget);
    final labels = [
      for (final node
          in find.bySemanticsLabel(RegExp(r', tile \d+$')).evaluate())
        (node.widget as Semantics).properties.label!.split(',').first,
    ];
    expect(labels.length, 4);
    expect(labels.toSet(), {'Family photo 1', 'Family photo 3'});
    expect(find.text('Done for now'), findsOneWidget);
  });

  testWidgets('photo cards grow with 200% text instead of shrinking it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 3200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final importer = _FakeImporter([
      [1, 2],
    ]);
    Widget big() => MaterialApp(
      theme: gmBuildTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(2)),
        child: child!,
      ),
      home: PhotoCollectionPage(
        directoryProvider: () async => directory,
        importer: importer,
      ),
    );
    await tester.pumpWidget(big());
    await _settle(tester);
    final choose = find.text('Choose photos');
    await tester.tap(choose);
    await _settle(tester);

    final options = find.textContaining('Photo options');
    expect(options, findsNWidgets(2));
    // Real size, never scaled down: no FittedBox around the label, and the
    // button keeps the 48 point floor.
    expect(
      find.ancestor(of: options.first, matching: find.byType(FittedBox)),
      findsNothing,
    );
    final button = find.ancestor(
      of: options.first,
      matching: find.byType(TextButton),
    );
    expect(tester.getSize(button.first).height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Play with favorites needs two and uses only favorites', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final importer = _FakeImporter([
      [1, 2, 3],
    ]);
    await tester.pumpWidget(_app(directory, importer));
    await _settle(tester);
    await _tapText(tester, 'Choose photos');
    expect(find.text('Play with favorites'), findsNothing);
    // Experiments are off in normal builds.
    expect(find.textContaining('picture puzzle'), findsNothing);

    await _openOptions(tester, 0);
    await _toggle(tester, 'Favorite');
    await _tapText(tester, 'Save', until: () => _shows(find.text('Favorite')));
    // One favorite is not enough for a game of its own.
    expect(find.text('Play with favorites'), findsNothing);

    await _openOptions(tester, 1);
    await _toggle(tester, 'Favorite');
    await _tapText(
      tester,
      'Save',
      until: () => _shows(find.text('Play with favorites')),
    );
    expect(find.text('Play with favorites'), findsOneWidget);
    // Still exactly one filled button on this screen.
    expect(find.byType(FilledButton), findsNWidgets(1));

    await _tapText(tester, 'Play with favorites');
    expect(find.text('Gentle photo match'), findsOneWidget);
    final labels = [
      for (final node
          in find.bySemanticsLabel(RegExp(r', tile \d+$')).evaluate())
        (node.widget as Semantics).properties.label!.split(',').first,
    ];
    expect(labels.length, 4);
    // Favorites sort first, so the non-favorite is "Family photo 3".
    expect(labels.toSet(), {'Family photo 1', 'Family photo 2'});
    expect(
      find.textContaining(RegExp('score|streak|move', caseSensitive: false)),
      findsNothing,
    );
  });

  testWidgets('a failed import leaves the collection and says what to do', (
    tester,
  ) async {
    final importer = _FakeImporter([
      [1, 2],
    ]);
    await tester.pumpWidget(_app(directory, importer));
    await _settle(tester);
    await _tapText(tester, 'Choose photos');
    expect(find.text('2 of 24 photos'), findsOneWidget);

    importer.failWith = const FileSystemException('No space left on device');
    await _tapText(tester, 'Choose photos');
    expect(find.textContaining('check free space'), findsOneWidget);
    expect(
      find.textContaining('existing collection is unchanged'),
      findsOneWidget,
    );
    expect(find.text('2 of 24 photos'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final ids = await tester.runAsync(() => FamilyPhotoStore(directory).load());
    expect(ids!.length, 2);
  });

  testWidgets('a damaged annotations file never hides the photos', (
    tester,
  ) async {
    final importer = _FakeImporter([
      [1, 2],
    ]);
    await tester.pumpWidget(_app(directory, importer));
    await _settle(tester);
    await _tapText(tester, 'Choose photos');
    await tester.runAsync(
      () => File('${directory.path}/annotations.json').writeAsString('{oops'),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(directory, importer));
    await _settle(tester);
    expect(find.text('2 of 24 photos'), findsOneWidget);
    expect(find.text('Play with these photos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'when nothing can be written, every change says so and keeps the photos',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final importer = _FakeImporter([
        [1, 2],
        [3],
      ]);
      await tester.pumpWidget(_app(directory, importer));
      await _settle(tester);
      await _tapText(tester, 'Choose photos');
      expect(find.text('2 of 24 photos'), findsOneWidget);

      // A read-only folder refuses every write, the way a full or protected
      // disk does. Root ignores permissions, so the check is skipped there.
      void chmod(String mode) =>
          Process.runSync('chmod', [mode, directory.path]);
      chmod('555');
      addTearDown(() => chmod('755'));
      final probe = File('${directory.path}/probe');
      final writable = await tester.runAsync(() async {
        try {
          await probe.create();
          await probe.delete();
          return true;
        } on FileSystemException {
          return false;
        }
      });
      if (writable!) {
        markTestSkipped('This user can write to read-only folders.');
        return;
      }

      await _tapText(tester, 'Choose photos');
      expect(find.textContaining('check free space'), findsOneWidget);
      expect(find.text('2 of 24 photos'), findsOneWidget);

      await _openOptions(tester, 0);
      await _toggle(tester, 'Favorite');
      final notSaved = find.textContaining('Could not save these details');
      await _tapText(tester, 'Save', until: () => _shows(notSaved));
      expect(notSaved, findsOneWidget);
      expect(find.text('Favorite'), findsNothing);

      await _openOptions(tester, 0);
      await _tapText(tester, 'Remove this copy');
      final notRemoved = find.textContaining('could not be removed');
      await _confirmDialog(tester, until: () => _shows(notRemoved));
      expect(notRemoved, findsOneWidget);
      expect(find.text('2 of 24 photos'), findsOneWidget);

      await _tapText(tester, 'Remove all photo copies');
      await _confirmDialog(tester, until: () => _shows(notRemoved));
      expect(notRemoved, findsOneWidget);
      expect(find.text('2 of 24 photos'), findsOneWidget);
      expect(tester.takeException(), isNull);

      chmod('755');
      final ids = await tester.runAsync(
        () => FamilyPhotoStore(directory).load(),
      );
      expect(ids, hasLength(2));
    },
    skip: Platform.isWindows,
  );

  testWidgets(
    'a collection that cannot be read for a moment never prunes photo details',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final importer = _FakeImporter([
        [1, 2],
      ]);
      await tester.pumpWidget(_app(directory, importer));
      await _settle(tester);
      await _tapText(tester, 'Choose photos');
      await _openOptions(tester, 0);
      await _toggle(tester, 'Favorite');
      await _tapText(
        tester,
        'Save',
        until: () => _shows(find.text('Favorite')),
      );
      final sidecar = File('${directory.path}/annotations.json');
      final details = await tester.runAsync(sidecar.readAsBytes);

      // The details are only pruned by a list the collection really holds.
      // An unreadable index must stop the screen, not empty that list.
      final manifest = File('${directory.path}/collection.json');
      void chmod(String mode) =>
          Process.runSync('chmod', [mode, manifest.path]);
      chmod('000');
      addTearDown(() => chmod('644'));
      final readable = await tester.runAsync(() async {
        try {
          await manifest.readAsBytes();
          return true;
        } on FileSystemException {
          return false;
        }
      });
      if (readable!) {
        markTestSkipped('This user can read any file.');
        return;
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_app(directory, importer));
      await _settle(tester);
      expect(
        find.textContaining('Could not open the photo collection'),
        findsOneWidget,
      );
      expect(await tester.runAsync(sidecar.readAsBytes), details);

      chmod('644');
      await _tapText(
        tester,
        'Try again',
        until: () => _shows(find.text('2 of 24 photos')),
      );
      expect(find.text('Favorite'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    skip: Platform.isWindows,
  );

  testWidgets('a photo that cannot be shown for a while keeps its details', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final importer = _FakeImporter([
      [1, 2, 3],
    ]);
    await tester.pumpWidget(_app(directory, importer));
    await _settle(tester);
    await _tapText(tester, 'Choose photos');
    await _openOptions(tester, 0);
    await tester.enterText(
      find.widgetWithText(TextField, 'Caption (optional)'),
      'Lake day',
    );
    await _toggle(tester, 'Favorite');
    await _toggle(tester, 'Hide from activities');
    await _tapText(tester, 'Save', until: () => _shows(find.text('Favorite')));

    // Its copy is replaced by something else for a while (a folder here).
    final notes = await tester.runAsync(
      () => PhotoAnnotationStore(directory).load(),
    );
    final id = notes!.keys.single;
    final copy = File('${directory.path}/$id.png');
    final aside = File('${directory.path}/aside.bin');
    await tester.runAsync(() async {
      await copy.rename(aside.path);
      await Directory(copy.path).create();
    });
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(directory, importer));
    await _settle(tester);
    expect(find.text('2 of 24 photos'), findsOneWidget);
    expect(find.text('Favorite'), findsNothing);

    // Back again: caption, favorite and hidden were never pruned.
    await tester.runAsync(() async {
      await Directory(copy.path).delete();
      await aside.rename(copy.path);
    });
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(directory, importer));
    await _settle(tester);
    expect(find.text('3 of 24 photos'), findsOneWidget);
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('Hidden'), findsOneWidget);
    final kept = await tester.runAsync(
      () => PhotoAnnotationStore(directory).load(),
    );
    expect(kept![id]!.caption, 'Lake day');
    expect(kept[id]!.hidden, isTrue);
  });
}
