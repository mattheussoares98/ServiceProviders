import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/http/http_client.dart';

abstract interface class AttachmentsRemoteDataSource {}

@LazySingleton(as: AttachmentsRemoteDataSource)
final class AttachmentsRemoteDataSourceImpl
    implements AttachmentsRemoteDataSource {
  const AttachmentsRemoteDataSourceImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  final HttpClient _httpClient;
}
