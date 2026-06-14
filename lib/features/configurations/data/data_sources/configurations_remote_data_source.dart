import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:injectable/injectable.dart';

abstract interface class ConfigurationsRemoteDataSource {}

@LazySingleton(as: ConfigurationsRemoteDataSource)
final class ConfigurationsRemoteDataSourceImpl
    implements ConfigurationsRemoteDataSource {
  const ConfigurationsRemoteDataSourceImpl({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;
}
