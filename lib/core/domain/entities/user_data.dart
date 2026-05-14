import 'package:clean_architecture/core/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

class UserDataEntity extends Equatable {
  const UserDataEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  const UserDataEntity.empty()
    : user = const User.empty(),
      accessToken = '',
      refreshToken = '';
  final User user;
  final String accessToken;
  final String refreshToken;

  UserDataEntity copyWith({
    User? user,
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
