import 'package:flutter/material.dart';
import 'package:golden_moments/app/view/platform_home.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/l10n/pack_text.dart';

class App extends StatefulWidget {
  const new({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The task-switcher name follows the device language.
      onGenerateTitle: (context) => context.l10n.appTitle,
      // Light only: older eyes read dark ink on warm paper best, and MIUI's
      // forced dark mode turned the app black (#18).
      theme: gmBuildTheme(),
      themeMode: ThemeMode.light,
      // Picture-pack names and captions follow the app language too.
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        PackTextDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: resolveAppLocale,
      home: buildPlatformHome(),
    );
  }
}
