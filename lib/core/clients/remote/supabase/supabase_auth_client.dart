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
    MapDynamic? data,
  });

  Session? get currentSession;
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
    redirectTo:
        'http://localhost:9090', //TODO pass this parameter and create the reset password page
    captchaToken: captchaToken,
  );

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    MapDynamic? data,
  }) => _auth.signUp(email: email, password: password, data: data);

  @override
  Session? get currentSession => _auth.currentSession;
}
