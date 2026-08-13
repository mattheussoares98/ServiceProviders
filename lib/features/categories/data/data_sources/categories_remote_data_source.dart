import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/requests/category_request_model.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/responses/category_model.dart';

abstract interface class CategoriesRemoteDataSource {
  FutureList<CategoryModel> getCategories(String companyId);
  FutureData<CategoryModel> createCategory(CategoryRequestModel request);
  FutureData<CategoryModel> updateCategory(CategoryRequestModel request);
  FutureVoid deleteCategory(String id);
}

@LazySingleton(as: CategoriesRemoteDataSource)
final class CategoriesRemoteDataSourceImpl
    implements CategoriesRemoteDataSource {
  const CategoriesRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureList<CategoryModel> getCategories(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'categories',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(CategoryModel.fromJson).toList();
      });

  @override
  FutureData<CategoryModel> createCategory(CategoryRequestModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.insert(
          table: 'categories',
          values: request.toJson(),
        );
        return CategoryModel.fromJson(response.first);
      });

  @override
  FutureData<CategoryModel> updateCategory(CategoryRequestModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.update(
          table: 'categories',
          values: request.toJson(),
          filters: [SupabaseFilter.eq('id', request.id)],
        );
        return CategoryModel.fromJson(response.first);
      });

  @override
  FutureVoid deleteCategory(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'categories',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });
}
