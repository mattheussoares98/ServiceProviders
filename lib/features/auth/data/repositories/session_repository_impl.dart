import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/data/data_sources/session_local_data_source.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/auth_user_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

/// A class that stores user data
@LazySingleton(as: SessionRepository)
final class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl({
    required SessionLocalDataSource localDataSource,
    required SupabaseAuthClient auth,
  }) : _localDataSource = localDataSource,
       _auth = auth;

  final SessionLocalDataSource _localDataSource;
  final SupabaseAuthClient _auth;
  final StreamController<UserDataEntity> _sessionController =
      StreamController<UserDataEntity>.broadcast();

  UserDataEntity _userData = UserDataEntity.empty();

  @override
  bool get isLoggedIn =>
      (_auth.currentSession?.accessToken.isNotEmpty ?? false) &&
      _userData.user.id.isNotEmpty;

  @override
  UserDataEntity get userData => _userData;

  @override
  AuthUserEntity? get currentAuthUser {
    final user = _auth.currentSession?.user;
    if (user == null) return null;
    return AuthUserEntity(
      id: user.id,
      email: user.email ?? '',
      name:
          (user.userMetadata?['name'] as String?) ??
          user.email?.split('@')[0] ??
          '',
      createdAt: user.createdAt.toDateTime() ?? DateTime.now(),
      updatedAt: user.updatedAt?.toDateTime() ?? DateTime.now(),
    );
  }

  @override
  Stream<String?> get authUserIdStream =>
      _auth.onAuthStateChange.map((data) => data.session?.user.id);

  @override
  Stream<UserDataEntity> get sessionStream => Stream.multi((controller) {
    controller.add(_userData);
    final subscription = _sessionController.stream.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );
    controller.onCancel = subscription.cancel;
  });

  @override
  set setUserData(UserDataEntity model) {
    _userData = model;
    _sessionController.add(model);
  }

  /// Check user's logged in credentials and store it before starting the app
  @override
  Future<void> checkForUserCredential() async {
    final response = await _localDataSource.getUserData();
    if (response != null) {
      _userData = response.toEntity();
      _sessionController.add(_userData);
    }
  }

  @override
  Future<void> logout() async {
    final cleanedUser = UserDataEntity.empty().copyWith(
      user: _userData.user.copyWith(email: _userData.user.email),
    );
    _userData = cleanedUser;
    _sessionController.add(cleanedUser);
    await _localDataSource.saveUserData(
      UserDataResponseModel.fromEntity(cleanedUser),
    );
    await _localDataSource.clearSelectedMode();
    await _auth.logout();
  }

  @override
  String? getSelectedMode() => _localDataSource.getSelectedMode();

  @override
  String? getSelectedCompanyId() => _localDataSource.getSelectedCompanyId();
}
