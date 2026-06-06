import 'package:clean_architecture/config/app_config.dart';
import 'package:clean_architecture/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:clean_architecture/core/data/handlers/supabase_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/data/models/requests/authentication_request_model.dart';
import 'package:clean_architecture/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:clean_architecture/routing/helper/route_data.dart';
import 'package:injectable/injectable.dart';

abstract interface class AuthRemoteDataSource {
  FutureData<UserDataResponseModel> login(AuthenticationRequestModel request);
  FutureData<UserDataResponseModel> signUp(SignUpRequestModel request);
  FutureVoid resetPassword(String email);
  FutureVoid changePassword(String newPassword);
  bool checkAuth();
}

@LazySingleton(as: AuthRemoteDataSource)
final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required SupabaseAuthClient supabaseAuth})
    : _supabaseAuth = supabaseAuth;
  final SupabaseAuthClient _supabaseAuth;

  @override
  FutureData<UserDataResponseModel> login(AuthenticationRequestModel request) {
    return SupabaseHandler.authCall(() async {
      final response = await _supabaseAuth.signInWithPassword(
        email: request.email, // Supabase uses email/password
        password: request.password,
      );

      return UserDataResponseModel.fromSupabase(response);
    });
  }

  @override
  FutureVoid resetPassword(String email) {
    final redirectUrl = '${AppConfigUtil.I.webBaseUrl}$kChangePasswordPath';
    return SupabaseHandler.voidAuthCall(
      () => _supabaseAuth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      ),
    );
  }

  @override
  FutureVoid changePassword(String newPassword) {
    return SupabaseHandler.voidAuthCall(
      () => _supabaseAuth.updateUserPassword(newPassword),
    );
  }

  @override
  FutureData<UserDataResponseModel> signUp(SignUpRequestModel request) {
    // Build the full redirect URL: base URL + email-confirmation path
    final redirectUrl = '${AppConfigUtil.I.webBaseUrl}$kEmailConfirmationPath';
    return SupabaseHandler.authCall(() async {
      final response = await _supabaseAuth.signUp(
        email: request.email,
        password: request.password,
        emailRedirectTo: redirectUrl,
        data: {'name': request.name},
      );

      return UserDataResponseModel.fromSupabase(response);
    });
  }

  @override
  bool checkAuth() => _supabaseAuth.currentSession != null;
}
