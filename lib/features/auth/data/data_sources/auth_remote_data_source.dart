import 'package:clean_architecture/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:clean_architecture/core/data/handlers/supabase_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/data/models/requests/authentication_model.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:injectable/injectable.dart';

abstract interface class AuthRemoteDataSource {
  FutureData<UserDataResponseModel> login(AuthenticationModel request);
  FutureVoid resetPassword(String email);
  bool checkAuth();
}

@LazySingleton(as: AuthRemoteDataSource)
final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required SupabaseAuthClient supabaseAuth})
    : _supabaseAuth = supabaseAuth;
  final SupabaseAuthClient _supabaseAuth;

  @override
  FutureData<UserDataResponseModel> login(AuthenticationModel request) {
    return SupabaseHandler.authCall(() async {
      final response = await _supabaseAuth.signInWithPassword(
        email: request.username, // Supabase uses email/password
        password: request.password,
      );

      return UserDataResponseModel.fromSupabase(response);
    });
  }

  @override
  FutureVoid resetPassword(String email) {
    return SupabaseHandler.voidAuthCall(
      () => _supabaseAuth.resetPasswordForEmail(email),
    );
  }

  @override
  bool checkAuth() => _supabaseAuth.currentSession != null;
}
