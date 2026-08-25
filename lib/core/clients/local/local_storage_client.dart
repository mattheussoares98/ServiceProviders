import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';

abstract interface class LocalStorageClient {
  Future<void> saveThemeMode(String themeMode);
  String getThemeMode();
  Future<void> savePushNotifications(bool enabled);
  bool getPushNotifications();
  Future<void> saveSelectedMode(String? mode);
  String? getSelectedMode();
  Future<void> saveSelectedCompanyId(String? companyId);
  String? getSelectedCompanyId();
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
  String? _selectedMode;
  String? _selectedCompanyId;
  UserDataEntity? _userSession;

  Future<void> init() async {
    final setting = await (_database.select(
      _database.appSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (setting != null) {
      _themeMode = setting.themeMode;
      _pushNotificationsEnabled = setting.pushNotificationsEnabled;
      _selectedMode = setting.selectedMode;
      _selectedCompanyId = setting.selectedCompanyId;
    }

    final session = await (_database.select(
      _database.userSessions,
    )..limit(1)).getSingleOrNull();
    if (session != null) {
      final profile =
          await (_database.select(_database.userProfiles)
                ..where((t) => t.id.equals(session.id) & t.deletedAt.isNull()))
              .getSingleOrNull();

      final userEntity = profile != null
          ? UserProfileModel.fromDb(profile).toEntity()
          : UserProfileEntity(
              id: session.id,
              companyId: '',
              name: session.name,
              email: session.email,
              isActive: session.isActive,
              isAdmin: false,
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
              avatarUrl: null,
              deletedAt: null,
              permissionGroupId: null,
              phone: null,
            );

      _userSession = UserDataEntity(
        user: userEntity,
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
  Future<void> saveSelectedMode(String? mode) async {
    _selectedMode = mode;
    await _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion(id: const Value(1), selectedMode: Value(mode)),
        );
  }

  @override
  String? getSelectedMode() => _selectedMode;

  @override
  Future<void> saveSelectedCompanyId(String? companyId) async {
    _selectedCompanyId = companyId;
    await _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion(
            id: const Value(1),
            selectedCompanyId: Value(companyId),
          ),
        );
  }

  @override
  String? getSelectedCompanyId() => _selectedCompanyId;

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
    _selectedMode = null;
    _selectedCompanyId = null;
    _userSession = null;
    await _database.transaction(() async {
      await _database.delete(_database.appSettings).go();
      await _database.delete(_database.userSessions).go();
    });
  }
}
