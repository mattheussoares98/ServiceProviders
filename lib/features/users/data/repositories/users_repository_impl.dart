import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/data/data_sources/users_local_data_source.dart';
import 'package:o_jogo_da_obra/features/users/data/data_sources/users_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/permission_group_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_invitation_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/repositories/users_repository.dart';

@LazySingleton(as: UsersRepository)
final class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl({
    required InternetClient internet,
    required UsersRemoteDataSource remoteDataSource,
    required UsersLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final UsersRemoteDataSource _remoteDataSource;
  final UsersLocalDataSource _localDataSource;

  // ============================================
  // User Profiles
  // ============================================

  @override
  FutureList<UserProfileEntity> getUserProfiles(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        UserProfileModel,
        UserProfileEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getUserProfiles(companyId),
        localCallback: () => _localDataSource.getUserProfiles(companyId),
        onRemoteSuccess: _localDataSource.saveUserProfiles,
      );

  @override
  FutureData<UserProfileEntity> getUserProfileById(String id) =>
      RepositoryHandler.fetchWithFallbackAndMap<
        UserProfileModel,
        UserProfileEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getUserProfileById(id),
        localCallback: () => _localDataSource.getUserProfileById(id),
        onRemoteSuccess: _localDataSource.saveUserProfile,
      );

  @override
  FutureBool updateUserProfile(UserProfileEntity userProfile) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.updateUserProfile(
            UserProfileModel.fromEntity(userProfile),
          );
          if (result is SuccessState<UserProfileModel>) {
            await _localDataSource.saveUserProfile(result.data!);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureBool deleteUserProfile(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.deleteUserProfile(id);
          if (result is SuccessState<void>) {
            await _localDataSource.deleteUserProfile(id);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureVoid inviteUser({
    required String email,
    required String companyId,
    required String groupId,
  }) => RepositoryHandler.fetchWithFallback(
    isInternetConnected: _internet.isConnected,
    remoteCallback: () => _remoteDataSource.inviteUser(
      email: email,
      companyId: companyId,
      groupId: groupId,
    ),
  );

  @override
  FutureList<UserInvitationEntity> getPendingInvitations(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        UserInvitationModel,
        UserInvitationEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () =>
            _remoteDataSource.getPendingInvitations(companyId),
      );

  @override
  FutureBool revokeInvitation(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.revokeInvitation(id);
          if (result is SuccessState<void>) {
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureVoid resendInvitation(UserInvitationEntity invitation) =>
      RepositoryHandler.fetchWithFallback(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.resendInvitation(invitation),
      );

  // ============================================
  // Permission Groups
  // ============================================

  @override
  FutureList<PermissionGroupEntity> getPermissionGroups(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        PermissionGroupModel,
        PermissionGroupEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getPermissionGroups(companyId),
        localCallback: () => _localDataSource.getPermissionGroups(companyId),
        onRemoteSuccess: _localDataSource.savePermissionGroups,
      );

  @override
  FutureBool createPermissionGroup(PermissionGroupEntity group) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.createPermissionGroup(
            PermissionGroupModel.fromEntity(group),
          );
          if (result is SuccessState<PermissionGroupModel>) {
            await _localDataSource.savePermissionGroup(result.data!);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureBool updatePermissionGroup(PermissionGroupEntity group) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.updatePermissionGroup(
            PermissionGroupModel.fromEntity(group),
          );
          if (result is SuccessState<PermissionGroupModel>) {
            await _localDataSource.savePermissionGroup(result.data!);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureBool deletePermissionGroup(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.deletePermissionGroup(id);
          if (result is SuccessState<void>) {
            await _localDataSource.deletePermissionGroup(id);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );
}
