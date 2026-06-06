import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:injectable/injectable.dart';


abstract interface class ChecklistsLocalDataSource {}

@LazySingleton(as: ChecklistsLocalDataSource)
final class ChecklistsLocalDataSourceImpl implements ChecklistsLocalDataSource {
  ChecklistsLocalDataSourceImpl({
    required LocalStorageClient localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalStorageClient _localDatabase;
}
