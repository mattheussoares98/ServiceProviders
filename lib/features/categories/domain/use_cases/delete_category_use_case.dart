import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/categories/domain/repositories/categories_repository.dart';

@LazySingleton()
class DeleteCategoryUseCase implements UseCase<bool, String> {
  DeleteCategoryUseCase({required CategoriesRepository categoriesRepository})
    : _categoriesRepository = categoriesRepository;

  final CategoriesRepository _categoriesRepository;

  @override
  FutureBool call(String request) =>
      _categoriesRepository.deleteCategory(request);
}
