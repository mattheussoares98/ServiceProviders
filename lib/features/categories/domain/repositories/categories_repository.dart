import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';

abstract interface class CategoriesRepository {
  FutureList<CategoryEntity> getCategories(String companyId);
  FutureBool createCategory(CategoryEntity category);
  FutureBool updateCategory(CategoryEntity category);
  FutureBool deleteCategory(String id);
}