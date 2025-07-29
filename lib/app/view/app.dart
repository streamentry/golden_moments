import 'package:flutter/material.dart';
import 'package:golden_moments/app/view/main_navigation.dart';
import 'package:golden_moments/data/services/download_manager.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DownloadManager().dispose(); // ✅ Cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golden Moments',
      theme: gmBuildTheme(brightness: Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MainNavigation(),
    );
  }
}
