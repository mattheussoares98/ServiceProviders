import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';

class ServiceProviderCompanyEntity extends Equatable {
  const ServiceProviderCompanyEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.documentType,
    required this.document,
    this.contactEmail,
    this.contactPhone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final DocumentType documentType;
  final String document;
  final String? contactEmail;
  final String? contactPhone;
  final bool isActive;
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
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulContactEmail,
    bool? annulContactPhone,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
