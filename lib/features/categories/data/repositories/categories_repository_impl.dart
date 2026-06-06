import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/data/handlers/repository_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_local_data_source.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:clean_architecture/features/categories/data/models/responses/category_response_model.dart';
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

  @override
  FutureList<CategoryEntity> getCategories(String companyId) =>
      RepositoryHandler.fetchFromLocalAndMapList<
        CategoryResponseModel,
        CategoryEntity
      >(localCallback: () => _localDataSource.getCategories(companyId));

  @override
  FutureBool createCategory(CategoryEntity category) =>
      _localDataSource.saveCategory(CategoryResponseModel.fromEntity(category));

  @override
  FutureBool updateCategory(CategoryEntity category) =>
      _localDataSource.saveCategory(CategoryResponseModel.fromEntity(category));

  @override
  FutureBool deleteCategory(String id) => _localDataSource.deleteCategory(id);
}
