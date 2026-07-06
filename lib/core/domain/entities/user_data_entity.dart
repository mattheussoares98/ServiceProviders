import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';

class UserDataEntity extends Equatable {
  const UserDataEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  UserDataEntity.empty()
    : user = UserProfileEntity.empty(),
      accessToken = '',
      refreshToken = '';
  final UserProfileEntity user;
  final String accessToken;
  final String refreshToken;

  UserDataEntity copyWith({
    UserProfileEntity? user,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserDataEntity(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}
