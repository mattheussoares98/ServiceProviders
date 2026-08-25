import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/config/app_config.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/permission_group_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_invitation_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';
import 'package:o_jogo_da_obra/routing/helper/route_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class UsersRemoteDataSource {
  // User Profiles
  FutureList<UserProfileModel> getUserProfiles(String companyId);
  FutureData<UserProfileModel> getUserProfileById(String id);
  FutureData<UserProfileModel> updateUserProfile(UserProfileModel request);
  FutureVoid deleteUserProfile(String id);
  Stream<RealtimeEvent<UserProfileModel>> watchUserProfilesRealtime({
    String? companyId,
  });
  FutureVoid inviteUser({
    required String email,
    required String companyId,
    required String groupId,
  });
  FutureList<UserInvitationModel> getPendingInvitations(String companyId);
  FutureVoid revokeInvitation(String id);
  FutureVoid resendInvitation(UserInvitationEntity invitation);

  // Permission Groups
  FutureList<PermissionGroupModel> getPermissionGroups(String companyId);
  FutureData<PermissionGroupModel> createPermissionGroup(
    PermissionGroupModel request,
  );
  FutureData<PermissionGroupModel> updatePermissionGroup(
    PermissionGroupModel request,
  );
  FutureVoid deletePermissionGroup(String id);
}

@LazySingleton(as: UsersRemoteDataSource)
final class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  const UsersRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
    required SupabaseRealtimeClient realtimeClient,
  }) : _database = database,
       _realtimeClient = realtimeClient;

  final SupabaseDatabaseClient _database;
  final SupabaseRealtimeClient _realtimeClient;

  // ============================================
  // User Profiles
  // ============================================

  @override
  FutureList<UserProfileModel> getUserProfiles(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'user_profiles',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(UserProfileModel.fromJson).toList();
      });

  @override
  FutureData<UserProfileModel> getUserProfileById(String id) =>
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

        return UserProfileModel.fromJson(response);
      });

  @override
  FutureData<UserProfileModel> updateUserProfile(UserProfileModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.update(
          table: 'user_profiles',
          values: request.toJson(),
          filters: [SupabaseFilter.eq('id', request.id)],
        );
        return UserProfileModel.fromJson(response.first);
      });

  @override
  FutureVoid deleteUserProfile(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'user_profiles',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  Stream<RealtimeEvent<UserProfileModel>> watchUserProfilesRealtime({
    String? companyId,
  }) {
    final filter = companyId != null && companyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          )
        : null;

    return _realtimeClient
        .streamTableChanges(
          table: 'user_profiles',
          filter: filter,
        )
        .map(
          (payload) =>
              RealtimePayloadMapper.map(payload, UserProfileModel.fromJson),
        );
  }

  @override
  FutureVoid inviteUser({
    required String email,
    required String companyId,
    required String groupId,
  }) => SupabaseHandler.voidCall(() async {
    final redirectUrl = '${AppConfigUtil.I.webBaseUrl}$kAcceptInvitePath';
    await _database.invokeFunction(
      'invite-user',
      method: HttpMethod.post,
      body: {
        'email': email,
        'company_id': companyId,
        'permission_group_id': groupId,
        'redirect_url': redirectUrl,
      },
    );
  });

  @override
  FutureList<UserInvitationModel> getPendingInvitations(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.rpc(
          functionName: 'get_pending_invitations',
          params: {'target_company_id': companyId},
        );
        return (response as List<dynamic>)
            .map((e) => UserInvitationModel.fromJson(e as MapDynamic))
            .toList();
      });

  @override
  FutureVoid revokeInvitation(String id) => SupabaseHandler.voidCall(() async {
    await _database.rpc(
      functionName: 'revoke_invitation',
      params: {'invitation_id': id},
    );
  });

  @override
  FutureVoid resendInvitation(UserInvitationEntity invitation) =>
      SupabaseHandler.voidCall(() async {
        final redirectUrl = '${AppConfigUtil.I.webBaseUrl}$kAcceptInvitePath';
        await _database.invokeFunction(
          'invite-user',
          method: HttpMethod.post,
          body: {
            'email': invitation.email,
            'company_id': invitation.companyId,
            'permission_group_id': invitation.permissionGroupId,
            'redirect_url': redirectUrl,
          },
        );
      });

  // ============================================
  // Permission Groups
  // ============================================

  @override
  FutureList<PermissionGroupModel> getPermissionGroups(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'permission_groups',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(PermissionGroupModel.fromJson).toList();
      });

  @override
  FutureData<PermissionGroupModel> createPermissionGroup(
    PermissionGroupModel request,
  ) => SupabaseHandler.call(() async {
    final response = await _database.insert(
      table: 'permission_groups',
      values: request.toJson(),
    );
    return PermissionGroupModel.fromJson(response.first);
  });

  @override
  FutureData<PermissionGroupModel> updatePermissionGroup(
    PermissionGroupModel request,
  ) => SupabaseHandler.call(() async {
    final response = await _database.update(
      table: 'permission_groups',
      values: request.toJson(),
      filters: [SupabaseFilter.eq('id', request.id)],
    );
    return PermissionGroupModel.fromJson(response.first);
  });

  @override
  FutureVoid deletePermissionGroup(String id) =>
      SupabaseHandler.voidCall(() async {
        await _database.update(
          table: 'permission_groups',
          values: {'deleted_at': DateTime.now().toIsoUtcString()},
          filters: [SupabaseFilter.eq('id', id)],
        );
      });
}
