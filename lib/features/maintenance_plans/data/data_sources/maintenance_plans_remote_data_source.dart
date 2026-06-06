import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:injectable/injectable.dart';

abstract interface class MaintenancePlansRemoteDataSource {}

@LazySingleton(as: MaintenancePlansRemoteDataSource)
final class MaintenancePlansRemoteDataSourceImpl implements MaintenancePlansRemoteDataSource {
  const MaintenancePlansRemoteDataSourceImpl({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;
}
