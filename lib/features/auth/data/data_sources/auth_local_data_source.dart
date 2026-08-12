import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/responses/user_data_model.dart';

abstract interface class AuthLocalDataSource {
  FutureBool saveUserData(UserDataModel userDataModel);
  FutureData<UserDataModel> getUserData();
}

@LazySingleton(as: AuthLocalDataSource)
final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({required LocalStorageClient localDatabase})
    : _localDatabase = localDatabase;
  final LocalStorageClient _localDatabase;

  @override
  FutureBool saveUserData(UserDataModel userDataModel) {
    return ErrorHandler.execute(() async {
      await _localDatabase.saveUserSession(userDataModel.toEntity());
      return const SuccessState(data: true);
    });
  }

  @override
  FutureData<UserDataModel> getUserData() {
    return ErrorHandler.execute(() async {
      final session = _localDatabase.getUserSession();
      if (session != null) {
        final userDataModel = UserDataModel.fromEntity(session);
        return SuccessState(data: userDataModel);
      }
      return FailureState<UserDataModel>(
        message: 'Usuário não encontrado'.hardcoded,
      );
    });
  }
}
