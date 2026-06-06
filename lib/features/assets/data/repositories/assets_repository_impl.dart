import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/features/assets/data/data_sources/assets_local_data_source.dart';
import 'package:clean_architecture/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:clean_architecture/features/assets/domain/repositories/assets_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AssetsRepository)
final class AssetsRepositoryImpl implements AssetsRepository {
  AssetsRepositoryImpl({
    required InternetClient internet,
    required AssetsRemoteDataSource remoteDataSource,
    required AssetsLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final AssetsRemoteDataSource _remoteDataSource;
  final AssetsLocalDataSource _localDataSource;
}
