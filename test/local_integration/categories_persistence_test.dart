import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_local_data_source.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/responses/category_model.dart';

import '../../testing/mocks/factories/asset_factory.dart';
import '../../testing/mocks/factories/local_database_fixture.dart';

void main() {
  late LocalDatabaseFixture fixture;
  CategoriesLocalDataSourceImpl source() =>
      CategoriesLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'category CRUD and clearing optional fields survive reopening',
    () async {
      final original = AssetFactory.makeCategoryEntity().copyWith(
        name: 'Elétrica – emergência',
        color: '#FF8800',
        description: 'Plantão',
      );
      expect(
        (await source().saveCategory(CategoryModel.fromEntity(original))).data,
        isTrue,
      );
      await fixture.reopen();
      var rows = (await source().getCategories(original.companyId)).data!;
      expect(rows.single.name, original.name);
      expect(rows.single.color, '#FF8800');
      expect(rows.single.description, 'Plantão');
      final updated = original.copyWith(
        name: 'Elétrica',
        annulColor: true,
        annulDescription: true,
      );
      expect(
        (await source().saveCategory(CategoryModel.fromEntity(updated))).data,
        isTrue,
      );
      await fixture.reopen();
      rows = (await source().getCategories(original.companyId)).data!;
      expect(rows.single.id, original.id);
      expect(rows.single.name, 'Elétrica');
      expect(rows.single.color, isNull);
      expect(rows.single.description, isNull);
      expect((await source().deleteCategory(original.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getCategories(original.companyId)).data, isEmpty);
    },
  );

  test(
    'same-name categories from different companies remain isolated',
    () async {
      final a = AssetFactory.makeCategoryEntity().copyWith(name: 'Motor');
      final b = AssetFactory.makeCategoryEntity().copyWith(name: 'Motor');
      expect(
        (await source().saveCategories([
          CategoryModel.fromEntity(a),
          CategoryModel.fromEntity(b),
        ])).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getCategories(a.companyId)).data!.map((r) => r.id),
        [a.id],
      );
      expect(
        (await source().getCategories(b.companyId)).data!.map((r) => r.id),
        [b.id],
      );
      expect((await source().deleteCategory(a.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getCategories(a.companyId)).data, isEmpty);
      expect((await source().getCategories(b.companyId)).data!.single.id, b.id);
    },
  );

  test(
    'replaying a server batch updates once and preserves tombstones',
    () async {
      final original = AssetFactory.makeCategoryEntity();
      final tombstone = AssetFactory.makeCategoryEntity().copyWith(
        companyId: original.companyId,
        deletedAt: DateTime.utc(2026, 9, 19),
      );
      final batch = [
        CategoryModel.fromEntity(original),
        CategoryModel.fromEntity(tombstone),
      ];
      expect((await source().saveCategories(batch)).data, isTrue);
      await fixture.reopen();
      expect((await source().saveCategories(batch)).data, isTrue);
      await fixture.reopen();
      expect(
        (await source().getCategories(
          original.companyId,
        )).data!.map((r) => r.id),
        [original.id],
      );
      final stored = await fixture.database
          .select(fixture.database.categories)
          .get();
      expect(stored, hasLength(2));
      expect(
        stored.singleWhere((r) => r.id == tombstone.id).deletedAt,
        isNotNull,
      );
    },
  );
}
