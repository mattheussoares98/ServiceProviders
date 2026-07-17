import 'package:equatable/equatable.dart';

class ServiceProviderProfileEntity extends Equatable {
  const ServiceProviderProfileEntity({
    required this.id,
    this.authUserId,
    required this.serviceProviderCompanyId,
    required this.name,
    required this.email,
    this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? authUserId;
  final String serviceProviderCompanyId;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    authUserId,
    serviceProviderCompanyId,
    name,
    email,
    phone,
    isActive,
    createdAt,
    updatedAt,
  ];

  ServiceProviderProfileEntity copyWith({
    String? id,
    String? authUserId,
    String? serviceProviderCompanyId,
    String? name,
    String? email,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? annulAuthUserId,
    bool? annulPhone,
  }) {
    return ServiceProviderProfileEntity(
      id: id ?? this.id,
      authUserId:
          annulAuthUserId == true ? null : authUserId ?? this.authUserId,
      serviceProviderCompanyId:
          serviceProviderCompanyId ?? this.serviceProviderCompanyId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: annulPhone == true ? null : phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
