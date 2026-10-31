import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/models/pack.dart';

/// Picture-pack text in the app language: topic names and descriptions,
/// pack titles, descriptions and themes, and picture captions.
///
/// The included catalog (`assets/data/packs_index.json`) holds English. Each
/// app language may add an overlay, `assets/data/i18n/packs_<locale>.json`,
/// keyed by the same ids (see docs/engineering/localization.md). Every field
/// falls back to English on its own, so a partial translation is fine.
///
/// Only what is shown changes: packs, ids and saved choices stay as they are.
@immutable
class PackText {
  const new _(this._categories, this._packs, this._captions);

  /// Reads an overlay. Anything that is not the expected shape is skipped,
  /// field by field, so a damaged file shows English rather than failing.
  factory parse(String source) {
    final Object? decoded;
    try {
      decoded = json.decode(source);
    } on FormatException {
      return english;
    }
    if (decoded is! Map) return english;
    final categories = <String, Map<String, String>>{};
    final packs = <String, Map<String, String>>{};
    final captions = <String, Map<String, String>>{};
    for (final MapEntry(:key, :value) in _entries(decoded['categories'])) {
      final fields = _texts(value, const {'name', 'description'});
      if (fields.isNotEmpty) categories[key] = fields;
    }
    for (final MapEntry(:key, :value) in _entries(decoded['packs'])) {
      final fields = _texts(value, const {'title', 'description', 'theme'});
      if (fields.isNotEmpty) packs[key] = fields;
      final images = _texts(value is Map ? value['images'] : null, null);
      if (images.isNotEmpty) captions[key] = images;
    }
    return PackText._(
      Map.unmodifiable(categories),
      Map.unmodifiable(packs),
      Map.unmodifiable(captions),
    );
  }

  /// No overlay: everything reads as the catalog's English.
  static const english = PackText._({}, {}, {});

  /// The pack text for the app language around [context], or [english]
  /// when no [PackTextDelegate] is installed.
  static PackText of(BuildContext context) =>
      Localizations.of<PackText>(context, PackText) ?? english;

  final Map<String, Map<String, String>> _categories;
  final Map<String, Map<String, String>> _packs;
  final Map<String, Map<String, String>> _captions;

  /// Whether this overlay translates nothing.
  bool get isEmpty =>
      _categories.isEmpty && _packs.isEmpty && _captions.isEmpty;

  String categoryName(Category category) =>
      categoryNameFor(category.id, category.name);

  /// The topic name for [categoryId], or [fallback] when not translated.
  String categoryNameFor(String categoryId, String fallback) =>
      _categories[categoryId]?['name'] ?? fallback;

  String categoryDescription(Category category) =>
      _categories[category.id]?['description'] ?? category.description;

  String packTitle(Pack pack) => _packs[pack.id]?['title'] ?? pack.title;

  String packTheme(Pack pack) => _packs[pack.id]?['theme'] ?? pack.theme;

  String? packDescription(Pack pack) =>
      _packs[pack.id]?['description'] ?? pack.description;

  /// The caption of picture [imageId] in pack [packId]. Picture ids repeat
  /// across packs, so both are needed.
  String caption(String packId, String imageId, String fallback) =>
      _captions[packId]?[imageId] ?? fallback;

  static Iterable<MapEntry<String, Object?>> _entries(Object? value) sync* {
    if (value is! Map) return;
    for (final MapEntry(:key, :value) in value.entries) {
      if (key is String) yield MapEntry(key, value);
    }
  }

  /// The non-blank text fields of [value], limited to [allowed] when given.
  static Map<String, String> _texts(Object? value, Set<String>? allowed) => {
    for (final MapEntry(:key, :value) in _entries(value))
      if ((allowed == null || allowed.contains(key)) &&
          value is String &&
          value.trim().isNotEmpty)
        key: value.trim(),
  };
}

/// Loads [PackText] for the app language and reloads it when the language
/// changes, alongside the app's other localizations.
class PackTextDelegate extends LocalizationsDelegate<PackText> {
  const new({this.bundle});

  /// Where overlays are read from; the app's [rootBundle] when null.
  final AssetBundle? bundle;

  /// The overlay file name for [locale] (`es`, `pt_BR`, `zh_Hans`), or null
  /// for English, which is the catalog itself.
  static String? overlayName(Locale locale) {
    if (locale.languageCode == 'en') return null;
    return [
      locale.languageCode,
      ?locale.scriptCode,
      ?locale.countryCode,
    ].join('_');
  }

  static String assetFor(String name) => 'assets/data/i18n/packs_$name.json';

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<PackText> load(Locale locale) {
    final name = overlayName(locale);
    if (name == null) return SynchronousFuture(PackText.english);
    return _read(bundle ?? rootBundle, name);
  }

  static Future<PackText> _read(AssetBundle bundle, String name) async {
    try {
      final data = await bundle.load(assetFor(name));
      final source = utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      return PackText.parse(source);
    } on Object catch (error) {
      // A missing or unreadable overlay means English. The file holds only
      // catalog text, never anything personal.
      debugPrint(
        'Picture-pack text for "$name" not loaded '
        '(${error.runtimeType}); showing English.',
      );
      return PackText.english;
    }
  }

  @override
  bool shouldReload(PackTextDelegate old) => old.bundle != bundle;
}

extension PackTextX on BuildContext {
  /// Picture-pack text in the app language; see [PackText].
  PackText get packText => PackText.of(this);
}
