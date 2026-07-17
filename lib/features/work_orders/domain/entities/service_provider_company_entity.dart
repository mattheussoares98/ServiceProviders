import 'package:equatable/equatable.dart';

class ServiceProviderCompanyEntity extends Equatable {
  const ServiceProviderCompanyEntity({
    required this.id,
    required this.companyId,
    required this.name,
    this.document,
    this.documentType,
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
  final String? document;
  final String? documentType;
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
    String? documentType,
    String? contactEmail,
    String? contactPhone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulDocument,
    bool? annulDocumentType,
    bool? annulContactEmail,
    bool? annulContactPhone,
    bool? annulDeletedAt,
  }) {
    return ServiceProviderCompanyEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      document: annulDocument == true ? null : document ?? this.document,
      documentType:
          annulDocumentType == true ? null : documentType ?? this.documentType,
      contactEmail:
          annulContactEmail == true ? null : contactEmail ?? this.contactEmail,
      contactPhone:
          annulContactPhone == true ? null : contactPhone ?? this.contactPhone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
