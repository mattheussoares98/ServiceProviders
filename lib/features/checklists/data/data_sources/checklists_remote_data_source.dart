import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/http/http_client.dart';

abstract interface class ChecklistsRemoteDataSource {}

@LazySingleton(as: ChecklistsRemoteDataSource)
final class ChecklistsRemoteDataSourceImpl
    implements ChecklistsRemoteDataSource {
  const ChecklistsRemoteDataSourceImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  final HttpClient _httpClient;
}
