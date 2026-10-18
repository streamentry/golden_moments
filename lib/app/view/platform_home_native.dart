import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:golden_moments/app/view/main_navigation.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';

/// The local-photo upgrade is initially supported on iOS and Android.
bool get usesGentleActivities => Platform.isIOS || Platform.isAndroid;

/// Preserve the existing desktop catalog until native photo flows are tested.
Widget buildPlatformHome() => usesGentleActivities
    ? const GentleHomePage()
    : const MainNavigation();
