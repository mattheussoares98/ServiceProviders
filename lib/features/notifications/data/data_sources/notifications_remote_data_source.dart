import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

abstract interface class NotificationsRemoteDataSource {
  FutureBool registerDeviceToken({
    required String userId,
    required String deviceToken,
    required String platform,
  });

  FutureBool deleteDeviceToken({
    required String userId,
    required String deviceToken,
  });
}

@LazySingleton(as: NotificationsRemoteDataSource)
final class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureBool registerDeviceToken({
    required String userId,
    required String deviceToken,
    required String platform,
  }) => SupabaseHandler.call(() async {
    await _database.upsert(
      table: 'user_device_tokens',
      values: {
        'user_id': userId,
        'device_token': deviceToken,
        'platform': platform,
        'updated_at': DateTime.now().toIsoUtcString(),
      },
      onConflict: 'user_id,device_token',
    );
    return true;
  });

  @override
  FutureBool deleteDeviceToken({
    required String userId,
    required String deviceToken,
  }) => SupabaseHandler.call(() async {
    await _database.delete(
      table: 'user_device_tokens',
      filters: [
        SupabaseFilter.eq('user_id', userId),
        SupabaseFilter.eq('device_token', deviceToken),
      ],
    );
    return true;
  });
}
