import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/categories/domain/repositories/categories_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class UpdateCategoryUseCase implements UseCase<bool, CategoryEntity> {
  UpdateCategoryUseCase({required CategoriesRepository categoriesRepository})
      : _categoriesRepository = categoriesRepository;

  final CategoriesRepository _categoriesRepository;

  @override
  FutureBool call(CategoryEntity request) =>
      _categoriesRepository.updateCategory(request);
}
