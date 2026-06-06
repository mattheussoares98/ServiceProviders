import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:injectable/injectable.dart';

abstract interface class AssetsLocalDataSource {}

@LazySingleton(as: AssetsLocalDataSource)
final class AssetsLocalDataSourceImpl implements AssetsLocalDataSource {
  AssetsLocalDataSourceImpl({required LocalStorageClient localDatabase})
    : _localDatabase = localDatabase;

  final LocalStorageClient _localDatabase;
}
