import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:injectable/injectable.dart';

abstract interface class AttachmentsRemoteDataSource {}

@LazySingleton(as: AttachmentsRemoteDataSource)
final class AttachmentsRemoteDataSourceImpl implements AttachmentsRemoteDataSource {
  const AttachmentsRemoteDataSourceImpl({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;
}
