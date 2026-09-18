import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity implements DataConvertible<AddressEntity> {
  const AddressModel({
    required super.postalCode,
    required super.street,
    required super.neighborhood,
    required super.city,
    required super.state,
    super.complement,
  });

  factory AddressModel.fromEntity(AddressEntity entity) => AddressModel(
    postalCode: entity.postalCode,
    street: entity.street,
    neighborhood: entity.neighborhood,
    city: entity.city,
    state: entity.state,
    complement: entity.complement,
  );

  factory AddressModel.fromJson(MapDynamic json) => AddressModel(
    postalCode: json['postal_code'] as String? ?? json['cep'] as String? ?? '',
    street: json['street'] as String? ?? json['logradouro'] as String? ?? '',
    neighborhood:
        json['neighborhood'] as String? ?? json['bairro'] as String? ?? '',
    city: json['city'] as String? ?? json['localidade'] as String? ?? '',
    state: json['state'] as String? ?? json['uf'] as String? ?? '',
    complement:
        json['complement'] as String? ?? json['complemento'] as String?,
  );

  @override
  MapDynamic toJson() => {
    'postal_code': postalCode,
    'street': street,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    if (complement != null) 'complement': complement,
  };

  @override
  AddressEntity toEntity() => this;
}
