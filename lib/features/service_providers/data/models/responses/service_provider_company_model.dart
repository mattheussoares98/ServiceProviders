import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';

class ServiceProviderCompanyModel extends ServiceProviderCompanyEntity
    implements DataConvertible<ServiceProviderCompanyEntity> {
  const ServiceProviderCompanyModel({
    required super.id,
    required super.companyId,
    required super.name,
    required super.document,
    required super.documentType,
    required super.contactEmail,
    required super.contactPhone,
    required super.isActive,
    required super.invitationStatus,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
  });

  factory ServiceProviderCompanyModel.fromEntity(
    ServiceProviderCompanyEntity entity,
  ) => ServiceProviderCompanyModel(
    id: entity.id,
    companyId: entity.companyId,
    name: entity.name,
    document: entity.document,
    documentType: entity.documentType,
    contactEmail: entity.contactEmail,
    contactPhone: entity.contactPhone,
    isActive: entity.isActive,
    invitationStatus: entity.invitationStatus,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory ServiceProviderCompanyModel.fromJson(MapDynamic json) =>
      ServiceProviderCompanyModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        document: json['document'] as String,
        documentType: DocumentType.fromName(json['document_type'] as String),
        contactEmail: json['contact_email'] as String?,
        contactPhone: json['contact_phone'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        invitationStatus: json['invitation_status'] != null
            ? ServiceProviderInvitationStatus.fromString(
                json['invitation_status'] as String,
              )
            : null,
        createdAt: (json['created_at'] as String?).toUtcDateTime() ??
            DateTime.now().toUtc(),
        updatedAt: (json['updated_at'] as String?).toUtcDateTime() ??
            DateTime.now().toUtc(),
        deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
      );

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'name': name,
    'document': document,
    'document_type': documentType.name,
    'contact_email': contactEmail,
    'contact_phone': contactPhone,
    'is_active': isActive,
    'invitation_status': invitationStatus?.value,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
  };

  @override
  ServiceProviderCompanyEntity toEntity() => ServiceProviderCompanyEntity(
    id: id,
    companyId: companyId,
    name: name,
    document: document,
    documentType: documentType,
    contactEmail: contactEmail,
    contactPhone: contactPhone,
    isActive: isActive,
    invitationStatus: invitationStatus,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
