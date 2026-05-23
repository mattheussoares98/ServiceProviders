import 'package:clean_architecture/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/data/data_sources/session_local_data_source.dart';
import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:injectable/injectable.dart';

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

  UserDataEntity _userData = const UserDataEntity.empty();

  @override
  bool get isLoggedIn => _auth.currentSession?.accessToken.isNotEmpty ?? false;

  @override
  UserDataEntity get userData => _userData;

  @override
  set setUserData(UserDataEntity model) => _userData = model;

  /// Check user's logged in credentials and store it before starting the app
  @override
  Future<void> checkForUserCredential() async {
    final response = await _localDataSource.getUserData();
    if (response != null) {
      _userData = response.toEntity();
    }
  }

  @override
  void logout() {
    _userData = const UserDataEntity.empty();
    _localDataSource.clearUserData();
    // _auth.signOut();//TODO add this method
  }
}
