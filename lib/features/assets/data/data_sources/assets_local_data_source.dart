import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/handlers/error_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/assets/data/models/responses/asset_response_model.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

abstract interface class AssetsLocalDataSource {
  FutureList<AssetResponseModel> getAssets(String companyId);
  FutureData<AssetResponseModel> getAssetById(String id);
  FutureBool saveAsset(AssetResponseModel asset);
  FutureBool deleteAsset(String id);
}

@LazySingleton(as: AssetsLocalDataSource)
final class AssetsLocalDataSourceImpl implements AssetsLocalDataSource {
  AssetsLocalDataSourceImpl({
    required AppDatabase database,
  }) : _database = database;

  final AppDatabase _database;

  @override
  FutureList<AssetResponseModel> getAssets(String companyId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.assets)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map((row) => AssetResponseModel(
                id: row.id,
                companyId: row.companyId,
                areaId: row.areaId,
                categoryId: row.categoryId,
                parentAssetId: row.parentAssetId,
                name: row.name,
                code: row.code,
                manufacturer: row.manufacturer,
                model: row.model,
                serialNumber: row.serialNumber,
                installDate: row.installDate,
                warrantyExpiration: row.warrantyExpiration,
                revisionForecast: row.revisionForecast,
                status: AssetStatus.fromCode(row.status),
                criticality: AssetCriticality.fromCode(row.criticality),
                notes: row.notes,
                createdAt: row.createdAt,
                updatedAt: row.updatedAt,
                deletedAt: row.deletedAt,
              ))
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureData<AssetResponseModel> getAssetById(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.assets)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
      final row = await query.getSingleOrNull();

      if (row == null) {
        return FailureState(message: 'Asset not found');
      }

      final model = AssetResponseModel(
        id: row.id,
        companyId: row.companyId,
        areaId: row.areaId,
        categoryId: row.categoryId,
        parentAssetId: row.parentAssetId,
        name: row.name,
        code: row.code,
        manufacturer: row.manufacturer,
        model: row.model,
        serialNumber: row.serialNumber,
        installDate: row.installDate,
        warrantyExpiration: row.warrantyExpiration,
        revisionForecast: row.revisionForecast,
        status: AssetStatus.fromCode(row.status),
        criticality: AssetCriticality.fromCode(row.criticality),
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );

      return SuccessState(data: model);
    });
  }

  @override
  FutureBool saveAsset(AssetResponseModel asset) {
    return ErrorHandler.execute(() async {
      await _database.into(_database.assets).insertOnConflictUpdate(
            AssetsCompanion(
              id: Value(asset.id),
              companyId: Value(asset.companyId),
              areaId: Value(asset.areaId),
              categoryId: Value(asset.categoryId),
              parentAssetId: Value(asset.parentAssetId),
              name: Value(asset.name),
              code: Value(asset.code),
              manufacturer: Value(asset.manufacturer),
              model: Value(asset.model),
              serialNumber: Value(asset.serialNumber),
              installDate: Value(asset.installDate),
              warrantyExpiration: Value(asset.warrantyExpiration),
              revisionForecast: Value(asset.revisionForecast),
              status: Value(asset.status.code),
              criticality: Value(asset.criticality.code),
              notes: Value(asset.notes),
              createdAt: Value(asset.createdAt),
              updatedAt: Value(asset.updatedAt),
              deletedAt: Value(asset.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteAsset(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.assets)
        ..where((t) => t.id.equals(id));
      await query.write(
        AssetsCompanion(
          deletedAt: Value(DateTime.now()),
        ),
      );
      return const SuccessState(data: true);
    });
  }
}
