import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_local_data_source.dart';
import 'package:clean_architecture/features/categories/data/models/responses/category_response_model.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late CategoriesLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = CategoriesLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertTestCompany(String companyId) async {
    await database
        .into(database.companies)
        .insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );
  }

  final tEntity = EntityFactory.makeCategoryEntity();
  final tModel = CategoryResponseModel.fromEntity(tEntity);

  group('CategoriesLocalDataSourceImpl', () {
    test('should save a category and successfully retrieve it', () async {
      // Arrange
      await insertTestCompany(tModel.companyId);

      // Act
      final saveResult = await dataSource.saveCategory(tModel);

      // Assert Save
      expect(saveResult, isA<SuccessState<bool>>());
      expect(saveResult.data, isTrue);

      // Act: Get categories
      final getResult = await dataSource.getCategories(tModel.companyId);

      // Assert Get
      expect(getResult, isA<SuccessState<List<CategoryResponseModel>>>());
      expect(getResult.data, hasLength(1));
      final resultModel = getResult.data!.first;
      expect(resultModel.id, tModel.id);
      expect(resultModel.companyId, tModel.companyId);
      expect(resultModel.name, tModel.name);
      expect(resultModel.description, tModel.description);
      expect(resultModel.color, tModel.color);
    });

    test(
      'should soft-delete a category and verify it is not returned in getCategories',
      () async {
        // Arrange
        await insertTestCompany(tModel.companyId);
        await dataSource.saveCategory(tModel);

        // Act: Delete
        final deleteResult = await dataSource.deleteCategory(tModel.id);

        // Assert Delete
        expect(deleteResult, isA<SuccessState<bool>>());
        expect(deleteResult.data, isTrue);

        // Act: Get categories
        final getResult = await dataSource.getCategories(tModel.companyId);

        // Assert Get: Should be empty because it is soft-deleted
        expect(getResult, isA<SuccessState<List<CategoryResponseModel>>>());
        expect(getResult.data, isEmpty);
      },
    );
  });
}
