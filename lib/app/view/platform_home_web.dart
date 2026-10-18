import 'package:flutter/widgets.dart';
import 'package:golden_moments/app/view/main_navigation.dart';

/// Web retains its existing catalog, cached pictures, and browser smoke tests.
bool get usesGentleActivities => false;

Widget buildPlatformHome() => const MainNavigation();
