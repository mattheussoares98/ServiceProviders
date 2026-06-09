import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserDataResponseModel extends UserDataEntity
    implements DataConvertible<UserDataEntity> {
  const UserDataResponseModel({
    required UserProfileResponseModel user,
    required super.accessToken,
    required super.refreshToken,
  }) : super(user: user);

  factory UserDataResponseModel.fromJson(MapDynamic json) {
    return UserDataResponseModel(
      user: UserProfileResponseModel.fromJson(
        json['user'] as MapDynamic? ?? {},
      ),
      accessToken: json['access'] as String? ?? '',
      refreshToken: json['refresh'] as String? ?? '',
    );
  }

  factory UserDataResponseModel.fromSupabase(sb.AuthResponse response) {
    final now = DateTime.now();
    return UserDataResponseModel(
      user: UserProfileResponseModel(
        id: response.user!.id,
        companyId: '',
        name: response.user!.userMetadata?['name'] as String? ?? '',
        email: response.user!.email ?? '',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      accessToken: response.session?.accessToken ?? '',
      refreshToken: response.session?.refreshToken ?? '',
    );
  }

  factory UserDataResponseModel.fromSupabaseProfile({
    required sb.AuthResponse response,
    required UserProfileResponseModel profile,
  }) {
    return UserDataResponseModel(
      user: profile,
      accessToken: response.session?.accessToken ?? '',
      refreshToken: response.session?.refreshToken ?? '',
    );
  }

  factory UserDataResponseModel.fromEntity(UserDataEntity domain) {
    return UserDataResponseModel(
      user: UserProfileResponseModel.fromEntity(domain.user),
      accessToken: domain.accessToken,
      refreshToken: domain.refreshToken,
    );
  }

  @override
  UserProfileResponseModel get user => super.user as UserProfileResponseModel;

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
