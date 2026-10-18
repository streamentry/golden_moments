import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:golden_moments/app/view/platform_home.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:provider/provider.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Avoid state dumps and user-provided photo paths or identifiers.
    log('State error in ${bloc.runtimeType}', stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = FlutterError.presentError;
  Bloc.observer = const AppBlocObserver();

  final soundSettings = SoundSettings();
  try {
    await soundSettings.load();
  } on Object {
    log('Using default local sound settings.');
  }

  // Sound uses bundled files and is optional. No Firebase/CDN initialization
  // or pack download may gate the first frame of the bundled catalog.
  if (!usesGentleActivities) {
    try {
      await SoundService().initialize(soundSettings);
    } on Object {
      log('Optional sound initialization unavailable.');
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => soundSettings,
      child: await builder(),
    ),
  );
}
