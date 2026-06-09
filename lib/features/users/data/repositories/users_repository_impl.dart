import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/data/handlers/repository_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_local_data_source.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_remote_data_source.dart';
import 'package:clean_architecture/features/users/data/models/responses/permission_group_response_model.dart';
import 'package:clean_architecture/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

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

  @override
  FutureList<UserProfileEntity> getUserProfiles(String companyId) =>
      RepositoryHandler.fetchFromLocalAndMapList<
        UserProfileResponseModel,
        UserProfileEntity
      >(localCallback: () => _localDataSource.getUserProfiles(companyId));

  @override
  FutureData<UserProfileEntity> getUserProfileById(String id) =>
      //TODO add remote loading here
      RepositoryHandler.fetchFromLocalAndMap<
        UserProfileResponseModel,
        UserProfileEntity
      >(localCallback: () => _localDataSource.getUserProfileById(id));

  @override
  FutureBool updateUserProfile(UserProfileEntity userProfile) =>
      _localDataSource.saveUserProfile(
        UserProfileResponseModel.fromEntity(userProfile),
      );

  @override
  FutureBool deleteUserProfile(String id) =>
      _localDataSource.deleteUserProfile(id);

  @override
  FutureList<PermissionGroupEntity> getPermissionGroups(String companyId) =>
      RepositoryHandler.fetchFromLocalAndMapList<
        PermissionGroupResponseModel,
        PermissionGroupEntity
      >(localCallback: () => _localDataSource.getPermissionGroups(companyId));

  @override
  FutureBool createPermissionGroup(PermissionGroupEntity group) =>
      _localDataSource.savePermissionGroup(
        PermissionGroupResponseModel.fromEntity(group),
      );

  @override
  FutureBool updatePermissionGroup(PermissionGroupEntity group) =>
      _localDataSource.savePermissionGroup(
        PermissionGroupResponseModel.fromEntity(group),
      );

  @override
  FutureBool deletePermissionGroup(String id) =>
      _localDataSource.deletePermissionGroup(id);
}
