import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:injectable/injectable.dart';

abstract interface class SessionLocalDataSource {
  Future<UserDataResponseModel?> getUserData();

  Future<void> saveUserData(UserDataResponseModel userData);
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
}
