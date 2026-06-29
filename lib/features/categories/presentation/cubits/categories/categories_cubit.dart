import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/categories/presentation/cubits/categories/categories_cubit_use_cases.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

part 'categories_state.dart';

@injectable
class CategoriesCubit extends BaseCubit<CategoriesState> {
  CategoriesCubit({required CategoriesCubitUseCases useCases})
    : _useCases = useCases,
      super(const CategoriesState.initial());

  final CategoriesCubitUseCases _useCases;

  Future<void> loadCategories({bool emitLoading = true}) async {
    final user = _useCases.getSessionUser();
    if (user.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(state.copyWith(status: StateStatus.loadingError, categories: []));
      return;
    }

    if (emitLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final result = await _useCases.getCategories(user.companyId);
    if (isClosed) return;

    if (result is SuccessState<List<CategoryEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          categories: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      final message = result.message ?? 'Erro ao carregar categorias'.hardcoded;
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: message,
        ),
      );
      showErrorToast(message);
    }
  }

  Future<bool> saveCategory({
    required String? id,
    required String name,
    String? description,
    String? color,
    DateTime? createdAt,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final isUpdate = id != null;
    final now = DateTime.now();
    final companyId = _useCases.getSessionUser().companyId;

    if (companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(state.copyWith(status: StateStatus.loadingError));
      return false;
    }

    final category = CategoryEntity(
      id: id ?? const Uuid().v4(),
      companyId: companyId,
      name: name.trim(),
      description: description?.trimToNull(),
      color: color?.trimToNull(),
      createdAt: createdAt ?? now,
    );

    final result = isUpdate
        ? await _useCases.updateCategory(category)
        : await _useCases.createCategory(category);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      await loadCategories(emitLoading: false);
      return true;
    } else {
      final message = result.message ?? 'Erro ao salvar categoria'.hardcoded;
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: message,
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<void> deleteCategory(String id) async {
    emit(
      state.copyWith(
        status: StateStatus.deleting,
        deletingIds: {...state.deletingIds, id},
      ),
    );

    final result = await _useCases.deleteCategory(id);
    if (isClosed) return;

    if (result is SuccessState<bool> && result.data == true) {
      await loadCategories(emitLoading: false);
      if (isClosed) return;

      emit(
        state.copyWith(
          status: StateStatus.loaded,
          deletingIds: {...state.deletingIds}..remove(id),
        ),
      );
    } else {
      final message = result.message ?? 'Erro ao excluir categoria'.hardcoded;
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: message,
          deletingIds: {...state.deletingIds}..remove(id),
        ),
      );
      showErrorToast(message);
    }
  }
}