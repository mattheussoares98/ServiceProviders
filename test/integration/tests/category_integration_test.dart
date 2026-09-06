@Tags(['integration'])
library;

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/requests/category_request_model.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/responses/category_model.dart';

import '../../../testing/mocks/factories/asset_factory.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';
import '../core/integration_run.dart';
import '../supabase_integration_helper.dart';

void main() {
  if (!IntegrationRun.registerGuard()) return;

  late SupabaseDatabaseClient db;
  late CategoriesRemoteDataSource categoriesRemote;
  late String companyId;

  setUpAll(() async {
    await SupabaseIntegrationHelper.initialize();
    db = SupabaseIntegrationHelper.databaseClient;
    categoriesRemote = CategoriesRemoteDataSourceImpl(database: db);
    companyId = IntegrationConfig.companyId;

    await SupabaseIntegrationHelper.signInAsAdmin();
  });

  tearDownAll(() async {
    if (IntegrationConfig.autoCleanup) {
      await IntegrationCleanup.cleanTracked(db);
    }
  });

  group('Category Database Integration Tests', () {
    test('Create, read, update, and soft-delete a category', () async {
      final categoryId = faker.guid.guid();
      IntegrationDataTracker.instance.track('categories', categoryId);

      final initialEntity = AssetFactory.makeCategoryEntity().copyWith(
        id: categoryId,
        companyId: companyId,
        name: IntegrationConfig.testName('Category ${faker.lorem.word()}'),
        createdAt: DateTime.now().toUtc(),
      );

      // 1. Create
      final createResult = await categoriesRemote.createCategory(
        CategoryRequestModel.fromEntity(initialEntity),
      );
      expect(createResult, isA<SuccessState<CategoryModel>>());
      final createdCategory =
          (createResult as SuccessState<CategoryModel>).data;
      expect(createdCategory?.toEntity(), initialEntity);

      // 2. Read (list)
      final listResult = await categoriesRemote.getCategories(companyId);
      expect(listResult, isA<SuccessState<List<CategoryModel>>>());
      final categories =
          (listResult as SuccessState<List<CategoryModel>>).data!;
      final foundCategory = categories.firstWhere((c) => c.id == categoryId);
      expect(foundCategory.toEntity(), initialEntity);

      // 3. Update
      final updatedName = IntegrationConfig.testName(
        'Updated Cat ${faker.lorem.word()}',
      );
      final updatedEntity = AssetFactory.makeCategoryEntity().copyWith(
        id: categoryId,
        companyId: companyId,
        name: updatedName,
        createdAt: DateTime.now().toUtc(),
      );
      final updateResult = await categoriesRemote.updateCategory(
        CategoryRequestModel.fromEntity(updatedEntity),
      );
      expect(updateResult, isA<SuccessState<CategoryModel>>());
      final updatedCategory =
          (updateResult as SuccessState<CategoryModel>).data;
      expect(updatedCategory?.toEntity(), updatedEntity);

      // 4. Soft Delete
      if (IntegrationConfig.autoCleanup) {
        final deleteResult = await categoriesRemote.deleteCategory(categoryId);
        expect(deleteResult, isA<SuccessState<void>>());

        // 5. Verify deleted category is excluded from active list
        final postDeleteList = await categoriesRemote.getCategories(companyId);
        final activeList =
            (postDeleteList as SuccessState<List<CategoryModel>>).data!;
        expect(activeList.any((c) => c.id == categoryId), isFalse);
      }
    });
  });
}
