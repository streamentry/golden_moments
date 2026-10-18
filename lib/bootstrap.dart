import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/data/services/download_manager.dart';
import 'package:golden_moments/data/services/http_client_service.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
import 'package:golden_moments/data/services/sound_service.dart';
import 'package:provider/provider.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  Bloc.observer = const AppBlocObserver();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    log('Firebase initialized successfully');
  } on Object catch (e, stackTrace) {
    log('Firebase initialization failed: $e', stackTrace: stackTrace);
    // Continue app initialization even if Firebase fails
    // This allows the app to run in development mode without proper Firebase
    // config
  }

  // Add cross-flavor configuration here
  final soundSettings = SoundSettings();
  await soundSettings.load();
  await SoundService().initialize(soundSettings);

  runApp(
    ChangeNotifierProvider(
      create: (_) => soundSettings,
      child: await builder(),
    ),
  );

  // Initialize services with error handling
  try {
    await _initializeServices();
    await _executeTaskOnLaunch();
  } on Object catch (e, stackTrace) {
    log('Service initialization failed: $e', stackTrace: stackTrace);
    // Continue app execution even if services fail to initialize
    // This allows the app to run in limited mode
  }
}

/// Initialize core services
Future<void> _initializeServices() async {
  await JsonCacheService().initialize();
  await DownloadManager().initialize();
  HttpClientService().initialize();
}

Future<void> _executeTaskOnLaunch() async {
  await DownloadManager().downloadInitialPacks();
}
