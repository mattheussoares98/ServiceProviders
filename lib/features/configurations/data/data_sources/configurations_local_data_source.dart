import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:clean_architecture/core/data/handlers/error_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/configurations/domain/entities/configurations_entity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

abstract interface class ConfigurationsLocalDataSource {
  FutureData<ConfigurationsEntity> getConfigurations();
  FutureBool savePushNotifications(bool enabled);
}

@LazySingleton(as: ConfigurationsLocalDataSource)
final class ConfigurationsLocalDataSourceImpl
    implements ConfigurationsLocalDataSource {
  const ConfigurationsLocalDataSourceImpl({
    required LocalStorageClient localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalStorageClient _localDatabase;

  @override
  FutureData<ConfigurationsEntity> getConfigurations() =>
      ErrorHandler.execute(() async {
        final pushEnabled = _localDatabase.getPushNotifications();
        final themeMode = _localDatabase.getThemeMode();
        var systemEnabled = true;
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
          data: ConfigurationsEntity(
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
}
