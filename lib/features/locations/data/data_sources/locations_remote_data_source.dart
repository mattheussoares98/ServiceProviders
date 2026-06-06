import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:injectable/injectable.dart';

abstract interface class LocationsRemoteDataSource {}

@LazySingleton(as: LocationsRemoteDataSource)
final class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  const LocationsRemoteDataSourceImpl({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;
}
