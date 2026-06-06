import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_local_data_source.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:clean_architecture/features/categories/domain/repositories/categories_repository.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: CategoriesRepository)
final class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl({
    required InternetClient internet,
    required CategoriesRemoteDataSource remoteDataSource,
    required CategoriesLocalDataSource localDataSource,
  })  : _internet = internet,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final InternetClient _internet;
  final CategoriesRemoteDataSource _remoteDataSource;
  final CategoriesLocalDataSource _localDataSource;
}
