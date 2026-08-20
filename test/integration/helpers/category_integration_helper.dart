import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/requests/category_request_model.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/responses/category_model.dart';

import '../../../testing/mocks/entity_factory.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';

/// Helper for getting or creating Categories in integration tests.
class CategoryIntegrationHelper {
  const CategoryIntegrationHelper._();

  /// Returns an existing category or creates a new `[IT]`-prefixed one.
  static Future<CategoryModel> getOrCreateCategory(
    CategoriesRemoteDataSource remote,
    String companyId,
  ) async {
    if (IntegrationConfig.useExistingData) {
      final result = await remote.getCategories(companyId);
      if (result is SuccessState<List<CategoryModel>> &&
          (result.data?.isNotEmpty ?? false)) {
        return result.data!.first;
      }
    }

    final entity = EntityFactory.makeCategoryEntity().copyWith(
      id: faker.guid.guid(),
      companyId: companyId,
      name: IntegrationConfig.testName(faker.lorem.word()),
      createdAt: DateTime.now().toUtc(),
    );
    final model = CategoryRequestModel.fromEntity(entity);
    final result = await remote.createCategory(model);
    final created = (result as SuccessState<CategoryModel>).data!;
    IntegrationDataTracker.instance.track('categories', created.id);
    return created;
  }
}
