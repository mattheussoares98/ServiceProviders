import 'package:clean_architecture/core/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class UserDataEntity extends Equatable {
  const UserDataEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  const UserDataEntity.empty()
    : user = const UserEntity.empty(),
      accessToken = '',
      refreshToken = '';
  final UserEntity user;
  final String accessToken;
  final String refreshToken;

  UserDataEntity copyWith({
    UserEntity? user,
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
