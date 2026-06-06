import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:injectable/injectable.dart';


abstract interface class AttachmentsLocalDataSource {}

@LazySingleton(as: AttachmentsLocalDataSource)
final class AttachmentsLocalDataSourceImpl implements AttachmentsLocalDataSource {
  AttachmentsLocalDataSourceImpl({
    required LocalStorageClient localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalStorageClient _localDatabase;
}
