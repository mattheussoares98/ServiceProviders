import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserDataModel extends UserDataEntity
    implements DataConvertible<UserDataEntity> {
  const UserDataModel({
    required UserProfileModel user,
    required super.accessToken,
    required super.refreshToken,
  }) : super(user: user);

  factory UserDataModel.fromJson(MapDynamic json) {
    return UserDataModel(
      user: UserProfileModel.fromJson(json['user'] as MapDynamic? ?? {}),
      accessToken: json['access'] as String? ?? '',
      refreshToken: json['refresh'] as String? ?? '',
    );
  }

  factory UserDataModel.fromSupabase(sb.AuthResponse response) {
    return UserDataModel(
      user: UserProfileModel.fromSupabase(response),
      accessToken: response.session?.accessToken ?? '',
      refreshToken: response.session?.refreshToken ?? '',
    );
  }

  factory UserDataModel.fromSupabaseProfile({
    required sb.AuthResponse response,
    required UserProfileModel profile,
  }) {
    return UserDataModel(
      user: profile,
      accessToken: response.session?.accessToken ?? '',
      refreshToken: response.session?.refreshToken ?? '',
    );
  }

  factory UserDataModel.fromEntity(UserDataEntity domain) {
    return UserDataModel(
      user: UserProfileModel.fromEntity(domain.user),
      accessToken: domain.accessToken,
      refreshToken: domain.refreshToken,
    );
  }

  @override
  UserProfileModel get user => super.user as UserProfileModel;

  @override
  MapDynamic toJson() => {
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
