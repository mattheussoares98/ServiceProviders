import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/auth_user_entity.dart';

abstract interface class SessionRepository {
  bool get isLoggedIn;
  UserDataEntity get userData;
  Stream<UserDataEntity> get sessionStream;
  AuthUserEntity? get currentAuthUser;
  Stream<String?> get authUserIdStream;
  Future<void> checkForUserCredential();
  set setUserData(UserDataEntity model);
  Future<void> logout();
  String? getSelectedMode();
  String? getSelectedCompanyId();
}
