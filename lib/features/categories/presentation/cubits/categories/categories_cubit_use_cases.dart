import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/categories/domain/use_cases/create_category_use_case.dart';
import 'package:o_jogo_da_obra/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:o_jogo_da_obra/features/categories/domain/use_cases/get_categories_use_case.dart';
import 'package:o_jogo_da_obra/features/categories/domain/use_cases/update_category_use_case.dart';

@LazySingleton()
class CategoriesCubitUseCases {
  const CategoriesCubitUseCases({
    required this.getSessionUser,
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  });

  final GetSessionUserUseCase getSessionUser;
  final GetCategoriesUseCase getCategories;
  final CreateCategoryUseCase createCategory;
  final UpdateCategoryUseCase updateCategory;
  final DeleteCategoryUseCase deleteCategory;
}
