import 'dart:convert';

import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/handlers/error_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/data/models/responses/permission_group_response_model.dart';
import 'package:clean_architecture/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

abstract interface class UsersLocalDataSource {
  // Profiles
  FutureList<UserProfileResponseModel> getUserProfiles(String companyId);
  FutureData<UserProfileResponseModel> getUserProfileById(String id);
  FutureBool saveUserProfile(UserProfileResponseModel user);
  FutureBool deleteUserProfile(String id);

  // Permission Groups
  FutureList<PermissionGroupResponseModel> getPermissionGroups(String companyId);
  FutureBool savePermissionGroup(PermissionGroupResponseModel group);
  FutureBool deletePermissionGroup(String id);
}

@LazySingleton(as: UsersLocalDataSource)
final class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  UsersLocalDataSourceImpl({
    required AppDatabase database,
  }) : _database = database;

  final AppDatabase _database;

  // ============================================
  // Profiles
  // ============================================

  @override
  FutureList<UserProfileResponseModel> getUserProfiles(String companyId) {
    return ErrorHandler.execute(() async {
      final list = await (_database.select(_database.userProfiles)
            ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull()))
          .get();

      return SuccessState(
        data: list
            .map(
              (t) => UserProfileResponseModel(
                id: t.id,
                companyId: t.companyId,
                name: t.name,
                email: t.email,
                phone: t.phone,
                permissionGroupId: t.permissionGroupId,
                avatarUrl: t.avatarUrl,
                isActive: t.isActive,
                createdAt: t.createdAt,
                updatedAt: t.updatedAt,
                deletedAt: t.deletedAt,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  FutureData<UserProfileResponseModel> getUserProfileById(String id) {
    return ErrorHandler.execute(() async {
      final t = await (_database.select(_database.userProfiles)
            ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
          .getSingleOrNull();

      if (t != null) {
        return SuccessState(
          data: UserProfileResponseModel(
            id: t.id,
            companyId: t.companyId,
            name: t.name,
            email: t.email,
            phone: t.phone,
            permissionGroupId: t.permissionGroupId,
            avatarUrl: t.avatarUrl,
            isActive: t.isActive,
            createdAt: t.createdAt,
            updatedAt: t.updatedAt,
            deletedAt: t.deletedAt,
          ),
        );
      }

      return FailureState<UserProfileResponseModel>(
        message: 'User profile not found'.hardcoded,
      );
    });
  }

  @override
  FutureBool saveUserProfile(UserProfileResponseModel user) {
    return ErrorHandler.execute(() async {
      await _database.into(_database.userProfiles).insertOnConflictUpdate(
            UserProfilesCompanion(
              id: Value(user.id),
              companyId: Value(user.companyId),
              name: Value(user.name),
              email: Value(user.email),
              phone: Value(user.phone),
              permissionGroupId: Value(user.permissionGroupId),
              avatarUrl: Value(user.avatarUrl),
              isActive: Value(user.isActive),
              createdAt: Value(user.createdAt),
              updatedAt: Value(user.updatedAt),
              deletedAt: Value(user.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteUserProfile(String id) {
    return ErrorHandler.execute(() async {
      await (_database.update(_database.userProfiles)
            ..where((t) => t.id.equals(id)))
          .write(UserProfilesCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }

  // ============================================
  // Permission Groups
  // ============================================

  @override
  FutureList<PermissionGroupResponseModel> getPermissionGroups(String companyId) {
    return ErrorHandler.execute(() async {
      final list = await (_database.select(_database.permissionGroups)
            ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull()))
          .get();

      return SuccessState(
        data: list.map((t) {
          final jsonMap = {
            'id': t.id,
            'company_id': t.companyId,
            'name': t.name,
            'permissions': t.permissions,
            'is_default': t.isDefault,
            'created_at': t.createdAt.toIso8601String(),
            'deleted_at': t.deletedAt?.toIso8601String(),
          };
          return PermissionGroupResponseModel.fromJson(jsonMap);
        }).toList(),
      );
    });
  }

  @override
  FutureBool savePermissionGroup(PermissionGroupResponseModel group) {
    return ErrorHandler.execute(() async {
      await _database.into(_database.permissionGroups).insertOnConflictUpdate(
            PermissionGroupsCompanion(
              id: Value(group.id),
              companyId: Value(group.companyId),
              name: Value(group.name),
              permissions: Value(jsonEncode(group.toJson()['permissions'])),
              isDefault: Value(group.isDefault),
              createdAt: Value(group.createdAt),
              deletedAt: Value(group.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deletePermissionGroup(String id) {
    return ErrorHandler.execute(() async {
      await (_database.update(_database.permissionGroups)
            ..where((t) => t.id.equals(id)))
          .write(PermissionGroupsCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }
}
