import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:injectable/injectable.dart';


abstract interface class CompanyLocalDataSource {}

@LazySingleton(as: CompanyLocalDataSource)
final class CompanyLocalDataSourceImpl implements CompanyLocalDataSource {
  CompanyLocalDataSourceImpl({
    required LocalStorageClient localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalStorageClient _localDatabase;
}
