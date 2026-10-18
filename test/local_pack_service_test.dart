import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/data/services/local_pack_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalPackService service;
  setUp(() {
    service = LocalPackService()..clearCache();
  });
  test('bundled catalog parses every pack and category', () async {
    final index = await service.loadPacksIndex();
    expect(index.packs.length, index.totalPacks);
    expect(index.categories, isNotEmpty);
    expect(index.packs.every((pack) => pack.images.isNotEmpty), isTrue);
    expect(index.packs.map((pack) => pack.id).toSet().length, index.totalPacks);
  });
  test('catalog is cached, filterable, and can be invalidated', () async {
    final index = await service.getPacksIndex();
    expect(identical(await service.getPacksIndex(), index), isTrue);
    final category = index.categories.first;
    final packs = await service.getPacksByCategory(category.id);
    expect(packs, isNotEmpty);
    expect(packs.every((pack) => pack.category == category.id), isTrue);
    expect(await service.getPackById(packs.first.id), packs.first);
    expect(await service.getCategories(), index.categories);
    expect(await service.getPacks(), index.packs);
    service.clearCache();
    expect(service.packsIndex, isNull);
  });
  test('missing pack fails explicitly', () async {
    await expectLater(service.getPackById('missing'), throwsStateError);
  });
}
