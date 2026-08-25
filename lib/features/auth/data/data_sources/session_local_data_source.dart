import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/responses/user_data_model.dart';

abstract interface class SessionLocalDataSource {
  Future<UserDataModel?> getUserData();

  Future<void> saveUserData(UserDataModel userData);

  Future<void> clearSelectedMode();

  String? getSelectedMode();

  String? getSelectedCompanyId();

  Future<void> saveSelectedCompanyId(String? companyId);
}

@LazySingleton(as: SessionLocalDataSource)
final class SessionLocalDataSourceImpl implements SessionLocalDataSource {
  SessionLocalDataSourceImpl(this._localStorageClient);
  final LocalStorageClient _localStorageClient;

  @override
  Future<UserDataModel?> getUserData() async {
    final session = _localStorageClient.getUserSession();
    if (session != null) {
      return UserDataModel.fromEntity(session);
    }
    return null;
  }

  @override
  Future<void> saveUserData(UserDataModel userData) async {
    await _localStorageClient.saveUserSession(userData.toEntity());
  }

  @override
  Future<void> clearSelectedMode() async {
    await _localStorageClient.saveSelectedMode(null);
  }

  @override
  String? getSelectedMode() => _localStorageClient.getSelectedMode();

  @override
  String? getSelectedCompanyId() => _localStorageClient.getSelectedCompanyId();

  @override
  Future<void> saveSelectedCompanyId(String? companyId) async {
    await _localStorageClient.saveSelectedCompanyId(companyId);
  }
}
