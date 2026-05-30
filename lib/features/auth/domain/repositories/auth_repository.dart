import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';

abstract interface class AuthRepository {
  FutureData<UserDataEntity> login(AuthenticationEntity authentication);
  FutureData<UserDataEntity> signUp(SignUpEntity request);
  FutureVoid resetPassword(String email);
  FutureVoid changePassword(String newPassword);
  FutureBool saveUserData(UserDataEntity userData);
  FutureData<UserDataEntity> getUserData();
  bool checkAuth();
  FutureBool removeUserData();
}
