import 'dart:typed_data';

class BrowserImageStore {
  static bool get isOnline => true;
  static Uint8List? peek(String url) => null;
  static Future<Uint8List?> read(String url) async => null;
  static Future<void> write(String url, Uint8List bytes) async {}
  static Future<void> delete(String url) async {}
}
