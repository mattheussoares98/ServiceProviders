import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/http/http_client.dart';

abstract interface class MaintenancePlansRemoteDataSource {}

@LazySingleton(as: MaintenancePlansRemoteDataSource)
final class MaintenancePlansRemoteDataSourceImpl
    implements MaintenancePlansRemoteDataSource {
  const MaintenancePlansRemoteDataSourceImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  final HttpClient _httpClient;
}
