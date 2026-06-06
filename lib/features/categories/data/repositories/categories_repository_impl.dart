import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_local_data_source.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/categories/domain/repositories/categories_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CategoriesRepository)
final class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl({
    required InternetClient internet,
    required CategoriesRemoteDataSource remoteDataSource,
    required CategoriesLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final CategoriesRemoteDataSource _remoteDataSource;
  final CategoriesLocalDataSource _localDataSource;

  // TODO: Wire to local/remote data sources with RepositoryHandler
  @override
  FutureList<CategoryEntity> getCategories(String companyId) =>
      throw UnimplementedError();

  @override
  FutureBool createCategory(CategoryEntity category) =>
      throw UnimplementedError();

  @override
  FutureBool updateCategory(CategoryEntity category) =>
      throw UnimplementedError();

  @override
  FutureBool deleteCategory(String id) => throw UnimplementedError();
}
