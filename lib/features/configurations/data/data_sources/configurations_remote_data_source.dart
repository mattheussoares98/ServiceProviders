import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/configurations/data/models/responses/configurations_response_model.dart';

abstract interface class ConfigurationsRemoteDataSource {
  FutureData<ConfigurationsResponseModel> getConfigurations(String userId);
  FutureVoid saveConfigurations({
    required String userId,
    required bool pushNotificationsEnabled,
    required String themeMode,
  });
}

@LazySingleton(as: ConfigurationsRemoteDataSource)
final class ConfigurationsRemoteDataSourceImpl
    implements ConfigurationsRemoteDataSource {
  const ConfigurationsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureData<ConfigurationsResponseModel> getConfigurations(String userId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectOne(
          table: 'user_configurations',
          filters: [SupabaseFilter.eq('user_id', userId)],
        );
        if (response == null) {
          return const ConfigurationsResponseModel(
            pushNotificationsEnabled: true,
            themeMode: 'system',
          );
        }
        return ConfigurationsResponseModel.fromJson(response);
      });

  @override
  FutureVoid saveConfigurations({
    required String userId,
    required bool pushNotificationsEnabled,
    required String themeMode,
  }) =>
      SupabaseHandler.voidCall(() async {
        await _database.upsert(
          table: 'user_configurations',
          values: {
            'user_id': userId,
            'push_notifications_enabled': pushNotificationsEnabled,
            'theme_mode': themeMode,
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      });
}
