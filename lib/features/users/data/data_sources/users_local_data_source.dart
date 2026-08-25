import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/permission_group_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';

abstract interface class UsersLocalDataSource {
  // Profiles
  FutureList<UserProfileModel> getUserProfiles(String companyId);
  FutureData<UserProfileModel> getUserProfileById(String id);
  FutureBool saveUserProfile(UserProfileModel user);
  FutureBool saveUserProfiles(List<UserProfileModel> users);
  FutureBool deleteUserProfile(String id);

  // Permission Groups
  FutureList<PermissionGroupModel> getPermissionGroups(String companyId);
  FutureBool savePermissionGroup(PermissionGroupModel group);
  FutureBool savePermissionGroups(List<PermissionGroupModel> groups);
  FutureBool deletePermissionGroup(String id);
}

@LazySingleton(as: UsersLocalDataSource)
final class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  UsersLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  // ============================================
  // Profiles
  // ============================================

  @override
  FutureList<UserProfileModel> getUserProfiles(String companyId) {
    return ErrorHandler.execute(() async {
      final list =
          await (_database.select(_database.userProfiles)..where(
                (t) => t.companyId.equals(companyId) & t.deletedAt.isNull(),
              ))
              .get();

      return SuccessState(data: list.map(UserProfileModel.fromDb).toList());
    });
  }

  @override
  FutureData<UserProfileModel> getUserProfileById(String id) {
    return ErrorHandler.execute(() async {
      final t =
          await (_database.select(_database.userProfiles)
                ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
              .getSingleOrNull();

      if (t != null) {
        return SuccessState(data: UserProfileModel.fromDb(t));
      }

      return FailureState<UserProfileModel>(
        message: 'Usuário não encontrado'.hardcoded,
      );
    });
  }

  @override
  FutureBool saveUserProfile(UserProfileModel user) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.userProfiles)
          .insertOnConflictUpdate(
            UserProfilesCompanion(
              id: Value(user.id),
              companyId: Value(user.companyId),
              name: Value(user.name),
              isAdmin: Value(user.isAdmin),
              email: Value(user.email),
              phone: Value(user.phone),
              permissionGroupId: Value(user.permissionGroupId),
              avatarUrl: Value(user.avatarUrl),
              isActive: Value(user.isActive),
              createdAt: Value(user.createdAt.toUtc()),
              updatedAt: Value(user.updatedAt.toUtc()),
              deletedAt: Value(user.deletedAt?.toUtc()),
              permissions: Value(jsonEncode(user.toJson()['permissions'])),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveUserProfiles(List<UserProfileModel> users) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.userProfiles,
          users.map(
            (user) => UserProfilesCompanion(
              id: Value(user.id),
              companyId: Value(user.companyId),
              name: Value(user.name),
              isAdmin: Value(user.isAdmin),
              email: Value(user.email),
              phone: Value(user.phone),
              permissionGroupId: Value(user.permissionGroupId),
              avatarUrl: Value(user.avatarUrl),
              isActive: Value(user.isActive),
              createdAt: Value(user.createdAt.toUtc()),
              updatedAt: Value(user.updatedAt.toUtc()),
              deletedAt: Value(user.deletedAt?.toUtc()),
              permissions: Value(jsonEncode(user.toJson()['permissions'])),
            ),
          ),
        );
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteUserProfile(String id) {
    return ErrorHandler.execute(() async {
      await (_database.update(_database.userProfiles)
            ..where((t) => t.id.equals(id)))
          .write(UserProfilesCompanion(deletedAt: Value(DateTime.now().toUtc())));
      return const SuccessState(data: true);
    });
  }

  // ============================================
  // Permission Groups
  // ============================================

  @override
  FutureList<PermissionGroupModel> getPermissionGroups(String companyId) {
    return ErrorHandler.execute(() async {
      final list =
          await (_database.select(_database.permissionGroups)..where(
                (t) => t.companyId.equals(companyId) & t.deletedAt.isNull(),
              ))
              .get();

      return SuccessState(data: list.map(PermissionGroupModel.fromDb).toList());
    });
  }

  @override
  FutureBool savePermissionGroup(PermissionGroupModel group) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.permissionGroups)
          .insertOnConflictUpdate(
            PermissionGroupsCompanion(
              id: Value(group.id),
              companyId: Value(group.companyId),
              name: Value(group.name),
              permissions: Value(jsonEncode(group.toJson()['permissions'])),
              isDefault: Value(group.isDefault),
              createdAt: Value(group.createdAt.toUtc()),
              deletedAt: Value(group.deletedAt?.toUtc()),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool savePermissionGroups(List<PermissionGroupModel> groups) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.permissionGroups,
          groups.map(
            (group) => PermissionGroupsCompanion(
              id: Value(group.id),
              companyId: Value(group.companyId),
              name: Value(group.name),
              permissions: Value(jsonEncode(group.toJson()['permissions'])),
              isDefault: Value(group.isDefault),
              createdAt: Value(group.createdAt.toUtc()),
              deletedAt: Value(group.deletedAt?.toUtc()),
            ),
          ),
        );
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deletePermissionGroup(String id) {
    return ErrorHandler.execute(() async {
      await (_database.update(_database.permissionGroups)
            ..where((t) => t.id.equals(id)))
          .write(PermissionGroupsCompanion(deletedAt: Value(DateTime.now().toUtc())));
      return const SuccessState(data: true);
    });
  }
}
