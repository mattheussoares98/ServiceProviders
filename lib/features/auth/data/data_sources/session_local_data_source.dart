import 'dart:convert';

import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:clean_architecture/core/constants/local_db_keys.dart';
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
    final stored = _localStorageClient.getEncryptedString(
      LocalDbKey.userData.key,
    );
    if (stored != null && stored.isNotEmpty) {
      try {
        final map = jsonDecode(stored) as Map<String, dynamic>;
        return UserDataResponseModel.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> saveUserData(UserDataResponseModel userData) async {
    await _localStorageClient.setStringWithEncryption(
      LocalDbKey.userData.key,
      jsonEncode(userData.toJson()),
    );
  }
}
