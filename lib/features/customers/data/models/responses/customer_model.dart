import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity
    implements DataConvertible<CustomerEntity> {
  const CustomerModel({
    required super.id,
    required super.companyId,
    required super.name,
    super.document,
    super.contactName,
    super.contactEmail,
    super.contactPhone,
    super.address,
    super.number,
    super.complement,
    super.neighborhood,
    super.city,
    super.state,
    super.postalCode,
    super.notes,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory CustomerModel.fromEntity(CustomerEntity entity) => CustomerModel(
    id: entity.id,
    companyId: entity.companyId,
    name: entity.name,
    document: entity.document,
    contactName: entity.contactName,
    contactEmail: entity.contactEmail,
    contactPhone: entity.contactPhone,
    address: entity.address,
    number: entity.number,
    complement: entity.complement,
    neighborhood: entity.neighborhood,
    city: entity.city,
    state: entity.state,
    postalCode: entity.postalCode,
    notes: entity.notes,
    isActive: entity.isActive,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory CustomerModel.fromJson(MapDynamic json) => CustomerModel(
    id: json['id'] as String? ?? '',
    companyId: json['company_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    document: json['document'] as String?,
    contactName: json['contact_name'] as String?,
    contactEmail: json['contact_email'] as String?,
    contactPhone: json['contact_phone'] as String?,
    address: json['address'] as String?,
    number: json['number'] as String?,
    complement: json['complement'] as String?,
    neighborhood: json['neighborhood'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    postalCode: json['postal_code'] as String?,
    notes: json['notes'] as String?,
    isActive: json['is_active'] as bool? ?? true,
    createdAt:
        (json['created_at'] as String?).toUtcDateTime() ??
        DateTime.now().toUtc(),
    updatedAt:
        (json['updated_at'] as String?).toUtcDateTime() ??
        DateTime.now().toUtc(),
    deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
  );

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'name': name,
    'document': document,
    'contact_name': contactName,
    'contact_email': contactEmail,
    'contact_phone': contactPhone,
    'address': address,
    'number': number,
    'complement': complement,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    'postal_code': postalCode,
    'notes': notes,
    'is_active': isActive,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
  };

  @override
  CustomerEntity toEntity() => CustomerEntity(
    id: id,
    companyId: companyId,
    name: name,
    document: document,
    contactName: contactName,
    contactEmail: contactEmail,
    contactPhone: contactPhone,
    address: address,
    number: number,
    complement: complement,
    neighborhood: neighborhood,
    city: city,
    state: state,
    postalCode: postalCode,
    notes: notes,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
