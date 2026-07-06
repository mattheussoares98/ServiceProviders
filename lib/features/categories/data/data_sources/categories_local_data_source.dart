import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/responses/category_response_model.dart';

abstract interface class CategoriesLocalDataSource {
  FutureList<CategoryResponseModel> getCategories(String companyId);
  FutureBool saveCategory(CategoryResponseModel category);
  FutureBool deleteCategory(String id);
  FutureBool saveCategories(List<CategoryResponseModel> categories);
}

@LazySingleton(as: CategoriesLocalDataSource)
final class CategoriesLocalDataSourceImpl implements CategoriesLocalDataSource {
  CategoriesLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureList<CategoryResponseModel> getCategories(String companyId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.categories)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map(
            (row) => CategoryResponseModel(
              id: row.id,
              companyId: row.companyId,
              name: row.name,
              description: row.description,
              color: row.color,
              createdAt: row.createdAt,
              deletedAt: row.deletedAt,
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveCategory(CategoryResponseModel category) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.categories)
          .insertOnConflictUpdate(
            CategoriesCompanion(
              id: Value(category.id),
              companyId: Value(category.companyId),
              name: Value(category.name),
              description: Value(category.description),
              color: Value(category.color),
              createdAt: Value(category.createdAt),
              deletedAt: Value(category.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteCategory(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.categories)
        ..where((t) => t.id.equals(id));
      await query.write(CategoriesCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveCategories(List<CategoryResponseModel> categories) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.categories,
          categories
              .map(
                (category) => CategoriesCompanion(
                  id: Value(category.id),
                  companyId: Value(category.companyId),
                  name: Value(category.name),
                  description: Value(category.description),
                  color: Value(category.color),
                  createdAt: Value(category.createdAt),
                  deletedAt: Value(category.deletedAt),
                ),
              )
              .toList(),
        );
      });
      return const SuccessState(data: true);
    });
  }
}
