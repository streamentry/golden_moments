import 'package:flutter/material.dart';
import 'package:golden_moments/app/view/platform_home.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golden Moments',
      // Light only: older eyes read dark ink on warm paper best, and MIUI's
      // forced dark mode turned the app black (#18).
      theme: gmBuildTheme(),
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: buildPlatformHome(),
    );
  }
}
