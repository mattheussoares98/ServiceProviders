import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_action.dart';

class AccessLogEntity extends Equatable {
  const AccessLogEntity({
    required this.id,
    required this.companyId,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.action,
    this.ipAddress,
    this.deviceInfo,
    required this.createdAt,
  });

  final String id;
  final String companyId;
  final String userId;
  final String? userName;
  final String? userEmail;
  final AccessLogAction action;
  final String? ipAddress;
  final String? deviceInfo;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    userId,
    userName,
    userEmail,
    action,
    ipAddress,
    deviceInfo,
    createdAt,
  ];

  AccessLogEntity copyWith({
    String? id,
    String? companyId,
    String? userId,
    String? userName,
    String? userEmail,
    AccessLogAction? action,
    String? ipAddress,
    String? deviceInfo,
    DateTime? createdAt,
    bool? annulUserName,
    bool? annulUserEmail,
    bool? annulIpAddress,
    bool? annulDeviceInfo,
  }) {
    return AccessLogEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      userName: annulUserName == true ? null : userName ?? this.userName,
      userEmail: annulUserEmail == true ? null : userEmail ?? this.userEmail,
      action: action ?? this.action,
      ipAddress: annulIpAddress == true ? null : ipAddress ?? this.ipAddress,
      deviceInfo: annulDeviceInfo == true ? null : deviceInfo ?? this.deviceInfo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
