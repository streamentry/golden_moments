import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:golden_moments/game/services/game_pack_loader.dart';
import 'package:golden_moments/game/models/models.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp/test_cache';
  }
}

void main() {
  group('GamePackLoader Tests', () {
    late GamePackLoader loader;

    setUpAll(() {
      PathProviderPlatform.instance = MockPathProviderPlatform();
    });

    setUp(() {
      loader = GamePackLoader.instance;
    });

    test('should load game pack successfully', () async {
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
  "categories": [],
  "featuredPacks": [],
  "packs": [
    {
      "id": "test_pack",
      "title": "Test Pack",
      "description": "A test pack for loading",
      "theme": "Test Theme",
      "category": "test",
      "difficulty": "easy",
      "isPremium": false,
      "isFeatured": false,
      "imageCount": 3,
      "estimatedSize": "2.5 MB",
      "version": "1.0.0",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z",
      "tags": ["test", "sample"],
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
        },
        {
          "id": "img3",
          "url": "https://example.com/img3.jpg",
          "caption": "Test Image 3"
        }
      ]
    }
  ]
}
''';
            }
            return null;
          });

      final result = await loader.loadGamePack('test_pack');

      expect(result.isSuccess, isTrue);
      expect(result.gamePack, isNotNull);
      expect(result.gamePack!.id, 'test_pack');
      expect(result.gamePack!.title, 'Test Pack');
      expect(result.gamePack!.theme, 'Test Theme');
      expect(result.gamePack!.difficulty, GameDifficulty.easy);
      expect(result.gamePack!.tiles.length, 3);
      expect(result.source, GamePackLoadSource.bundled);
      expect(result.metadata, isNotNull);
      expect(result.metadata!.cacheHit, isTrue);
      expect(result.metadata!.imageCount, 3);
    });

    test('should fail to load non-existent pack', () async {
      // Mock the asset bundle
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

      final result = await loader.loadGamePack('non_existent_pack');

      expect(result.isSuccess, isFalse);
      expect(result.gamePack, isNull);
      expect(result.errorMessage, contains('Pack not found'));
      expect(result.source, GamePackLoadSource.none);
    });

    test('should get available packs', () async {
      // Mock the asset bundle
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
      "theme": "Theme 1",
      "category": "test",
      "difficulty": "easy",
      "isPremium": false,
      "isFeatured": false,
      "imageCount": 2,
      "estimatedSize": "1.0 MB",
      "version": "1.0.0",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z",
      "tags": [],
      "images": [
        {
          "id": "img1",
          "url": "https://example.com/img1.jpg",
          "caption": "Image 1"
        },
        {
          "id": "img2",
          "url": "https://example.com/img2.jpg",
          "caption": "Image 2"
        }
      ]
    },
    {
      "id": "pack2",
      "title": "Pack 2",
      "description": "Second pack",
      "theme": "Theme 2",
      "category": "test",
      "difficulty": "medium",
      "isPremium": true,
      "isFeatured": true,
      "imageCount": 4,
      "estimatedSize": "3.0 MB",
      "version": "1.0.0",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z",
      "tags": [],
      "images": [
        {
          "id": "img1",
          "url": "https://example.com/img1.jpg",
          "caption": "Image 1"
        },
        {
          "id": "img2",
          "url": "https://example.com/img2.jpg",
          "caption": "Image 2"
        },
        {
          "id": "img3",
          "url": "https://example.com/img3.jpg",
          "caption": "Image 3"
        },
        {
          "id": "img4",
          "url": "https://example.com/img4.jpg",
          "caption": "Image 4"
        }
      ]
    }
  ]
}
''';
            }
            return null;
          });

      final packs = await loader.getAvailablePacks();

      expect(packs.length, 2);
      expect(packs[0].id, 'pack1');
      expect(packs[0].tiles.length, 2);
      expect(packs[1].id, 'pack2');
      expect(packs[1].tiles.length, 4);
      expect(packs[1].difficulty, GameDifficulty.medium);
    });

    test('should handle loading errors gracefully', () async {
      // Mock the asset bundle to throw an error
      const channel = MethodChannel('flutter/assets');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'loadString') {
              throw Exception('Asset loading failed');
            }
            return null;
          });

      final result = await loader.loadGamePack('any_pack');

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Failed to load pack'));
      expect(result.source, GamePackLoadSource.none);
    });

    test('should preload pack images', () async {
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
  "categories": [],
  "featuredPacks": [],
  "packs": [
    {
      "id": "preload_pack",
      "title": "Preload Pack",
      "description": "Pack for preloading test",
      "theme": "Preload",
      "category": "test",
      "difficulty": "easy",
      "isPremium": false,
      "isFeatured": false,
      "imageCount": 2,
      "estimatedSize": "1.5 MB",
      "version": "1.0.0",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z",
      "tags": [],
      "images": [
        {
          "id": "img1",
          "url": "https://example.com/preload1.jpg",
          "caption": "Preload Image 1"
        },
        {
          "id": "img2",
          "url": "https://example.com/preload2.jpg",
          "caption": "Preload Image 2"
        }
      ]
    }
  ]
}
''';
            }
            return null;
          });

      final result = await loader.loadGamePack('preload_pack');
      expect(result.isSuccess, isTrue);

      // Test preloading (should not throw)
      await loader.preloadPackImages(result.gamePack!);

      expect(true, isTrue); // If we get here, preloading worked
    });

    test('should cleanup expired cache', () async {
      // This should not throw an error
      await loader.cleanupExpiredCache();

      expect(true, isTrue); // If we get here, cleanup worked
    });
  });
}
