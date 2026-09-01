import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/has_permission_use_case.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'users_state.dart';

enum UsersSections implements SectionKey {
  loadAll,
  revokeInvitation,
  updateUser,
  deleteUser,
  saveGroup,
  deleteGroup,
}

@injectable
class UsersCubit extends BaseCubit<UsersState> {
  UsersCubit({required UsersCubitUseCases useCases})
    : _useCases = useCases,
      super(const UsersState.initial()) {
    _initRealtime();
  }

  final UsersCubitUseCases _useCases;
  StreamSubscription<RealtimeEvent<UserProfileEntity>>? _usersSubscription;

  void _initRealtime() {
    final companyId = _useCases.getActiveCompanyId();
    _usersSubscription = _useCases
        .watchUserProfilesRealtime(companyId: companyId)
        .listen(_handleRealtimeEvent);
  }

  void _handleRealtimeEvent(RealtimeEvent<UserProfileEntity> event) {
    if (isClosed) return;

    final currentUsers = List<UserProfileEntity>.from(state.users);

    switch (event.eventType) {
      case RealtimeEventType.insert:
        if (event.entity != null && event.entity!.deletedAt == null) {
          final index = currentUsers.indexWhere((u) => u.id == event.id);
          if (index == -1) {
            currentUsers.insert(0, event.entity!);
          } else {
            currentUsers[index] = event.entity!;
          }
          emit(state.copyWith(users: currentUsers));
        }
      case RealtimeEventType.update:
        if (event.entity != null) {
          final index = currentUsers.indexWhere((u) => u.id == event.id);
          if (event.entity!.deletedAt != null) {
            if (index != -1) {
              currentUsers.removeAt(index);
              emit(state.copyWith(users: currentUsers));
            }
          } else {
            if (index != -1) {
              currentUsers[index] = event.entity!;
            } else {
              currentUsers.add(event.entity!);
            }
            emit(state.copyWith(users: currentUsers));
          }
        }
      case RealtimeEventType.delete:
        final index = currentUsers.indexWhere((u) => u.id == event.id);
        if (index != -1) {
          currentUsers.removeAt(index);
          emit(state.copyWith(users: currentUsers));
        }
    }
  }

  // ============================================
  // Load Operations
  // ============================================

  Future<bool> loadUsers({bool emitLoading = true}) async {
    final companyId = _useCases.getActiveCompanyId();

    if (emitLoading && !isClosed) {
      emit(state.copyWith(status: DataStatus.loading));
    }

    final result = await _useCases.getUsers(companyId);
    if (isClosed) return false;

    if (result is SuccessState<List<UserProfileEntity>>) {
      emit(
        state.copyWith(
          status: DataStatus.loaded,
          users: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
      return true;
    } else {
      final message = result.message ?? 'Erro ao carregar usuários'.hardcoded;
      emit(
        state.copyWith(status: DataStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> loadPermissionGroups({bool emitLoading = true}) async {
    final companyId = _useCases.getActiveCompanyId();

    if (emitLoading) {
      emit(state.copyWith(status: DataStatus.loading));
    }

    final result = await _useCases.getPermissionGroups(companyId);
    if (isClosed) return false;

    if (result is SuccessState<List<PermissionGroupEntity>>) {
      emit(
        state.copyWith(
          status: DataStatus.loaded,
          permissionGroups: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao carregar grupos de permissão'.hardcoded;
      emit(
        state.copyWith(status: DataStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> loadInvitations({bool emitLoading = true}) async {
    final companyId = _useCases.getActiveCompanyId();

    if (emitLoading && !isClosed) {
      emit(state.copyWith(status: DataStatus.loading));
    }

    final result = await _useCases.getPendingInvitations(companyId);
    if (isClosed) return false;

    if (result is SuccessState<List<UserInvitationEntity>>) {
      emit(
        state.copyWith(
          status: DataStatus.loaded,
          invitations: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
      return true;
    } else {
      final message = result.message ?? 'Erro ao carregar convites'.hardcoded;
      emit(
        state.copyWith(status: DataStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<void> loadAll({bool emitLoading = true}) async {
    if (emitLoading) {
      emit(
        state.copyWith(
          sections: withSection(UsersSections.loadAll, SectionStatus.running),
        ),
      );
    }

    try {
      final results = await Future.wait([
        loadUsers(emitLoading: false),
        loadPermissionGroups(emitLoading: false),
        loadInvitations(emitLoading: false),
      ]);

      if (isClosed) return;

      final hasError = results.any((success) => !success);

      emit(
        state.copyWith(
          sections: withSection(
            UsersSections.loadAll,
            hasError ? SectionStatus.error : SectionStatus.success,
          ),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          sections: withSection(UsersSections.loadAll, SectionStatus.error),
        ),
      );
    }
  }

  Future<bool> revokeInvitation(String id) async {
    emit(
      state.copyWith(
        sections: withSection(
          UsersSections.revokeInvitation,
          SectionStatus.running,
        ),
        deletingInvitationIds: {...state.deletingInvitationIds, id},
      ),
    );

    final result = await _useCases.revokeInvitation(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            UsersSections.revokeInvitation,
            SectionStatus.success,
          ),
          deletingInvitationIds: {...state.deletingInvitationIds}..remove(id),
        ),
      );
      await loadInvitations(emitLoading: false);
      return true;
    } else {
      final message = result.message ?? 'Erro ao revogar convite'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            UsersSections.revokeInvitation,
            SectionStatus.error,
          ),
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
    emit(
      state.copyWith(
        sections: withSection(UsersSections.updateUser, SectionStatus.running),
      ),
    );

    final currentUser = state.users.firstWhereOrNull((u) => u.id == userId);
    if (currentUser == null) {
      final message = 'Usuário não encontrado'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(UsersSections.updateUser, SectionStatus.error),
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
      emit(
        state.copyWith(
          sections: withSection(
            UsersSections.updateUser,
            SectionStatus.success,
          ),
        ),
      );
      await loadUsers(emitLoading: false);
      return true;
    } else {
      final message = result.message ?? 'Erro ao atualizar usuário'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(UsersSections.updateUser, SectionStatus.error),
          errorMessage: message,
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> updateUserPermissionGroup(String userId, String groupId) async {
    emit(
      state.copyWith(
        sections: withSection(UsersSections.updateUser, SectionStatus.running),
      ),
    );

    final currentUser = state.users.firstWhereOrNull((u) => u.id == userId);
    if (currentUser == null) {
      final message = 'Usuário não encontrado'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(UsersSections.updateUser, SectionStatus.error),
          errorMessage: message.hardcoded,
        ),
      );
      showErrorToast(message.hardcoded);
      return false;
    }

    final updatedUser = currentUser.copyWith(permissionGroupId: groupId);
    final result = await _useCases.updateUserProfile(updatedUser);

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            UsersSections.updateUser,
            SectionStatus.success,
          ),
        ),
      );
      await loadUsers(emitLoading: false);
      return true;
    } else {
      if (isClosed) return false;
      final message = result.message ?? 'Erro ao atualizar usuário'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(UsersSections.updateUser, SectionStatus.error),
          errorMessage: message,
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> deleteUserProfile(String id) async {
    emit(
      state.copyWith(
        sections: withSection(UsersSections.deleteUser, SectionStatus.running),
        deletingUserIds: {...state.deletingUserIds, id},
      ),
    );

    final result = await _useCases.deleteUserProfile(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final updatedUsers = state.users.where((u) => u.id != id).toList();
      emit(
        state.copyWith(
          users: updatedUsers,
          sections: withSection(
            UsersSections.deleteUser,
            SectionStatus.success,
          ),
          deletingUserIds: {...state.deletingUserIds}..remove(id),
        ),
      );
      await loadUsers(emitLoading: false);
      return true;
    } else {
      final message = result.message ?? 'Erro ao excluir usuário'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(UsersSections.deleteUser, SectionStatus.error),
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
    emit(
      state.copyWith(
        sections: withSection(UsersSections.saveGroup, SectionStatus.running),
      ),
    );

    final result = isUpdate
        ? await _useCases.updatePermissionGroup(group)
        : await _useCases.createPermissionGroup(group);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(UsersSections.saveGroup, SectionStatus.success),
        ),
      );
      await loadPermissionGroups(emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao salvar grupo de permissão'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(UsersSections.saveGroup, SectionStatus.error),
          errorMessage: message,
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<void> deletePermissionGroup(String id) async {
    emit(
      state.copyWith(
        sections: withSection(UsersSections.deleteGroup, SectionStatus.running),
        deletingGroupIds: {...state.deletingGroupIds, id},
      ),
    );

    final result = await _useCases.deletePermissionGroup(id);
    if (isClosed) return;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            UsersSections.deleteGroup,
            SectionStatus.success,
          ),
          deletingGroupIds: {...state.deletingGroupIds}..remove(id),
        ),
      );
      await loadPermissionGroups(emitLoading: false);
    } else {
      final message =
          result.message ?? 'Erro ao excluir grupo de permissão'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(UsersSections.deleteGroup, SectionStatus.error),
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

  bool hasPermission(ActionPermission permission) {
    final appMode =
        AppMode.fromName(_useCases.getSelectedMode()) ?? AppMode.internal;
    final sessionUser = _useCases.getSessionUser();
    final currentUser =
        state.users.firstWhereOrNull((u) => u.id == sessionUser.id) ??
        sessionUser;

    return HasPermissionUseCase.evaluatePermission(
      permission: permission,
      user: currentUser,
      permissionGroups: state.permissionGroups,
      appMode: appMode,
    );
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

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}
