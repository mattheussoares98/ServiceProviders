import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit_use_cases.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';

part 'users_state.dart';

@injectable
class UsersCubit extends BaseCubit<UsersState> {
  UsersCubit({required UsersCubitUseCases useCases})
    : _useCases = useCases,
      super(const UsersState.initial());

  final UsersCubitUseCases _useCases;

  // ============================================
  // Load Operations
  // ============================================

  Future<void> loadUsers({bool emitLoading = true}) async {
    final sessionUser = _useCases.getSessionUser();
    if (sessionUser.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(state.copyWith(status: StateStatus.loadingError, users: []));
      return;
    }

    if (emitLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final result = await _useCases.getUsers(sessionUser.companyId);
    if (isClosed) return;

    if (result is SuccessState<List<UserProfileEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          users: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      final message = result.message ?? 'Erro ao carregar usuários'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
    }
  }

  Future<void> loadPermissionGroups({bool emitLoading = true}) async {
    final sessionUser = _useCases.getSessionUser();
    if (sessionUser.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(
        state.copyWith(status: StateStatus.loadingError, permissionGroups: []),
      );
      return;
    }

    if (emitLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final result = await _useCases.getPermissionGroups(sessionUser.companyId);
    if (isClosed) return;

    if (result is SuccessState<List<PermissionGroupEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          permissionGroups: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      final message =
          result.message ?? 'Erro ao carregar grupos de permissão'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
    }
  }

  Future<void> loadAll({bool emitLoading = true}) async {
    if (emitLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    await loadUsers(emitLoading: false);
    if (state.status == StateStatus.loadingError) return;

    await loadPermissionGroups(emitLoading: false);
  }

  // ============================================
  // User Profile Operations
  // ============================================

  Future<bool> updateUserProfile(UserProfileEntity userProfile) async {
    emit(state.copyWith(status: StateStatus.saving));

    final result = await _useCases.updateUserProfile(userProfile);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      await loadUsers(emitLoading: false);
      return true;
    } else {
      final message = result.message ?? 'Erro ao atualizar usuário'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<void> deleteUserProfile(String id) async {
    emit(
      state.copyWith(
        status: StateStatus.deleting,
        deletingUserIds: {...state.deletingUserIds, id},
      ),
    );

    final result = await _useCases.deleteUserProfile(id);
    if (isClosed) return;

    if (result is SuccessState<bool> && result.data == true) {
      await loadUsers(emitLoading: false);
      if (isClosed) return;

      emit(
        state.copyWith(
          status: StateStatus.loaded,
          deletingUserIds: {...state.deletingUserIds}..remove(id),
        ),
      );
    } else {
      final message = result.message ?? 'Erro ao excluir usuário'.hardcoded;
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: message,
          deletingUserIds: {...state.deletingUserIds}..remove(id),
        ),
      );
      showErrorToast(message);
    }
  }

  // ============================================
  // Permission Group Operations
  // ============================================

  Future<bool> savePermissionGroup(
    PermissionGroupEntity group, {
    required bool isUpdate,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final result = isUpdate
        ? await _useCases.updatePermissionGroup(group)
        : await _useCases.createPermissionGroup(group);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      await loadPermissionGroups(emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao salvar grupo de permissão'.hardcoded;
      emit(state.copyWith(errorMessage: message));
      showErrorToast(message);
      return false;
    }
  }

  Future<void> deletePermissionGroup(String id) async {
    emit(
      state.copyWith(
        status: StateStatus.deleting,
        deletingGroupIds: {...state.deletingGroupIds, id},
      ),
    );

    final result = await _useCases.deletePermissionGroup(id);
    if (isClosed) return;

    if (result is SuccessState<bool> && result.data == true) {
      await loadPermissionGroups(emitLoading: false);
      if (isClosed) return;

      emit(
        state.copyWith(
          status: StateStatus.loaded,
          deletingGroupIds: {...state.deletingGroupIds}..remove(id),
        ),
      );
    } else {
      final message =
          result.message ?? 'Erro ao excluir grupo de permissão'.hardcoded;
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: message,
          deletingGroupIds: {...state.deletingGroupIds}..remove(id),
        ),
      );
      showErrorToast(message);
    }
  }

  // ============================================
  // Permission Helper
  // ============================================

  bool hasPermission(ResourceType resource, PermissionAction action) {
    final sessionUser = _useCases.getSessionUser();
    if (sessionUser.isAdmin) return true;

    final userOverride = sessionUser.permissions[resource]?[action];
    if (userOverride != null) {
      return userOverride; //TODO check if there is a test for it
    }

    final groupId = sessionUser.permissionGroupId;
    if (groupId == null || groupId.isEmpty) return false;

    final group = state.permissionGroups.firstWhereOrNull(
      (g) => g.id == groupId,
    );
    if (group != null) {
      return group.permissions[resource]?.contains(action) ?? false;
    }

    return false;
  }
}
