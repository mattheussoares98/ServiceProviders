import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_local_data_source.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/requests/category_request_model.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/responses/category_model.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';
import 'package:o_jogo_da_obra/features/categories/domain/repositories/categories_repository.dart';

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
      RepositoryHandler.fetchWithFallbackAndMapList<
        CategoryModel,
        CategoryEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getCategories(companyId),
        localCallback: () => _localDataSource.getCategories(companyId),
        onRemoteSuccess: _localDataSource.saveCategories,
      );

  @override
  FutureBool createCategory(CategoryEntity category) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () =>
            _localDataSource.saveCategory(CategoryModel.fromEntity(category)),
        remoteCallback: () async {
          final result = await _remoteDataSource.createCategory(
            CategoryRequestModel.fromEntity(category),
          );
          if (result is SuccessState<CategoryModel>) {
            await _localDataSource.saveCategory(result.data!);
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
  FutureBool updateCategory(CategoryEntity category) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () =>
            _localDataSource.saveCategory(CategoryModel.fromEntity(category)),
        remoteCallback: () async {
          final result = await _remoteDataSource.updateCategory(
            CategoryRequestModel.fromEntity(category),
          );
          if (result is SuccessState<CategoryModel>) {
            await _localDataSource.saveCategory(result.data!);
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
  FutureBool deleteCategory(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.deleteCategory(id),
        remoteCallback: () async {
          final result = await _remoteDataSource.deleteCategory(id);
          if (result is SuccessState<void>) {
            await _localDataSource.deleteCategory(id);
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
