import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:injectable/injectable.dart';

abstract interface class ChecklistsRemoteDataSource {}

@LazySingleton(as: ChecklistsRemoteDataSource)
final class ChecklistsRemoteDataSourceImpl implements ChecklistsRemoteDataSource {
  const ChecklistsRemoteDataSourceImpl({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;
}
