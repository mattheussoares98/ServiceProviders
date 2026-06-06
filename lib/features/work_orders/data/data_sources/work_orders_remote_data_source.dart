import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:injectable/injectable.dart';

abstract interface class WorkOrdersRemoteDataSource {}

@LazySingleton(as: WorkOrdersRemoteDataSource)
final class WorkOrdersRemoteDataSourceImpl implements WorkOrdersRemoteDataSource {
  const WorkOrdersRemoteDataSourceImpl({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;
}
