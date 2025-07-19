import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:golden_moments/data/models/sound_setting.dart';
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
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Add cross-flavor configuration here

  runApp(
    ChangeNotifierProvider(
      create: (_) => SoundSettings(),
      child: await builder(),
    ),
  );

  // Initialize services
  await _initializeServices();
}

/// Initialize core services
Future<void> _initializeServices() async {
  // Initialize cache service first
  await JsonCacheService().initialize();
  await SoundService().initialize();

  HttpClientService().initialize();
}
