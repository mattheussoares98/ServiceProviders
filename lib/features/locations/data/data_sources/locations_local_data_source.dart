import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:injectable/injectable.dart';


abstract interface class LocationsLocalDataSource {}

@LazySingleton(as: LocationsLocalDataSource)
final class LocationsLocalDataSourceImpl implements LocationsLocalDataSource {
  LocationsLocalDataSourceImpl({
    required LocalStorageClient localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalStorageClient _localDatabase;
}
