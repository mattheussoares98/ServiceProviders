import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/data/handlers/supabase_handler.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/data/models/responses/permission_group_response_model.dart';
import 'package:clean_architecture/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class UsersRemoteDataSource {
  // User Profiles
  FutureList<UserProfileResponseModel> getUserProfiles(String companyId);
  FutureData<UserProfileResponseModel> getUserProfileById(String id);
  FutureData<UserProfileResponseModel> updateUserProfile(
    UserProfileResponseModel request,
  );
  FutureVoid deleteUserProfile(String id);
  FutureVoid inviteUser({
    required String email,
    required String companyId,
    required String groupId,
  });

  // Permission Groups
  FutureList<PermissionGroupResponseModel> getPermissionGroups(
    String companyId,
  );
  FutureData<PermissionGroupResponseModel> createPermissionGroup(
    PermissionGroupResponseModel request,
  );
  FutureData<PermissionGroupResponseModel> updatePermissionGroup(
    PermissionGroupResponseModel request,
  );
  FutureVoid deletePermissionGroup(String id);
}

@LazySingleton(as: UsersRemoteDataSource)
final class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  const UsersRemoteDataSourceImpl({required SupabaseDatabaseClient database})
    : _database = database;

  final SupabaseDatabaseClient _database;

  // ============================================
  // User Profiles
  // ============================================

  @override
  FutureList<UserProfileResponseModel> getUserProfiles(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'user_profiles',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(UserProfileResponseModel.fromJson).toList();
      });

  @override
  FutureData<UserProfileResponseModel> getUserProfileById(String id) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectOne(
          table: 'user_profiles',
          filters: [
            SupabaseFilter.eq('id', id),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );

        if (response == null) {
          throw Exception('Usuário não encontrado'.hardcoded);
        }

        return UserProfileResponseModel.fromJson(response);
      });

  @override
  FutureData<UserProfileResponseModel> updateUserProfile(
    UserProfileResponseModel request,
  ) => SupabaseHandler.call(() async {
    final response = await _database.update(
      table: 'user_profiles',
      values: request.toJson(),
      filters: [SupabaseFilter.eq('id', request.id)],
    );
    return UserProfileResponseModel.fromJson(response.first);
  });

  @override
  FutureVoid deleteUserProfile(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'user_profiles',
      values: {'deleted_at': DateTime.now().toIso8601String()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  FutureVoid inviteUser({
    required String email,
    required String companyId,
    required String groupId,
  }) => SupabaseHandler.voidCall(() async {
    await _database.invokeFunction(
      'invite-user',
      method: HttpMethod.post,
      body: {
        'email': email,
        'company_id': companyId,
        'permission_group_id': groupId,
      },
    );
  });

  // ============================================
  // Permission Groups
  // ============================================

  @override
  FutureList<PermissionGroupResponseModel> getPermissionGroups(
    String companyId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'permission_groups',
      filters: [
        SupabaseFilter.eq('company_id', companyId),
        SupabaseFilter.isFilter('deleted_at', null),
      ],
    );
    return response.map(PermissionGroupResponseModel.fromJson).toList();
  });

  @override
  FutureData<PermissionGroupResponseModel> createPermissionGroup(
    PermissionGroupResponseModel request,
  ) => SupabaseHandler.call(() async {
    final response = await _database.insert(
      table: 'permission_groups',
      values: request.toJson(),
    );
    return PermissionGroupResponseModel.fromJson(response.first);
  });

  @override
  FutureData<PermissionGroupResponseModel> updatePermissionGroup(
    PermissionGroupResponseModel request,
  ) => SupabaseHandler.call(() async {
    final response = await _database.update(
      table: 'permission_groups',
      values: request.toJson(),
      filters: [SupabaseFilter.eq('id', request.id)],
    );
    return PermissionGroupResponseModel.fromJson(response.first);
  });

  @override
  FutureVoid deletePermissionGroup(String id) =>
      SupabaseHandler.voidCall(() async {
        await _database.update(
          table: 'permission_groups',
          values: {'deleted_at': DateTime.now().toIso8601String()},
          filters: [SupabaseFilter.eq('id', id)],
        );
      });
}
