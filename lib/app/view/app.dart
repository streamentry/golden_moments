import 'package:flutter/material.dart';
import 'package:memory_lane/home/view/home_page.dart';
import 'package:memory_lane/l10n/l10n.dart';
import 'package:memory_lane/shared/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Lane',
      theme: AppTheme.getTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
