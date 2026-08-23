import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sync/data/models/sync_error_model.dart';

abstract interface class SyncRemoteDataSource {
  FutureBool reportSyncError(SyncErrorModel error);
}

@LazySingleton(as: SyncRemoteDataSource)
final class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  const SyncRemoteDataSourceImpl({required SupabaseDatabaseClient database})
    : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureBool reportSyncError(SyncErrorModel error) =>
      SupabaseHandler.call(() async {
        await _database.insert(table: 'sync_errors', values: error.toJson());
        return true;
      });
}
