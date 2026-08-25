import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/responses/asset_model.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';

abstract interface class AssetsLocalDataSource {
  FutureList<AssetModel> getAssets(String companyId);
  FutureData<AssetModel> getAssetById(String id);
  FutureBool saveAsset(AssetModel asset);
  FutureBool deleteAsset(String id);
  FutureBool saveAssets(List<AssetModel> assets);
}

@LazySingleton(as: AssetsLocalDataSource)
final class AssetsLocalDataSourceImpl implements AssetsLocalDataSource {
  AssetsLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureList<AssetModel> getAssets(String companyId) {
    return ErrorHandler.execute(() async {
      final query =
          _database.select(_database.assets).join([
            innerJoin(
              _database.areas,
              _database.areas.id.equalsExp(_database.assets.areaId),
            ),
            innerJoin(
              _database.locations,
              _database.locations.id.equalsExp(_database.areas.locationId),
            ),
          ])..where(
            _database.assets.companyId.equals(companyId) &
                _database.assets.deletedAt.isNull() &
                _database.areas.deletedAt.isNull() &
                _database.locations.deletedAt.isNull(),
          );
      final rows = await query.get();

      final list = rows.map((row) {
        final asset = row.readTable(_database.assets);
        return AssetModel(
          id: asset.id,
          companyId: asset.companyId,
          areaId: asset.areaId,
          categoryId: asset.categoryId,
          parentAssetId: asset.parentAssetId,
          name: asset.name,
          code: asset.code,
          manufacturer: asset.manufacturer,
          model: asset.model,
          serialNumber: asset.serialNumber,
          installDate: asset.installDate?.toUtc(),
          warrantyExpiration: asset.warrantyExpiration?.toUtc(),
          revisionForecast: asset.revisionForecast?.toUtc(),
          status: AssetStatus.fromCode(asset.status),
          criticality: AssetCriticality.fromCode(asset.criticality),
          notes: asset.notes,
          createdAt: asset.createdAt.toUtc(),
          updatedAt: asset.updatedAt.toUtc(),
          deletedAt: asset.deletedAt?.toUtc(),
        );
      }).toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureData<AssetModel> getAssetById(String id) {
    return ErrorHandler.execute(() async {
      final query =
          _database.select(_database.assets).join([
            innerJoin(
              _database.areas,
              _database.areas.id.equalsExp(_database.assets.areaId),
            ),
            innerJoin(
              _database.locations,
              _database.locations.id.equalsExp(_database.areas.locationId),
            ),
          ])..where(
            _database.assets.id.equals(id) &
                _database.assets.deletedAt.isNull() &
                _database.areas.deletedAt.isNull() &
                _database.locations.deletedAt.isNull(),
          );
      final row = await query.getSingleOrNull();

      if (row == null) {
        return FailureState(message: 'Equipamento não encontrado'.hardcoded);
      }

      final asset = row.readTable(_database.assets);
      final model = AssetModel(
        id: asset.id,
        companyId: asset.companyId,
        areaId: asset.areaId,
        categoryId: asset.categoryId,
        parentAssetId: asset.parentAssetId,
        name: asset.name,
        code: asset.code,
        manufacturer: asset.manufacturer,
        model: asset.model,
        serialNumber: asset.serialNumber,
        installDate: asset.installDate?.toUtc(),
        warrantyExpiration: asset.warrantyExpiration?.toUtc(),
        revisionForecast: asset.revisionForecast?.toUtc(),
        status: AssetStatus.fromCode(asset.status),
        criticality: AssetCriticality.fromCode(asset.criticality),
        notes: asset.notes,
        createdAt: asset.createdAt.toUtc(),
        updatedAt: asset.updatedAt.toUtc(),
        deletedAt: asset.deletedAt?.toUtc(),
      );

      return SuccessState(data: model);
    });
  }

  @override
  FutureBool saveAsset(AssetModel asset) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.assets)
          .insertOnConflictUpdate(
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
              installDate: Value(asset.installDate?.toUtc()),
              warrantyExpiration: Value(asset.warrantyExpiration?.toUtc()),
              revisionForecast: Value(asset.revisionForecast?.toUtc()),
              status: Value(asset.status.code),
              criticality: Value(asset.criticality.code),
              notes: Value(asset.notes),
              createdAt: Value(asset.createdAt.toUtc()),
              updatedAt: Value(asset.updatedAt.toUtc()),
              deletedAt: Value(asset.deletedAt?.toUtc()),
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
        AssetsCompanion(deletedAt: Value(DateTime.now().toUtc())),
      );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveAssets(List<AssetModel> assets) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.assets,
          assets
              .map(
                (asset) => AssetsCompanion(
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
                  installDate: Value(asset.installDate?.toUtc()),
                  warrantyExpiration: Value(asset.warrantyExpiration?.toUtc()),
                  revisionForecast: Value(asset.revisionForecast?.toUtc()),
                  status: Value(asset.status.code),
                  criticality: Value(asset.criticality.code),
                  notes: Value(asset.notes),
                  createdAt: Value(asset.createdAt.toUtc()),
                  updatedAt: Value(asset.updatedAt.toUtc()),
                  deletedAt: Value(asset.deletedAt?.toUtc()),
                ),
              )
              .toList(),
        );
      });
      return const SuccessState(data: true);
    });
  }
}
