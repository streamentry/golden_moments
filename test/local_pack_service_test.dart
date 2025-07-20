import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';

void main() {
  group('LocalPackService Tests', () {
    late LocalPackService service;

    setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

    setUp(() {
      service = LocalPackService.instance;
    });

    test('should load pack index from local JSON', () async {
      // Mock the asset bundle
      const channel = MethodChannel('flutter/assets');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'loadString') {
              return '''
{
  "version": "1.0.0",
  "lastUpdated": "2025-01-09T12:00:00Z",
  "totalPacks": 1,
  "categories": [
    {
      "id": "test",
      "name": "Test Category",
      "description": "Test category",
      "iconUrl": "test.png",
      "packCount": 1
    }
  ],
  "featuredPacks": ["test_pack"],
  "packs": [
    {
      "id": "test_pack",
      "title": "Test Pack",
      "description": "A test pack",
      "theme": "Test",
      "category": "test",
      "difficulty": "easy",
      "isPremium": false,
      "isFeatured": true,
      "imageCount": 2,
      "estimatedSize": "1.0 MB",
      "version": "1.0.0",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z",
      "tags": ["test"],
      "thumbnailUrl": "test_thumb.jpg",
      "previewImages": ["preview1.jpg"],
      "images": [
        {
          "id": "img1",
          "url": "https://example.com/img1.jpg",
          "caption": "Test Image 1"
        },
        {
          "id": "img2", 
          "url": "https://example.com/img2.jpg",
          "caption": "Test Image 2"
        }
      ]
    }
  ]
}
''';
            }
            return null;
          });

      final packIndex = await service.loadPackIndex();

      expect(packIndex.version, '1.0.0');
      expect(packIndex.totalPacks, 1);
      expect(packIndex.packs.length, 1);
      expect(packIndex.packs.first.id, 'test_pack');
      expect(packIndex.packs.first.images.length, 2);
    });

    test('should get all packs', () async {
      // Setup mock as above
      const channel = MethodChannel('flutter/assets');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'loadString') {
              return '''
{
  "version": "1.0.0",
  "lastUpdated": "2025-01-09T12:00:00Z",
  "totalPacks": 2,
  "categories": [],
  "featuredPacks": [],
  "packs": [
    {
      "id": "pack1",
      "title": "Pack 1",
      "description": "First pack",
      "theme": "Test",
      "category": "test",
      "difficulty": "easy",
      "isPremium": false,
      "isFeatured": false,
      "imageCount": 1,
      "estimatedSize": "1.0 MB",
      "version": "1.0.0",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z",
      "tags": [],
      "images": []
    },
    {
      "id": "pack2",
      "title": "Pack 2", 
      "description": "Second pack",
      "theme": "Test",
      "category": "test",
      "difficulty": "medium",
      "isPremium": true,
      "isFeatured": true,
      "imageCount": 1,
      "estimatedSize": "2.0 MB",
      "version": "1.0.0",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z",
      "tags": [],
      "images": []
    }
  ]
}
''';
            }
            return null;
          });

      final packs = await service.getAllPacks();

      expect(packs.length, 2);
      expect(packs[0].id, 'pack1');
      expect(packs[1].id, 'pack2');
    });

    test('should get pack by ID', () async {
      // Setup mock
      const channel = MethodChannel('flutter/assets');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'loadString') {
              return '''
{
  "version": "1.0.0",
  "lastUpdated": "2025-01-09T12:00:00Z",
  "totalPacks": 1,
  "categories": [],
  "featuredPacks": [],
  "packs": [
    {
      "id": "target_pack",
      "title": "Target Pack",
      "description": "The pack we want",
      "theme": "Test",
      "category": "test",
      "difficulty": "easy",
      "isPremium": false,
      "isFeatured": false,
      "imageCount": 1,
      "estimatedSize": "1.0 MB",
      "version": "1.0.0",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z",
      "tags": [],
      "images": []
    }
  ]
}
''';
            }
            return null;
          });

      final pack = await service.getPackById('target_pack');

      expect(pack, isNotNull);
      expect(pack!.id, 'target_pack');
      expect(pack.title, 'Target Pack');
    });

    test('should return null for non-existent pack', () async {
      // Setup mock
      const channel = MethodChannel('flutter/assets');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'loadString') {
              return '''
{
  "version": "1.0.0",
  "lastUpdated": "2025-01-09T12:00:00Z",
  "totalPacks": 0,
  "categories": [],
  "featuredPacks": [],
  "packs": []
}
''';
            }
            return null;
          });

      final pack = await service.getPackById('non_existent');

      expect(pack, isNull);
    });

    test('should convert pack info to game pack', () async {
      // Setup mock
      const channel = MethodChannel('flutter/assets');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'loadString') {
              return '''
{
  "version": "1.0.0",
  "lastUpdated": "2025-01-09T12:00:00Z",
  "totalPacks": 1,
  "categories": [],
  "featuredPacks": [],
  "packs": [
    {
      "id": "game_pack",
      "title": "Game Pack",
      "description": "A pack for gaming",
      "theme": "Gaming",
      "category": "test",
      "difficulty": "medium",
      "isPremium": false,
      "isFeatured": false,
      "imageCount": 2,
      "estimatedSize": "1.5 MB",
      "version": "1.0.0",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z",
      "tags": ["game"],
      "images": [
        {
          "id": "tile1",
          "url": "https://example.com/tile1.jpg",
          "caption": "Game Tile 1"
        },
        {
          "id": "tile2",
          "url": "https://example.com/tile2.jpg", 
          "caption": "Game Tile 2"
        }
      ]
    }
  ]
}
''';
            }
            return null;
          });

      final packInfo = await service.getPackById('game_pack');
      final gamePack = service.convertToGamePack(packInfo!);

      expect(gamePack.id, 'game_pack');
      expect(gamePack.title, 'Game Pack');
      expect(gamePack.theme, 'Gaming');
      expect(gamePack.tiles.length, 2);
      expect(gamePack.tiles[0].id, 'tile1');
      expect(gamePack.tiles[0].imageUrl, 'https://example.com/tile1.jpg');
      expect(gamePack.tiles[0].caption, 'Game Tile 1');
    });
  });
}
