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

  AssetEntity copyWith({
    String? id,
    String? companyId,
    String? areaId,
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
  }) {
    return AssetEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      areaId: areaId ?? this.areaId,
      categoryId: categoryId ?? this.categoryId,
      parentAssetId: parentAssetId ?? this.parentAssetId,
      name: name ?? this.name,
      code: code ?? this.code,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      installDate: installDate ?? this.installDate,
      warrantyExpiration: warrantyExpiration ?? this.warrantyExpiration,
      revisionForecast: revisionForecast ?? this.revisionForecast,
      status: status ?? this.status,
      criticality: criticality ?? this.criticality,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  AssetEntity annulCategoryId() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: null,
        parentAssetId: parentAssetId,
        name: name,
        code: code,
        manufacturer: manufacturer,
        model: model,
        serialNumber: serialNumber,
        installDate: installDate,
        warrantyExpiration: warrantyExpiration,
        revisionForecast: revisionForecast,
        status: status,
        criticality: criticality,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AssetEntity annulParentAssetId() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        parentAssetId: null,
        name: name,
        code: code,
        manufacturer: manufacturer,
        model: model,
        serialNumber: serialNumber,
        installDate: installDate,
        warrantyExpiration: warrantyExpiration,
        revisionForecast: revisionForecast,
        status: status,
        criticality: criticality,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AssetEntity annulCode() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        parentAssetId: parentAssetId,
        name: name,
        code: null,
        manufacturer: manufacturer,
        model: model,
        serialNumber: serialNumber,
        installDate: installDate,
        warrantyExpiration: warrantyExpiration,
        revisionForecast: revisionForecast,
        status: status,
        criticality: criticality,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AssetEntity annulManufacturer() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        parentAssetId: parentAssetId,
        name: name,
        code: code,
        manufacturer: null,
        model: model,
        serialNumber: serialNumber,
        installDate: installDate,
        warrantyExpiration: warrantyExpiration,
        revisionForecast: revisionForecast,
        status: status,
        criticality: criticality,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AssetEntity annulModel() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        parentAssetId: parentAssetId,
        name: name,
        code: code,
        manufacturer: manufacturer,
        model: null,
        serialNumber: serialNumber,
        installDate: installDate,
        warrantyExpiration: warrantyExpiration,
        revisionForecast: revisionForecast,
        status: status,
        criticality: criticality,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AssetEntity annulSerialNumber() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        parentAssetId: parentAssetId,
        name: name,
        code: code,
        manufacturer: manufacturer,
        model: model,
        serialNumber: null,
        installDate: installDate,
        warrantyExpiration: warrantyExpiration,
        revisionForecast: revisionForecast,
        status: status,
        criticality: criticality,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AssetEntity annulInstallDate() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        parentAssetId: parentAssetId,
        name: name,
        code: code,
        manufacturer: manufacturer,
        model: model,
        serialNumber: serialNumber,
        installDate: null,
        warrantyExpiration: warrantyExpiration,
        revisionForecast: revisionForecast,
        status: status,
        criticality: criticality,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AssetEntity annulWarrantyExpiration() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        parentAssetId: parentAssetId,
        name: name,
        code: code,
        manufacturer: manufacturer,
        model: model,
        serialNumber: serialNumber,
        installDate: installDate,
        warrantyExpiration: null,
        revisionForecast: revisionForecast,
        status: status,
        criticality: criticality,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AssetEntity annulRevisionForecast() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        parentAssetId: parentAssetId,
        name: name,
        code: code,
        manufacturer: manufacturer,
        model: model,
        serialNumber: serialNumber,
        installDate: installDate,
        warrantyExpiration: warrantyExpiration,
        revisionForecast: null,
        status: status,
        criticality: criticality,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AssetEntity annulNotes() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        parentAssetId: parentAssetId,
        name: name,
        code: code,
        manufacturer: manufacturer,
        model: model,
        serialNumber: serialNumber,
        installDate: installDate,
        warrantyExpiration: warrantyExpiration,
        revisionForecast: revisionForecast,
        status: status,
        criticality: criticality,
        notes: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AssetEntity annulDeletedAt() => AssetEntity(
        id: id,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        parentAssetId: parentAssetId,
        name: name,
        code: code,
        manufacturer: manufacturer,
        model: model,
        serialNumber: serialNumber,
        installDate: installDate,
        warrantyExpiration: warrantyExpiration,
        revisionForecast: revisionForecast,
        status: status,
        criticality: criticality,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );
}
