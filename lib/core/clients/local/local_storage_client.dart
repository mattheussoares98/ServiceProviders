import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

abstract interface class LocalStorageClient {
  Future<void> saveThemeMode(String themeMode);
  String getThemeMode();
  Future<void> savePushNotifications(bool enabled);
  bool getPushNotifications();
  Future<void> saveUserSession(UserDataEntity userSession);
  UserDataEntity? getUserSession();
  Future<void> clearUserSession();
  Future<void> clearAll();
}

@module
abstract class LocalStorageClientModule {
  @preResolve // It tells GetIt that it must await the asynchronous setup (init()) of LocalStorageClientImpl before finalizing the application startup. This ensures that the key-value cache is fully loaded into memory before any screen or HTTP interceptor attempts to read from it.
  Future<LocalStorageClient> provideLocalStorageClient(
    AppDatabase database,
  ) async {
    final client = LocalStorageClientImpl(database: database);
    try {
      await client.init();
    } catch (_) {}
    return client;
  }
}

final class LocalStorageClientImpl implements LocalStorageClient {
  LocalStorageClientImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;
  String _themeMode = 'system';
  bool _pushNotificationsEnabled = true;
  UserDataEntity? _userSession;

  Future<void> init() async {
    final setting = await (_database.select(
      _database.appSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (setting != null) {
      _themeMode = setting.themeMode;
      _pushNotificationsEnabled = setting.pushNotificationsEnabled;
    }

    final session = await (_database.select(
      _database.userSessions,
    )..limit(1)).getSingleOrNull();
    if (session != null) {
      final profile =
          await (_database.select(_database.userProfiles)
                ..where((t) => t.id.equals(session.id) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (profile == null) {
        return;
      }

      _userSession = UserDataEntity(
        user: UserProfileResponseModel.fromDb(profile).toEntity(),
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
    }
  }

  @override
  Future<void> saveThemeMode(String themeMode) async {
    _themeMode = themeMode;
    await _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion(id: const Value(1), themeMode: Value(themeMode)),
        );
  }

  @override
  String getThemeMode() => _themeMode;

  @override
  Future<void> savePushNotifications(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    await _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion(
            id: const Value(1),
            pushNotificationsEnabled: Value(enabled),
          ),
        );
  }

  @override
  bool getPushNotifications() => _pushNotificationsEnabled;

  @override
  Future<void> saveUserSession(UserDataEntity userSession) async {
    _userSession = userSession;
    await _database.transaction(() async {
      await _database.delete(_database.userSessions).go();
      await _database
          .into(_database.userSessions)
          .insert(
            UserSessionsCompanion(
              id: Value(userSession.user.id),
              name: Value(userSession.user.name),
              email: Value(userSession.user.email),
              isActive: Value(userSession.user.isActive),
              accessToken: Value(userSession.accessToken),
              refreshToken: Value(userSession.refreshToken),
            ),
          );
    });
  }

  @override
  UserDataEntity? getUserSession() => _userSession;

  @override
  Future<void> clearUserSession() async {
    _userSession = null;
    await _database.delete(_database.userSessions).go();
  }

  @override
  Future<void> clearAll() async {
    _themeMode = 'system';
    _pushNotificationsEnabled = false;
    _userSession = null;
    await _database.transaction(() async {
      await _database.delete(_database.appSettings).go();
      await _database.delete(_database.userSessions).go();
    });
  }
}
