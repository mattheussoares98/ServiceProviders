import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/configurations/data/models/responses/configurations_model.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';

abstract interface class ConfigurationsLocalDataSource {
  FutureData<ConfigurationsModel> getConfigurations();
  FutureBool savePushNotifications(bool enabled);
  FutureBool saveConfigurations(ConfigurationsEntity configurations);
  FutureBool saveThemeMode(String themeMode);
  FutureVoid clearAll();
}

@LazySingleton(as: ConfigurationsLocalDataSource)
final class ConfigurationsLocalDataSourceImpl
    implements ConfigurationsLocalDataSource {
  const ConfigurationsLocalDataSourceImpl({
    required LocalStorageClient localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalStorageClient _localDatabase;

  @override
  FutureData<ConfigurationsModel> getConfigurations() =>
      ErrorHandler.execute(() async {
        final pushEnabled = _localDatabase.getPushNotifications();
        final themeMode = _localDatabase.getThemeMode();
        bool systemEnabled = true;
        try {
          final settings = await FirebaseMessaging.instance
              .getNotificationSettings();
          systemEnabled =
              settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
        } catch (_) {
          systemEnabled = false;
        }
        return SuccessState(
          data: ConfigurationsModel(
            pushNotificationsEnabled: pushEnabled,
            themeMode: themeMode,
            systemNotificationsEnabled: systemEnabled,
          ),
        );
      });

  @override
  FutureBool savePushNotifications(bool enabled) =>
      ErrorHandler.execute(() async {
        await _localDatabase.savePushNotifications(enabled);
        return const SuccessState(data: true);
      });

  @override
  FutureBool saveConfigurations(ConfigurationsEntity configurations) =>
      ErrorHandler.execute(() async {
        await _localDatabase.savePushNotifications(
          configurations.pushNotificationsEnabled,
        );
        await _localDatabase.saveThemeMode(configurations.themeMode);
        return const SuccessState(data: true);
      });

  @override
  FutureBool saveThemeMode(String themeMode) => ErrorHandler.execute(() async {
    await _localDatabase.saveThemeMode(themeMode);
    return const SuccessState(data: true);
  });

  @override
  FutureVoid clearAll() => ErrorHandler.execute(() async {
    await _localDatabase.clearAll();
    return SuccessState.nil;
  });
}
