import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:golden_moments/app/view/platform_home.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
import 'package:golden_moments/data/services/download_manager.dart';
import 'package:golden_moments/data/services/http_client_service.dart';
import 'package:golden_moments/data/services/json_cache_service.dart';
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

  // Preserve the independently stabilized browser/desktop initialization.
  // The mobile starter does not depend on Firebase, audio, HTTP or downloads.
  if (!usesGentleActivities) {
    try {
      await Firebase.initializeApp();
    } on Object {
      log('Optional Firebase initialization unavailable.');
    }
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

  if (!usesGentleActivities) {
    try {
      await JsonCacheService().initialize();
      await DownloadManager().initialize();
      HttpClientService().initialize();
      await DownloadManager().downloadInitialPacks();
    } on Object {
      log('The optional catalog is not fully available.');
    }
  }
}
