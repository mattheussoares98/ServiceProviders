import 'package:clean_architecture/core/domain/entities/user_data.dart';

abstract interface class SessionRepository {
  bool get isLoggedIn;
  UserDataEntity get userData;
  Future<void> checkForUserCredential();
  set setUserData(UserDataEntity model);
  void clearSessionData();
}
