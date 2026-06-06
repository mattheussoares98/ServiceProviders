import 'package:equatable/equatable.dart';

class VerifyTokenEntity extends Equatable {
  const VerifyTokenEntity({required this.token, required this.userId});
  final String token;
  final String userId;

  @override
  List<Object?> get props => [token, userId];
}
