import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/responses/user_data_response_model.dart';

abstract interface class SessionLocalDataSource {
  Future<UserDataResponseModel?> getUserData();

  Future<void> saveUserData(UserDataResponseModel userData);

  Future<void> clearSelectedMode();

  String? getSelectedMode();

  String? getSelectedCompanyId();
}

@LazySingleton(as: SessionLocalDataSource)
final class SessionLocalDataSourceImpl implements SessionLocalDataSource {
  SessionLocalDataSourceImpl(this._localStorageClient);
  final LocalStorageClient _localStorageClient;

  @override
  Future<UserDataResponseModel?> getUserData() async {
    final session = _localStorageClient.getUserSession();
    if (session != null) {
      return UserDataResponseModel.fromEntity(session);
    }
    return null;
  }

  @override
  Future<void> saveUserData(UserDataResponseModel userData) async {
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
}

