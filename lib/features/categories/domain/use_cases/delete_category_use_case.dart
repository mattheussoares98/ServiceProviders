import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/categories/domain/repositories/categories_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class DeleteCategoryUseCase implements UseCase<bool, String> {
  DeleteCategoryUseCase({required CategoriesRepository categoriesRepository})
      : _categoriesRepository = categoriesRepository;

  final CategoriesRepository _categoriesRepository;

  @override
  FutureBool call(String request) =>
      _categoriesRepository.deleteCategory(request);
}
