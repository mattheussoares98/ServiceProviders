import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

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

    if (emitLoading && !isClosed) {
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

  Future<void> loadInvitations({bool emitLoading = true}) async {
    final sessionUser = _useCases.getSessionUser();

    if (emitLoading && !isClosed) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final result = await _useCases.getPendingInvitations(sessionUser.companyId);
    if (isClosed) return;

    if (result is SuccessState<List<UserInvitationEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          invitations: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      final message = result.message ?? 'Erro ao carregar convites'.hardcoded;
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

    await Future.wait([
      loadUsers(emitLoading: false),
      loadPermissionGroups(emitLoading: false),
      loadInvitations(emitLoading: false),
    ]);
  }

  Future<bool> revokeInvitation(String id) async {
    emit(
      state.copyWith(
        status: StateStatus.deleting,
        deletingInvitationIds: {...state.deletingInvitationIds, id},
      ),
    );

    final result = await _useCases.revokeInvitation(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      await loadInvitations(emitLoading: false);
      if (isClosed) return false;

      emit(
        state.copyWith(
          status: StateStatus.loaded,
          deletingInvitationIds: {...state.deletingInvitationIds}..remove(id),
        ),
      );
      return true;
    } else {
      final message = result.message ?? 'Erro ao revogar convite'.hardcoded;
      emit(
        state.copyWith(
          status: StateStatus.deletingError,
          errorMessage: message,
          deletingInvitationIds: {...state.deletingInvitationIds}..remove(id),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> resendInvitation(UserInvitationEntity invitation) async {
    emit(
      state.copyWith(
        resendingInvitationIds: {
          ...state.resendingInvitationIds,
          invitation.id,
        },
      ),
    );

    final result = await _useCases.resendInvitation(invitation);
    if (isClosed) return false;

    final updatedResending = {...state.resendingInvitationIds}
      ..remove(invitation.id);

    if (result is SuccessState) {
      await loadInvitations(emitLoading: false);
      if (isClosed) return false;

      emit(state.copyWith(resendingInvitationIds: updatedResending));
      showSuccessToast('Convite reenviado com sucesso!'.hardcoded);
      return true;
    } else {
      final message = result.message ?? 'Erro ao reenviar convite'.hardcoded;
      emit(
        state.copyWith(
          resendingInvitationIds: updatedResending,
          errorMessage: message,
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  // ============================================
  // User Profile Operations
  // ============================================

  Future<bool> updateUserPermissions(
    String userId,
    Map<ResourceType, Map<PermissionAction, bool?>> permissions, {
    String? groupId,
    UserWorkOrdersPermissionOverrideEntity? workOrders,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final currentUser = state.users.firstWhereOrNull((u) => u.id == userId);
    if (currentUser == null) {
      final message = 'Usuário não encontrado'.hardcoded;
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: message.hardcoded,
        ),
      );
      showErrorToast(message.hardcoded);
      return false;
    }

    final updatedUser = currentUser.copyWith(
      permissions: permissions,
      permissionGroupId: groupId,
      workOrders: workOrders,
    );
    final result = await _useCases.updateUserProfile(updatedUser);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      await loadUsers(emitLoading: false);
      return true;
    } else {
      final message = result.message ?? 'Erro ao atualizar usuário'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> updateUserPermissionGroup(String userId, String groupId) async {
    emit(state.copyWith(status: StateStatus.saving));

    final currentUser = state.users.firstWhereOrNull((u) => u.id == userId);
    if (currentUser == null) {
      final message = 'Usuário não encontrado'.hardcoded;
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: message.hardcoded,
        ),
      );
      showErrorToast(message.hardcoded);
      return false;
    }

    final updatedUser = currentUser.copyWith(permissionGroupId: groupId);
    final result = await _useCases.updateUserProfile(updatedUser);

    if (result is SuccessState<bool> && result.data == true) {
      await loadUsers(emitLoading: false);
      return true;
    } else {
      if (isClosed) return false;
      final message = result.message ?? 'Erro ao atualizar usuário'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> deleteUserProfile(String id) async {
    emit(
      state.copyWith(
        status: StateStatus.deleting,
        deletingUserIds: {...state.deletingUserIds, id},
      ),
    );

    final result = await _useCases.deleteUserProfile(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      await loadUsers(emitLoading: false);
      if (isClosed) return false;

      emit(
        state.copyWith(
          status: StateStatus.loaded,
          deletingUserIds: {...state.deletingUserIds}..remove(id),
        ),
      );
      return true;
    } else {
      final message = result.message ?? 'Erro ao excluir usuário'.hardcoded;
      emit(
        state.copyWith(
          status: StateStatus.deletingError,
          errorMessage: message,
          deletingUserIds: {...state.deletingUserIds}..remove(id),
        ),
      );
      showErrorToast(message);
      return false;
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
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
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
          status: StateStatus.deletingError,
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

  bool hasActionPermission(ActionPermission permission) {
    return switch (permission) {
      ResourceActionPermission(:final resource, :final action) => hasPermission(
        resource,
        action,
      ),
      WorkOrderSubActionPermission(:final subAction) =>
        hasWorkOrderSubActionPermission(subAction),
    };
  }

  bool hasWorkOrderSubActionPermission(WorkOrderSubAction subAction) {
    final sessionUser = _useCases.getSessionUser();
    final currentUser =
        state.users.firstWhereOrNull((u) => u.id == sessionUser.id) ??
        sessionUser;

    if (currentUser.isAdmin) return true;

    final woPermissions = currentUser.workOrdersPermissionOverrides;
    final groupPermissions = state.permissionGroups
        .firstWhereOrNull((g) => g.id == currentUser.permissionGroupId)
        ?.workOrders;

    switch (subAction) {
      case WorkOrderSubAction.deleteObservation:
        final override = woPermissions.deleteObservation;
        if (override != null) return override;
        return groupPermissions?.deleteObservation ?? false;

      case WorkOrderSubAction.changeStatus:
        final override = woPermissions.changeStatus;
        if (override != null) return override;
        return groupPermissions?.changeStatus ?? false;

      case WorkOrderSubAction.reassign:
        final override = woPermissions.reassign;
        if (override != null) return override;
        return groupPermissions?.reassign ?? false;

      case WorkOrderSubAction.approvePause:
        final override = woPermissions.approvePause;
        if (override != null) return override;
        return groupPermissions?.approvePause ?? false;

      case WorkOrderSubAction.approveCompletion:
        final override = woPermissions.approveCompletion;
        if (override != null) return override;
        return groupPermissions?.approveCompletion ?? false;
    }
  }

  bool hasPermission(ResourceType resource, PermissionAction action) {
    final sessionUser = _useCases.getSessionUser();
    final currentUser =
        state.users.firstWhereOrNull((u) => u.id == sessionUser.id) ??
        sessionUser;

    if (currentUser.isAdmin) return true;

    if (resource == ResourceType.workOrders) {
      final woPermissions = currentUser.workOrdersPermissionOverrides;
      final groupPermissions = state.permissionGroups
          .firstWhereOrNull((g) => g.id == currentUser.permissionGroupId)
          ?.workOrders;

      if (action == PermissionAction.create) {
        if (woPermissions.create != null) return woPermissions.create!;
        if (groupPermissions?.create == true) return true;
      } else if (action == PermissionAction.delete) {
        if (woPermissions.delete != null) return woPermissions.delete!;
        if (groupPermissions?.delete == true) return true;
      }
    }

    final userOverride = currentUser.permissions[resource]?[action];
    if (userOverride != null) {
      return userOverride;
    }

    final groupId = currentUser.permissionGroupId;
    if (groupId == null || groupId.isEmpty) return false;

    final group = state.permissionGroups.firstWhereOrNull(
      (g) => g.id == groupId,
    );
    if (group != null) {
      return group.permissions[resource]?.contains(action) ?? false;
    }

    return false;
  }

  Future<void> navigateToEditUserPermissions(UserProfileEntity user) async {
    await pushRoute(EditUserPermissionsRoute(user: user));
  }

  Future<void> navigateToEditGroupPermissions(
    PermissionGroupEntity group,
  ) async {
    await pushRoute(EditGroupPermissionsRoute(group: group));
  }

  void popRoute() {
    popRouteAdaptively();
  }
}
