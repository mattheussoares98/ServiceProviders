import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';

class CustomerEntity extends Equatable {
  const CustomerEntity({
    required this.id,
    required this.companyId,
    required this.name,
    this.document,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
    this.postalCode,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final String? document;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DocumentType? get documentType {
    if (document == null) return null;
    final digits = document!.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 14) return DocumentType.cnpj;
    if (digits.length == 11) return DocumentType.cpf;
    return null;
  }

  CustomerEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    String? document,
    bool? annulDocument,
    String? contactName,
    bool? annulContactName,
    String? contactEmail,
    bool? annulContactEmail,
    String? contactPhone,
    bool? annulContactPhone,
    String? address,
    bool? annulAddress,
    String? number,
    bool? annulNumber,
    String? complement,
    bool? annulComplement,
    String? neighborhood,
    bool? annulNeighborhood,
    String? city,
    bool? annulCity,
    String? state,
    bool? annulState,
    String? postalCode,
    bool? annulPostalCode,
    String? notes,
    bool? annulNotes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulDeletedAt,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      document: annulDocument == true ? null : (document ?? this.document),
      contactName: annulContactName == true
          ? null
          : (contactName ?? this.contactName),
      contactEmail: annulContactEmail == true
          ? null
          : (contactEmail ?? this.contactEmail),
      contactPhone: annulContactPhone == true
          ? null
          : (contactPhone ?? this.contactPhone),
      address: annulAddress == true ? null : (address ?? this.address),
      number: annulNumber == true ? null : (number ?? this.number),
      complement: annulComplement == true
          ? null
          : (complement ?? this.complement),
      neighborhood: annulNeighborhood == true
          ? null
          : (neighborhood ?? this.neighborhood),
      city: annulCity == true ? null : (city ?? this.city),
      state: annulState == true ? null : (state ?? this.state),
      postalCode: annulPostalCode == true
          ? null
          : (postalCode ?? this.postalCode),
      notes: annulNotes == true ? null : (notes ?? this.notes),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : (deletedAt ?? this.deletedAt),
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    name,
    document,
    contactName,
    contactEmail,
    contactPhone,
    address,
    number,
    complement,
    neighborhood,
    city,
    state,
    postalCode,
    notes,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
