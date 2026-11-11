/// Which game a picture pack opens. Native mobile plays a pack on the gentle
/// board, which reads local files; the browser keeps the picture-pack game.
/// The split keeps native file code out of the browser dependency graph,
/// like `platform_home.dart`.
library;

export 'pack_game_web.dart' if (dart.library.io) 'pack_game_native.dart';
