import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:injectable/injectable.dart';


abstract interface class WorkOrdersLocalDataSource {}

@LazySingleton(as: WorkOrdersLocalDataSource)
final class WorkOrdersLocalDataSourceImpl implements WorkOrdersLocalDataSource {
  WorkOrdersLocalDataSourceImpl({
    required LocalStorageClient localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalStorageClient _localDatabase;
}
