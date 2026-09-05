import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_action.dart';

class CreateAccessLogRequestEntity extends Equatable {
  const CreateAccessLogRequestEntity({
    required this.companyId,
    required this.userId,
    required this.action,
    this.ipAddress,
    this.deviceInfo,
  });

  final String companyId;
  final String userId;
  final AccessLogAction action;
  final String? ipAddress;
  final String? deviceInfo;

  @override
  List<Object?> get props => [
    companyId,
    userId,
    action,
    ipAddress,
    deviceInfo,
  ];

  CreateAccessLogRequestEntity copyWith({
    String? companyId,
    String? userId,
    AccessLogAction? action,
    String? ipAddress,
    String? deviceInfo,
    bool? annulIpAddress,
    bool? annulDeviceInfo,
  }) {
    return CreateAccessLogRequestEntity(
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      ipAddress: annulIpAddress == true ? null : ipAddress ?? this.ipAddress,
      deviceInfo: annulDeviceInfo == true ? null : deviceInfo ?? this.deviceInfo,
    );
  }
}
