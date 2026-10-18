import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Image bytes live in Cache Storage; pack metadata lives in preferences.
class BrowserImageStore {
  static const _cacheName = 'golden-moments-images-v1';
  static final _loaded = <String, Uint8List>{};

  static bool get isOnline => web.window.navigator.onLine;
  static Uint8List? peek(String url) => _loaded[url];

  static Future<Uint8List?> read(String url) async {
    final cache = await web.window.caches.open(_cacheName).toDart;
    final response = await cache.match(url.toJS).toDart;
    if (response == null) return null;
    final bytes = (await response.arrayBuffer().toDart).toDart.asUint8List();
    _loaded[url] = bytes;
    return bytes;
  }

  static Future<void> write(String url, Uint8List bytes) async {
    final cache = await web.window.caches.open(_cacheName).toDart;
    await cache.put(url.toJS, web.Response(bytes.toJS)).toDart;
    _loaded[url] = bytes;
  }

  static Future<void> delete(String url) async {
    final cache = await web.window.caches.open(_cacheName).toDart;
    await cache.delete(url.toJS).toDart;
    _loaded.remove(url);
  }
}
