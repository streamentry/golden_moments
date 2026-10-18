/// Keep native file and photo-picker code out of the browser dependency graph.
library;

export 'platform_home_web.dart'
    if (dart.library.io) 'platform_home_native.dart';
