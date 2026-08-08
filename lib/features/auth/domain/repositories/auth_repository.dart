import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/auth_user_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/authentication_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/sign_up_entity.dart';

abstract interface class AuthRepository {
  FutureData<UserDataEntity> login(AuthenticationEntity authentication);
  FutureData<UserDataEntity> signUp(SignUpEntity request);
  FutureVoid resetPassword(String email);
  FutureVoid changePassword(String newPassword);
  FutureBool saveUserData(UserDataEntity userData);
  FutureData<UserDataEntity> getUserData();
  bool checkAuth();
  AuthUserEntity? get currentAuthUser;
  Stream<String?> get authUserIdStream;
  Future<void> logout();
}
