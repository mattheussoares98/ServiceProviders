import 'package:clean_architecture/features/auth/domain/entities/verify_token.dart';

class VerifyTokenRequestModel {
  const VerifyTokenRequestModel({required this.token, required this.userId});

  factory VerifyTokenRequestModel.fromEntity(VerifyToken verifyToken) =>
      VerifyTokenRequestModel(
        token: verifyToken.token,
        userId: verifyToken.userId,
      );
  final String token;
  final String userId;

  Map<String, dynamic> toJson() => {'token': token, 'user_id': userId};
}
