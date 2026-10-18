import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:provider/provider.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Do not record state dumps, selected photos, or personal identifiers.
    log('State error in ${bloc.runtimeType}', stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = FlutterError.presentError;
  Bloc.observer = const AppBlocObserver();

  // Local activities do not initialize Firebase, audio, HTTP, or downloads.
  // Existing pack services are initialized only when the library is opened.
  final soundSettings = SoundSettings();
  try {
    await soundSettings.load();
  } catch (_) {
    log('Using default local sound settings.');
  }
  runApp(ChangeNotifierProvider(
    create: (_) => soundSettings,
    child: await builder(),
  ));
}
