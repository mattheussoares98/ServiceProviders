import 'package:clean_architecture/config/app_config.dart';
import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:clean_architecture/core/data/handlers/supabase_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/data/models/requests/authentication_request_model.dart';
import 'package:clean_architecture/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:clean_architecture/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:clean_architecture/routing/helper/route_data.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  FutureData<UserDataResponseModel> login(AuthenticationRequestModel request);
  FutureData<UserDataResponseModel> signUp(SignUpRequestModel request);
  FutureData<UserProfileResponseModel> getCurrentUserProfile(String userId);
  FutureVoid resetPassword(String email);
  FutureVoid changePassword(String newPassword);
  bool checkAuth();
}

@LazySingleton(as: AuthRemoteDataSource)
final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required SupabaseAuthClient supabaseAuth,
    required SupabaseDatabaseClient supabaseDatabase,
  }) : _supabaseAuth = supabaseAuth,
       _supabaseDatabase = supabaseDatabase;

  final SupabaseAuthClient _supabaseAuth;
  final SupabaseDatabaseClient _supabaseDatabase;

  @override
  FutureData<UserDataResponseModel> login(AuthenticationRequestModel request) {
    return SupabaseHandler.authCall(() async {
      final response = await _supabaseAuth.signInWithPassword(
        email: request.email, // Supabase uses email/password
        password: request.password,
      );

      final profile = await _getUserProfile(response.user?.id);
      return UserDataResponseModel.fromSupabaseProfile(
        response: response,
        profile: profile,
      );
    });
  }

  @override
  FutureData<UserProfileResponseModel> getCurrentUserProfile(String userId) {
    return SupabaseHandler.authCall(() => _getUserProfile(userId));
  }

  @override
  FutureVoid resetPassword(String email) {
    final redirectUrl = '${AppConfigUtil.I.webBaseUrl}$kChangePasswordPath';
    return SupabaseHandler.voidAuthCall(
      () => _supabaseAuth.resetPasswordForEmail(email, redirectTo: redirectUrl),
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

  Future<UserProfileResponseModel> _getUserProfile(String? userId) async {
    if (userId == null || userId.isEmpty) {
      throw const AuthException('Usuário autenticado inválido.');
    }

    final profileJson = await _supabaseDatabase.selectOne(
      table: 'user_profiles',
      filters: [SupabaseFilter.eq('id', userId)],
    );
    if (profileJson == null) {
      throw const AuthException('Perfil de usuário não encontrado.');
    }

    return UserProfileResponseModel.fromJson(profileJson);
  }
}
