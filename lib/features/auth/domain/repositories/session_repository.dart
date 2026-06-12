import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';

abstract interface class SessionRepository {
  bool get isLoggedIn;
  UserDataEntity get userData;
  Stream<UserDataEntity> get sessionStream;
  Future<void> checkForUserCredential();
  set setUserData(UserDataEntity model);
  Future<void> logout();
}
