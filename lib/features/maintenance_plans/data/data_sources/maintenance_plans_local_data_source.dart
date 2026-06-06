import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:injectable/injectable.dart';


abstract interface class MaintenancePlansLocalDataSource {}

@LazySingleton(as: MaintenancePlansLocalDataSource)
final class MaintenancePlansLocalDataSourceImpl implements MaintenancePlansLocalDataSource {
  MaintenancePlansLocalDataSourceImpl({
    required LocalStorageClient localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalStorageClient _localDatabase;
}
