import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/data/handlers/repository_handler.dart';
import 'package:clean_architecture/core/domain/entities/user_data.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:clean_architecture/features/auth/data/models/requests/authentication_model.dart';
import 'package:clean_architecture/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required InternetClient internet,
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _internet = internet;

  final InternetClient _internet;
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  FutureData<UserDataEntity> login(AuthenticationEntity authentication) {
    return RepositoryHandler.fetchWithFallbackAndMap(
      isInternetConnected: _internet.isConnected,
      remoteCallback: () => _remoteDataSource.login(
        AuthenticationModel.fromEntity(authentication),
      ),
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
  FutureBool removeUserData() => _localDataSource.removeUserData();
}
