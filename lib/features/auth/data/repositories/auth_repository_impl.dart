import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/data/handlers/repository_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:clean_architecture/features/auth/data/models/requests/authentication_request_model.dart';
import 'package:clean_architecture/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_local_data_source.dart';
import 'package:injectable/injectable.dart';

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
        if (profile.id.isEmpty || profile.companyId.isEmpty) {
          return Future.value(
            FailureState<Object?>(
              message: 'Perfil de usuário não encontrado.'.hardcoded,
            ),
          );
        }
        return _usersLocalDataSource.saveUserProfile(profile);
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
}
