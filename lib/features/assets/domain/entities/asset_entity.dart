import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:equatable/equatable.dart';

class AssetEntity extends Equatable {
  const AssetEntity({
    required this.id,
    required this.companyId,
    required this.areaId,
    this.categoryId,
    this.parentAssetId,
    required this.name,
    this.code,
    this.manufacturer,
    this.model,
    this.serialNumber,
    this.installDate,
    this.warrantyExpiration,
    this.revisionForecast,
    required this.status,
    required this.criticality,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String companyId;
  final String areaId;
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

  @override
  List<Object?> get props => [
        id,
        companyId,
        areaId,
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
}
