import 'package:flutter/material.dart';
import 'package:golden_moments/data/services/download_manager.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/l10n/l10n.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void dispose() {
    DownloadManager().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golden Moments',
      theme: gmBuildTheme(brightness: Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const GentleHomePage(),
    );
  }
}
