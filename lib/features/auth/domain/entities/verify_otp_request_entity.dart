import 'package:equatable/equatable.dart';

class VerifyOtpRequestEntity extends Equatable {
  const VerifyOtpRequestEntity({
    required this.tokenHash,
    this.type = 'invite',
  });

  final String tokenHash;
  final String type;

  VerifyOtpRequestEntity copyWith({
    String? tokenHash,
    String? type,
  }) {
    return VerifyOtpRequestEntity(
      tokenHash: tokenHash ?? this.tokenHash,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [tokenHash, type];
}
