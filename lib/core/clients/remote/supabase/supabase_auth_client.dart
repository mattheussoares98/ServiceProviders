import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Interface for Supabase Auth client to allow mocking in tests.
abstract interface class SupabaseAuthClient {
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
    String? captchaToken,
  });

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String? emailRedirectTo,
    MapDynamic? data,
  });

  Future<void> logout();

  Session? get currentSession;

  Stream<AuthState> get onAuthStateChange;

  Future<void> updateUserPassword(String newPassword);
}

@LazySingleton(as: SupabaseAuthClient)
final class SupabaseAuthClientImpl implements SupabaseAuthClient {
  const SupabaseAuthClientImpl(this._auth);

  final GoTrueClient _auth;

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) => _auth.signInWithPassword(email: email, password: password);

  @override
  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
    String? captchaToken,
  }) => _auth.resetPasswordForEmail(
    email,
    redirectTo: redirectTo,
    captchaToken: captchaToken,
  );

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String? emailRedirectTo,
    MapDynamic? data,
  }) => _auth.signUp(
    email: email,
    password: password,
    emailRedirectTo: emailRedirectTo,
    data: data,
  );

  @override
  Session? get currentSession => _auth.currentSession;

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  @override
  Future<void> updateUserPassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }
}
