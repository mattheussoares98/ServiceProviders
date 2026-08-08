import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:o_jogo_da_obra/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/requests/authentication_request_model.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/auth_user_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/authentication_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/sign_up_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/auth_repository.dart';
import 'package:o_jogo_da_obra/features/users/data/data_sources/users_local_data_source.dart';

@LazySingleton(as: AuthRepository)
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required InternetClient internet,
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required UsersLocalDataSource usersLocalDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _usersLocalDataSource = usersLocalDataSource,
       _internet = internet;

  final InternetClient _internet;
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final UsersLocalDataSource _usersLocalDataSource;

  @override
  FutureData<UserDataEntity> login(AuthenticationEntity authentication) {
    return RepositoryHandler.fetchWithFallbackAndMap(
      isInternetConnected: _internet.isConnected,
      remoteCallback: () => _remoteDataSource.login(
        AuthenticationRequestModel.fromEntity(authentication),
      ),
      onRemoteSuccess: (data) {
        final profile = data.user;
        if (profile.id.isEmpty) {
          return Future.value(
            FailureState<Object?>(
              message: 'Perfil de usuário não encontrado.'.hardcoded,
            ),
          );
        }
        if (profile.companyId.isNotEmpty) {
          return _usersLocalDataSource.saveUserProfile(profile);
        }
        return Future.value(const SuccessState(data: true));
      },
    );
  }

  @override
  FutureData<UserDataEntity> signUp(SignUpEntity request) {
    return RepositoryHandler.fetchWithFallbackAndMap(
      isInternetConnected: _internet.isConnected,
      remoteCallback: () =>
          _remoteDataSource.signUp(SignUpRequestModel.fromEntity(request)),
    );
  }

  @override
  FutureVoid resetPassword(String email) =>
      _remoteDataSource.resetPassword(email);

  @override
  FutureVoid changePassword(String newPassword) =>
      _remoteDataSource.changePassword(newPassword);

  @override
  FutureBool saveUserData(UserDataEntity userData) =>
      _localDataSource.saveUserData(UserDataResponseModel.fromEntity(userData));

  @override
  FutureData<UserDataEntity> getUserData() {
    return RepositoryHandler.fetchFromLocalAndMap(
      localCallback: _localDataSource.getUserData,
    );
  }

  @override
  bool checkAuth() => _remoteDataSource.checkAuth();

  @override
  AuthUserEntity? get currentAuthUser => _remoteDataSource.currentAuthUser;

  @override
  Stream<String?> get authUserIdStream => _remoteDataSource.authUserIdStream;

  @override
  Future<void> logout() => _remoteDataSource.logout();
}
