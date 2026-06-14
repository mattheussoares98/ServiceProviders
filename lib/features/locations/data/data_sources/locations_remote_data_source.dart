import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:clean_architecture/core/constants/api_endpoints.dart';
import 'package:clean_architecture/core/data/handlers/api_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/locations/data/models/requests/area_request_model.dart';
import 'package:clean_architecture/features/locations/data/models/requests/location_request_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/area_response_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/location_response_model.dart';
import 'package:injectable/injectable.dart';

abstract interface class LocationsRemoteDataSource {
  FutureList<LocationModel> getLocations(String companyId);
  FutureData<LocationModel> createLocation(LocationRequestModel request);
  FutureData<LocationModel> updateLocation(LocationRequestModel request);
  FutureVoid deleteLocation(String id);

  FutureList<AreaResponseModel> getAreasByLocation(String locationId);
  FutureData<AreaResponseModel> createArea(AreaRequestModel request);
  FutureData<AreaResponseModel> updateArea(AreaRequestModel request);
  FutureVoid deleteArea(String id);
}

@LazySingleton(as: LocationsRemoteDataSource)
final class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  const LocationsRemoteDataSourceImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  final HttpClient _httpClient;

  @override
  FutureList<LocationModel> getLocations(String companyId) => ApiHandler.call(
    () => _httpClient.get(
      ApiEndpoints.locations,
      queryParameters: {'company_id': companyId},
    ),
    fromJson: LocationModel.fromJson,
  );

  @override
  FutureData<LocationModel> createLocation(LocationRequestModel request) =>
      ApiHandler.call(
        () => _httpClient.post(ApiEndpoints.locations, data: request.toJson()),
        fromJson: LocationModel.fromJson,
      );

  @override
  FutureData<LocationModel> updateLocation(LocationRequestModel request) =>
      ApiHandler.call(
        () => _httpClient.put(
          ApiEndpoints.locationById(request.id),
          data: request.toJson(),
        ),
        fromJson: LocationModel.fromJson,
      );

  @override
  FutureVoid deleteLocation(String id) => ApiHandler.voidCall(
    () => _httpClient.delete(ApiEndpoints.locationById(id)),
  );

  @override
  FutureList<AreaResponseModel> getAreasByLocation(String locationId) =>
      ApiHandler.call(
        () => _httpClient.get(
          ApiEndpoints.areas,
          queryParameters: {'location_id': locationId},
        ),
        fromJson: AreaResponseModel.fromJson,
      );

  @override
  FutureData<AreaResponseModel> createArea(AreaRequestModel request) =>
      ApiHandler.call(
        () => _httpClient.post(ApiEndpoints.areas, data: request.toJson()),
        fromJson: AreaResponseModel.fromJson,
      );

  @override
  FutureData<AreaResponseModel> updateArea(AreaRequestModel request) =>
      ApiHandler.call(
        () => _httpClient.put(
          ApiEndpoints.areaById(request.id),
          data: request.toJson(),
        ),
        fromJson: AreaResponseModel.fromJson,
      );

  @override
  FutureVoid deleteArea(String id) =>
      ApiHandler.voidCall(() => _httpClient.delete(ApiEndpoints.areaById(id)));
}
