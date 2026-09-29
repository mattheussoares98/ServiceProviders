import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';

class AssetEntity extends Equatable {
  const AssetEntity({
    required this.id,
    required this.companyId,
    this.locationId,
    this.areaId,
    this.customerId,
    required this.categoryId,
    required this.parentAssetId,
    required this.name,
    required this.code,
    required this.manufacturer,
    required this.model,
    required this.serialNumber,
    required this.installDate,
    required this.warrantyExpiration,
    required this.revisionForecast,
    required this.status,
    required this.criticality,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String companyId;
  final String? locationId;
  final String? areaId;
  final String? customerId;
  final String? categoryId;
  final String? parentAssetId;
  final String name;
  final String? code;
  final String? manufacturer;
  final String? model;
  final String? serialNumber;
  final DateTime? installDate;
  final DateTime? warrantyExpiration;
  final DateTime? revisionForecast;
  final AssetStatus status;
  final AssetCriticality criticality;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  @override
  List<Object?> get props => [
    id,
    companyId,
    locationId,
    areaId,
    customerId,
    categoryId,
    parentAssetId,
    name,
    code,
    manufacturer,
    model,
    serialNumber,
    installDate,
    warrantyExpiration,
    revisionForecast,
    status,
    criticality,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ];

  AssetEntity copyWith({
    String? id,
    String? companyId,
    String? locationId,
    String? areaId,
    String? customerId,
    String? categoryId,
    String? parentAssetId,
    String? name,
    String? code,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? installDate,
    DateTime? warrantyExpiration,
    DateTime? revisionForecast,
    AssetStatus? status,
    AssetCriticality? criticality,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulLocationId,
    bool? annulAreaId,
    bool? annulCustomerId,
    bool? annulCategoryId,
    bool? annulParentAssetId,
    bool? annulCode,
    bool? annulManufacturer,
    bool? annulModel,
    bool? annulSerialNumber,
    bool? annulInstallDate,
    bool? annulWarrantyExpiration,
    bool? annulRevisionForecast,
    bool? annulNotes,
    bool? annulDeletedAt,
  }) {
    return AssetEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      locationId: annulLocationId == true
          ? null
          : locationId ?? this.locationId,
      areaId: annulAreaId == true ? null : areaId ?? this.areaId,
      customerId: annulCustomerId == true
          ? null
          : customerId ?? this.customerId,
      categoryId: annulCategoryId == true
          ? null
          : categoryId ?? this.categoryId,
      parentAssetId: annulParentAssetId == true
          ? null
          : parentAssetId ?? this.parentAssetId,
      name: name ?? this.name,
      code: annulCode == true ? null : code ?? this.code,
      manufacturer: annulManufacturer == true
          ? null
          : manufacturer ?? this.manufacturer,
      model: annulModel == true ? null : model ?? this.model,
      serialNumber: annulSerialNumber == true
          ? null
          : serialNumber ?? this.serialNumber,
      installDate: annulInstallDate == true
          ? null
          : installDate ?? this.installDate,
      warrantyExpiration: annulWarrantyExpiration == true
          ? null
          : warrantyExpiration ?? this.warrantyExpiration,
      revisionForecast: annulRevisionForecast == true
          ? null
          : revisionForecast ?? this.revisionForecast,
      status: status ?? this.status,
      criticality: criticality ?? this.criticality,
      notes: annulNotes == true ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
