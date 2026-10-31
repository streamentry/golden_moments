import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/models/category.dart';
import 'package:golden_moments/data/models/image.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/data/models/packs_index.dart';
import 'package:golden_moments/features/game/cubit/tile_state.dart';
import 'package:golden_moments/features/game/presentation/widgets/memory_tile.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/l10n/pack_text.dart';
import 'package:golden_moments/shared/widgets/category_card.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';

const _icon = 'assets/images/catalog/defe68445f56c7f448b228be.jpg';

const _cow = Image(id: 'cow_1', url: _icon, caption: 'Friendly Cow');

const _farm = Pack(
  id: 'animals_farm',
  title: 'Farm Animals',
  theme: 'Farm Life',
  category: 'animals',
  version: '1',
  difficulty: GameDifficulty.easy,
  thumbnailUrl: _icon,
  images: [_cow],
  estimatedSize: '1 MB',
  description: 'Friendly farm animals',
);

const _animals = Category(
  id: 'animals',
  name: 'Animals',
  description: 'Cute and friendly animals',
  iconUrl: _icon,
  packCount: 1,
);

const _spanish = '''
{
  "categories": {"animals": {"name": "Animales"}},
  "packs": {
    "animals_farm": {
      "title": "Animales de granja",
      "theme": "Vida en la granja",
      "images": {"cow_1": "Vaca amistosa"}
    }
  }
}
''';

/// Serves overlays from memory; a missing name fails like a missing asset.
class _Bundle extends CachingAssetBundle {
  _Bundle(this.files);

  final Map<String, String> files;
  final requested = <String>[];

  @override
  Future<ByteData> load(String key) async {
    requested.add(key);
    final text = files[key];
    if (text == null) throw FlutterError('Unable to load asset: $key');
    return ByteData.sublistView(utf8.encode(text));
  }
}

String _asset(String name) => PackTextDelegate.assetFor(name);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PackText.parse', () {
    test('applies translated fields and keeps English for the rest', () {
      final text = PackText.parse(_spanish);
      expect(text.categoryName(_animals), 'Animales');
      expect(text.categoryDescription(_animals), _animals.description);
      expect(text.packTitle(_farm), 'Animales de granja');
      expect(text.packTheme(_farm), 'Vida en la granja');
      expect(text.packDescription(_farm), _farm.description);
      expect(text.caption('animals_farm', 'cow_1', 'x'), 'Vaca amistosa');
      // The same picture id in another pack is not translated by this one.
      expect(text.caption('nature_mountains', 'cow_1', 'Cow'), 'Cow');
      expect(text.categoryNameFor('nature', 'Nature'), 'Nature');
    });

    test('ignores blank text, wrong types and unknown fields', () {
      final text = PackText.parse('''
        {
          "categories": {"animals": {"name": "  ", "description": 3}},
          "packs": {
            "animals_farm": {
              "title": ["Granja"],
              "theme": " Granja ",
              "colour": "rojo",
              "images": {"cow_1": 7, "pig_1": "Cerdo"}
            },
            "broken": "not an object"
          }
        }
      ''');
      expect(text.categoryName(_animals), 'Animals');
      expect(text.categoryDescription(_animals), _animals.description);
      expect(text.packTitle(_farm), 'Farm Animals');
      expect(text.packTheme(_farm), 'Granja');
      expect(text.caption('animals_farm', 'cow_1', 'Cow'), 'Cow');
      expect(text.caption('animals_farm', 'pig_1', 'Pig'), 'Cerdo');
    });

    test('malformed overlays read as English', () {
      for (final source in ['', '{not json', '[1, 2]', '"text"', 'null']) {
        final text = PackText.parse(source);
        expect(text.isEmpty, isTrue, reason: source);
        expect(text.packTitle(_farm), 'Farm Animals');
      }
      final wrongShape = PackText.parse('{"categories": [], "packs": 5}');
      expect(wrongShape.isEmpty, isTrue);
    });
  });

  group('PackTextDelegate', () {
    test('names overlays as the ARB files do', () {
      expect(PackTextDelegate.overlayName(const Locale('en')), isNull);
      expect(PackTextDelegate.overlayName(const Locale('es')), 'es');
      expect(PackTextDelegate.overlayName(const Locale('pt', 'BR')), 'pt_BR');
      expect(
        PackTextDelegate.overlayName(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ),
        'zh_Hant',
      );
    });

    test('English needs no file and loads synchronously', () {
      final bundle = _Bundle({});
      final loaded = PackTextDelegate(bundle: bundle).load(const Locale('en'));
      expect(loaded, isA<SynchronousFuture<PackText>>());
      expect(bundle.requested, isEmpty);
    });

    test('loads the overlay for the language', () async {
      final bundle = _Bundle({_asset('es'): _spanish});
      final text = await PackTextDelegate(bundle: bundle)
          .load(const Locale('es'));
      expect(text.packTitle(_farm), 'Animales de granja');
    });

    test('a missing or malformed overlay falls back to English', () async {
      final bundle = _Bundle({_asset('fr'): '{"packs": {"animals_farm": '});
      final delegate = PackTextDelegate(bundle: bundle);
      final missing = await delegate.load(const Locale('de'));
      final malformed = await delegate.load(const Locale('fr'));
      expect(missing.isEmpty, isTrue);
      expect(malformed.isEmpty, isTrue);
      expect(missing.packTitle(_farm), 'Farm Animals');
    });

    test('every app language has a readable bundled overlay', () async {
      for (final locale in AppLocalizations.supportedLocales) {
        final name = PackTextDelegate.overlayName(locale);
        // The base pt and zh files exist only for the generator; the app
        // resolves to pt_BR, zh_Hans or zh_Hant.
        if (name == null || name == 'pt' || name == 'zh') continue;
        final data = await rootBundle.load(_asset(name));
        expect(data.lengthInBytes, greaterThan(0), reason: name);
        expect(
          () => PackText.parse(utf8.decode(data.buffer.asUint8List())),
          returnsNormally,
        );
      }
    });
  });

  test('packs_en.json is exactly the catalog English', () {
    final index = PacksIndex.fromJson(
      json.decode(File('assets/data/packs_index.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final source = json.decode(
      File('assets/data/i18n/packs_en.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final text = PackText.parse(json.encode(source));
    expect(
      (source['categories'] as Map).keys,
      index.categories.map((c) => c.id),
    );
    expect((source['packs'] as Map).keys, index.packs.map((p) => p.id));
    for (final category in index.categories) {
      expect(text.categoryNameFor(category.id, ''), category.name);
      expect(
        text.categoryDescription(
          Category(
            id: category.id,
            name: '',
            description: '',
            iconUrl: '',
            packCount: 0,
          ),
        ),
        category.description,
      );
    }
    for (final pack in index.packs) {
      final blank = pack.copyWith(title: '', theme: '');
      expect(text.packTitle(blank), pack.title);
      expect(text.packTheme(blank), pack.theme);
      expect(
        (source['packs'] as Map)[pack.id]['description'],
        pack.description,
      );
      final captions =
          (source['packs'] as Map)[pack.id]['images'] as Map<String, dynamic>;
      expect(captions.keys, pack.images.map((i) => i.id));
      for (final image in pack.images) {
        expect(text.caption(pack.id, image.id, ''), image.caption);
      }
    }
  });

  group('on screen', () {
    Widget app(Locale locale, AssetBundle bundle, Widget child) => MaterialApp(
      locale: locale,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        PackTextDelegate(bundle: bundle),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ListView(children: [child])),
    );

    testWidgets('pack and topic text follow the app language', (tester) async {
      final bundle = _Bundle({_asset('es'): _spanish});
      final cards = Column(
        children: [
          PackCard(pack: _farm, onTap: () {}, onNotForMe: () {}),
          CategoryCard(category: _animals, onTap: () {}),
        ],
      );
      await tester.pumpWidget(app(const Locale('es'), bundle, cards));
      await tester.pumpAndSettle();
      expect(find.text('Animales de granja'), findsOneWidget);
      expect(find.text('Vida en la granja'), findsOneWidget);
      expect(find.text('Animales'), findsOneWidget);
      // Untranslated fields stay English.
      expect(find.text(_animals.description), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Animales de granja')), findsWidgets);

      await tester.pumpWidget(app(const Locale('en'), bundle, cards));
      await tester.pumpAndSettle();
      expect(find.text('Farm Animals'), findsOneWidget);
      expect(find.text('Animals'), findsOneWidget);
      expect(find.text('Animales de granja'), findsNothing);
    });

    testWidgets('a shown picture is named in the app language', (tester) async {
      final bundle = _Bundle({_asset('es'): _spanish});
      const shown = GameTile(id: 't1', image: _cow, isRevealed: true);
      const hidden = GameTile(id: 't2', image: _cow);
      await tester.pumpWidget(
        app(
          const Locale('es'),
          bundle,
          Row(
            children: [
              SizedBox.square(
                dimension: 120,
                child: MemoryTile(
                  tile: shown,
                  position: 1,
                  packId: _farm.id,
                  onTap: () {},
                ),
              ),
              SizedBox.square(
                dimension: 120,
                child: MemoryTile(
                  tile: hidden,
                  position: 2,
                  packId: _farm.id,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('Vaca amistosa')), findsOneWidget);
      // A hidden tile never names its picture, in any language.
      expect(find.bySemanticsLabel(RegExp('Friendly Cow')), findsNothing);
    });

    testWidgets('a missing overlay shows English', (tester) async {
      await tester.pumpWidget(
        app(
          const Locale('ja'),
          _Bundle({}),
          PackCard(pack: _farm, onTap: () {}),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Farm Animals'), findsOneWidget);
      expect(find.text('Farm Life'), findsOneWidget);
    });
  });
}
