import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';
import 'package:o_jogo_da_obra/features/categories/domain/repositories/categories_repository.dart';

@LazySingleton()
class GetCategoriesUseCase implements UseCase<List<CategoryEntity>, String> {
  GetCategoriesUseCase({required CategoriesRepository categoriesRepository})
    : _categoriesRepository = categoriesRepository;

  final CategoriesRepository _categoriesRepository;

  @override
  FutureList<CategoryEntity> call(String request) =>
      _categoriesRepository.getCategories(request);
}
