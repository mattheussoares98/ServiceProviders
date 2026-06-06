import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:clean_architecture/core/constants/api_endpoints.dart';
import 'package:clean_architecture/core/data/handlers/api_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/categories/data/models/requests/category_request_model.dart';
import 'package:clean_architecture/features/categories/data/models/responses/category_response_model.dart';
import 'package:injectable/injectable.dart';

abstract interface class CategoriesRemoteDataSource {
  FutureList<CategoryResponseModel> getCategories(String companyId);
  FutureData<CategoryResponseModel> createCategory(
    CategoryRequestModel request,
  );
  FutureData<CategoryResponseModel> updateCategory(
    CategoryRequestModel request,
  );
  FutureVoid deleteCategory(String id);
}

@LazySingleton(as: CategoriesRemoteDataSource)
final class CategoriesRemoteDataSourceImpl
    implements CategoriesRemoteDataSource {
  const CategoriesRemoteDataSourceImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  final HttpClient _httpClient;

  @override
  FutureList<CategoryResponseModel> getCategories(String companyId) =>
      ApiHandler.call(
        () => _httpClient.get(
          ApiEndpoints.categories,
          queryParameters: {'company_id': companyId},
        ),
        fromJson: CategoryResponseModel.fromJson,
      );

  @override
  FutureData<CategoryResponseModel> createCategory(
    CategoryRequestModel request,
  ) => ApiHandler.call(
    () => _httpClient.post(ApiEndpoints.categories, data: request.toJson()),
    fromJson: CategoryResponseModel.fromJson,
  );

  @override
  FutureData<CategoryResponseModel> updateCategory(
    CategoryRequestModel request,
  ) => ApiHandler.call(
    () => _httpClient.put(
      ApiEndpoints.categoryById(request.id),
      data: request.toJson(),
    ),
    fromJson: CategoryResponseModel.fromJson,
  );

  @override
  FutureVoid deleteCategory(String id) => ApiHandler.voidCall(
    () => _httpClient.delete(ApiEndpoints.categoryById(id)),
  );
}
