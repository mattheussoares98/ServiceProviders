import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_local_data_source.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_remote_data_source.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: UsersRepository)
final class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl({
    required InternetClient internet,
    required UsersRemoteDataSource remoteDataSource,
    required UsersLocalDataSource localDataSource,
  })  : _internet = internet,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final InternetClient _internet;
  final UsersRemoteDataSource _remoteDataSource;
  final UsersLocalDataSource _localDataSource;
}
