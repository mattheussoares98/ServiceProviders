import 'dart:convert';

import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:clean_architecture/core/constants/local_db_keys.dart';
import 'package:clean_architecture/core/data/handlers/error_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:injectable/injectable.dart';

abstract interface class AuthLocalDataSource {
  FutureBool saveUserData(UserDataResponseModel userDataModel);
  FutureData<UserDataResponseModel> getUserData();
  FutureBool removeUserData();
}

@LazySingleton(as: AuthLocalDataSource)
final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({required LocalStorageClient localDatabase})
    : _localDatabase = localDatabase;
  final LocalStorageClient _localDatabase;

  @override
  FutureBool saveUserData(UserDataResponseModel userDataModel) {
    return ErrorHandler.execute(() async {
      await _localDatabase.setString(
        LocalDbKey.userData.key,
        jsonEncode(userDataModel.toJson()),
      );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureData<UserDataResponseModel> getUserData() {
    return ErrorHandler.execute(() async {
      final String userData =
          _localDatabase.getString(LocalDbKey.userData.key) ?? '';

      if (userData.isNotEmpty) {
        final userDataModel = UserDataResponseModel.fromJson(
          jsonDecode(userData) as MapDynamic,
        );
        return SuccessState(data: userDataModel);
      }
      return FailureState<UserDataResponseModel>(
        message: 'Usuário não encontrado'.hardcoded,
      );
    });
  }

  @override
  FutureBool removeUserData() {
    return ErrorHandler.execute(() async {
      await _localDatabase.remove(LocalDbKey.userData.key);
      return const SuccessState(data: true);
    });
  }
}
