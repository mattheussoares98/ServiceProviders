import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:injectable/injectable.dart';


abstract interface class UsersLocalDataSource {}

@LazySingleton(as: UsersLocalDataSource)
final class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  UsersLocalDataSourceImpl({
    required LocalStorageClient localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalStorageClient _localDatabase;
}
