import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';

abstract interface class SessionRepository {
  bool get isLoggedIn;
  UserDataEntity get userData;
  Future<void> checkForUserCredential();
  set setUserData(UserDataEntity model);
  Future<void> logout({required String? email, required String? name});
}
