import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';

class ServiceProviderCompanyResponseModel extends ServiceProviderCompanyEntity
    implements DataConvertible<ServiceProviderCompanyEntity> {
  const ServiceProviderCompanyResponseModel({
    required super.id,
    required super.companyId,
    required super.name,
    required super.document,
    required super.documentType,
    super.contactEmail,
    super.contactPhone,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory ServiceProviderCompanyResponseModel.fromEntity(
    ServiceProviderCompanyEntity entity,
  ) => ServiceProviderCompanyResponseModel(
    id: entity.id,
    companyId: entity.companyId,
    name: entity.name,
    document: entity.document,
    documentType: entity.documentType,
    contactEmail: entity.contactEmail,
    contactPhone: entity.contactPhone,
    isActive: entity.isActive,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory ServiceProviderCompanyResponseModel.fromJson(MapDynamic json) =>
      ServiceProviderCompanyResponseModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        document: json['document'] as String,
        documentType: DocumentType.fromName(json['document_type'] as String),
        contactEmail: json['contact_email'] as String?,
        contactPhone: json['contact_phone'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'] as String)
            : null,
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
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
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
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
