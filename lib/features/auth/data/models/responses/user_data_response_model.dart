import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/data/models/responses/user_model.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserDataResponseModel extends UserDataEntity
    implements DataConvertible<UserDataEntity> {
  const UserDataResponseModel({
    required UserModel user,
    required super.accessToken,
    required super.refreshToken,
  }) : super(user: user);

  factory UserDataResponseModel.fromJson(Map<String, dynamic> json) {
    return UserDataResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      accessToken: json['access'] as String? ?? '',
      refreshToken: json['refresh'] as String? ?? '',
    );
  }

  factory UserDataResponseModel.fromSupabase(sb.AuthResponse response) {
    return UserDataResponseModel(
      user: UserModel.fromSupabase(response.user!),
      accessToken: response.session?.accessToken ?? '',
      refreshToken: response.session?.refreshToken ?? '',
    );
  }

  factory UserDataResponseModel.fromEntity(UserDataEntity domain) {
    return UserDataResponseModel(
      user: UserModel.fromEntity(domain.user),
      accessToken: domain.accessToken,
      refreshToken: domain.refreshToken,
    );
  }

  @override
  UserModel get user => super.user as UserModel;

  @override
  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'access': accessToken,
    'refresh': refreshToken,
  };

  @override
  UserDataEntity toEntity() {
    return UserDataEntity(
      user: user.toEntity(),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
