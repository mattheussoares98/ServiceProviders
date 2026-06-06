import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_local_data_source.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_remote_data_source.dart';
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

  // TODO: Wire to local/remote data sources with RepositoryHandler
  @override
  FutureList<UserProfileEntity> getUserProfiles(String companyId) =>
      throw UnimplementedError();

  @override
  FutureData<UserProfileEntity> getUserProfileById(String id) =>
      throw UnimplementedError();

  @override
  FutureBool updateUserProfile(UserProfileEntity userProfile) =>
      throw UnimplementedError();

  @override
  FutureBool deleteUserProfile(String id) => throw UnimplementedError();

  @override
  FutureList<PermissionGroupEntity> getPermissionGroups(String companyId) =>
      throw UnimplementedError();

  @override
  FutureBool createPermissionGroup(PermissionGroupEntity group) =>
      throw UnimplementedError();

  @override
  FutureBool updatePermissionGroup(PermissionGroupEntity group) =>
      throw UnimplementedError();

  @override
  FutureBool deletePermissionGroup(String id) => throw UnimplementedError();
}
