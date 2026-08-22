import 'package:equatable/equatable.dart';

class DeviceTokenEntity extends Equatable {
  const DeviceTokenEntity({
    required this.id,
    required this.userId,
    required this.deviceToken,
    required this.platform,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String deviceToken;
  final String platform;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceTokenEntity copyWith({
    String? id,
    String? userId,
    String? deviceToken,
    String? platform,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceTokenEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceToken: deviceToken ?? this.deviceToken,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    deviceToken,
    platform,
    createdAt,
    updatedAt,
  ];
}
