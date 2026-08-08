import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';

class ServiceProviderCompanyEntity extends Equatable {
  const ServiceProviderCompanyEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.documentType,
    required this.document,
    required this.contactEmail,
    required this.contactPhone,
    required this.isActive,
    required this.invitationStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final DocumentType documentType;
  final String document;
  final String? contactEmail;
  final String? contactPhone;
  final bool isActive;
  final ServiceProviderInvitationStatus? invitationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    name,
    document,
    documentType,
    contactEmail,
    contactPhone,
    isActive,
    invitationStatus,
    createdAt,
    updatedAt,
    deletedAt,
  ];

  ServiceProviderCompanyEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    String? document,
    DocumentType? documentType,
    String? contactEmail,
    String? contactPhone,
    bool? isActive,
    ServiceProviderInvitationStatus? invitationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulContactEmail,
    bool? annulContactPhone,
    bool? annulInvitationStatus,
    bool? annulDeletedAt,
  }) {
    return ServiceProviderCompanyEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      document: document ?? this.document,
      documentType: documentType ?? this.documentType,
      contactEmail: annulContactEmail == true
          ? null
          : contactEmail ?? this.contactEmail,
      contactPhone: annulContactPhone == true
          ? null
          : contactPhone ?? this.contactPhone,
      isActive: isActive ?? this.isActive,
      invitationStatus: annulInvitationStatus == true
          ? null
          : invitationStatus ?? this.invitationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
