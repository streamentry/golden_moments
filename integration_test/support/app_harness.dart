import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/app/app.dart';
import 'package:golden_moments/bootstrap.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where screenshots go, set with
/// `--dart-define=GM_E2E_SCREENSHOT_DIR=<folder>`. Empty means no
/// screenshots. `flutter test` uninstalls the app afterwards, so the folder
/// must be outside the app: on a simulator, which shares the Mac's file
/// system, an absolute path such as the repository's `build/` folder works.
const String screenshotDirectory = String.fromEnvironment(
  'GM_E2E_SCREENSHOT_DIR',
);

/// The folder, inside the app's own storage, that holds family-photo copies.
Future<Directory> familyPhotoDirectory() async {
  final root = await getApplicationSupportDirectory();
  return Directory('${root.path}/family_photos_v1');
}

/// Forgets everything the app saved: preferences, saved boards, pack choices
/// and family-photo copies. Bundled assets are never touched.
Future<void> resetAppStorage() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  final photos = await familyPhotoDirectory();
  if (photos.existsSync()) await photos.delete(recursive: true);
}

/// Defines one journey: fresh storage, semantics on (so finders work the way
/// a screen reader sees the app) and storage cleared again afterwards.
void journey(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    await resetAppStorage();
    final semantics = tester.ensureSemantics();
    try {
      await body(tester);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
      await resetAppStorage();
    }
  });
}

/// Starts the real app through the production [bootstrap], exactly as
/// `lib/main.dart` does, optionally at a larger text size. Calling it again
/// in the same test is a cold relaunch over the same saved storage.
Future<void> launchApp(WidgetTester tester, {double textScale = 1}) async {
  // Re-read preferences from the device so a relaunch sees only what was
  // really written to disk, not the in-memory cache.
  await (await SharedPreferences.getInstance()).reload();
  // bootstrap installs the app's own error presenter; keep the test's
  // handler so layout overflows and other errors still fail the journey.
  final testErrorHandler = FlutterError.onError;
  try {
    await bootstrap(
      () => textScale == 1
          ? const App()
          : _ScaledText(scale: textScale, child: const App()),
    );
  } finally {
    FlutterError.onError = testErrorHandler;
  }
  await waitFor(tester, find.byType(App));
  await settle(tester);
}

/// Applies a system-like text size: MaterialApp reads the text scaler from
/// the nearest MediaQuery above it.
class _ScaledText extends StatelessWidget {
  const new({required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQueryData.fromView(View.of(context))
        .copyWith(textScaler: TextScaler.linear(scale)),
    child: child,
  );
}

const _frame = Duration(milliseconds: 50);

/// Pumps until nothing more is scheduled (animations and route transitions
/// have finished), or [timeout]. Unlike pumpAndSettle it never fails on a
/// progress indicator that keeps animating.
Future<void> settle(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);
  do {
    await tester.pump(_frame);
  } while (tester.binding.hasScheduledFrame && DateTime.now().isBefore(end));
}

/// Pumps real frames until [finder] finds something. Real file and
/// preference I/O completes in real time, so this is the deterministic wait.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) => waitUntil(
  tester,
  () => finder.evaluate().isNotEmpty,
  description: finder.toString(describeSelf: true),
  timeout: timeout,
);

/// Pumps real frames until [finder] finds nothing.
Future<void> waitForAbsent(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) => waitUntil(
  tester,
  () => finder.evaluate().isEmpty,
  description: 'no ${finder.toString(describeSelf: true)}',
  timeout: timeout,
);

/// Pumps real frames until [condition] holds.
Future<void> waitUntil(
  WidgetTester tester,
  bool Function() condition, {
  required String description,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (true) {
    await tester.pump(_frame);
    if (condition()) return;
    if (DateTime.now().isAfter(end)) {
      fail('Timed out after $timeout waiting for $description');
    }
  }
}

/// Lets [duration] of real time pass while frames keep pumping; used only to
/// prove that nothing changes on its own (no timers, no auto-advance).
Future<void> letTimePass(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Scrolls [finder] into view if needed, checks a person could actually
/// touch it there, taps it and lets the result settle.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  final target = finder.first;
  await tester.ensureVisible(target);
  await settle(tester);
  expectHittable(tester, target);
  await tester.tap(target);
  await settle(tester);
}

/// Fails unless the centre of [finder] is on screen and a tap there would
/// reach it (not covered by a sheet, dialog or bar).
void expectHittable(WidgetTester tester, Finder finder) {
  final element = finder.evaluate().single;
  final box = element.renderObject! as RenderBox;
  final center = box.localToGlobal(box.size.center(Offset.zero));
  final view = tester.view;
  final screen = Offset.zero & (view.physicalSize / view.devicePixelRatio);
  expect(
    screen.contains(center),
    isTrue,
    reason: '${finder.toString(describeSelf: true)} is off screen at $center',
  );
  final hit = tester.hitTestOnBinding(center);
  expect(
    hit.path.any((entry) => entry.target == box),
    isTrue,
    reason: '${finder.toString(describeSelf: true)} is covered at $center',
  );
}

var _shots = 0;
final _shotName = RegExp(r'^\d\d-j[0-9a-z-]+\.png$');

/// Saves a screenshot of the device screen as `NN-name.png` in
/// [screenshotDirectory]. A failure only skips the picture; it never fails a
/// journey.
Future<void> snap(WidgetTester tester, String name) async {
  if (screenshotDirectory.isEmpty) return;
  await settle(tester);
  final file = '${(++_shots).toString().padLeft(2, '0')}-$name.png';
  try {
    final bytes = await IntegrationTestWidgetsFlutterBinding.instance
        .takeScreenshot(name);
    final folder = Directory(screenshotDirectory);
    await folder.create(recursive: true);
    // Start each run without earlier journey pictures; nothing else in the
    // folder is touched.
    if (_shots == 1) {
      for (final old in folder.listSync().whereType<File>()) {
        if (_shotName.hasMatch(old.uri.pathSegments.last)) old.deleteSync();
      }
    }
    await File('${folder.path}/$file').writeAsBytes(bytes);
    debugPrint('Screenshot saved: $file');
  } on Object catch (error) {
    debugPrint('Screenshot $file skipped: ${error.runtimeType}');
  }
}
