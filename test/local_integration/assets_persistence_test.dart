import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/assets/data/data_sources/assets_local_data_source.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/responses/asset_model.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';

import '../../testing/mocks/factories/asset_factory.dart';
import '../../testing/mocks/factories/local_database_fixture.dart';

void main() {
  late LocalDatabaseFixture fixture;
  AssetsLocalDataSourceImpl source() =>
      AssetsLocalDataSourceImpl(database: fixture.database);
  LocationsLocalDataSourceImpl locations() =>
      LocationsLocalDataSourceImpl(database: fixture.database);
  final location = AssetFactory.makeLocationEntity();
  final area = AssetFactory.makeAreaEntity().copyWith(
    companyId: location.companyId,
    locationId: location.id,
  );
  final asset = AssetFactory.makeAssetEntity().copyWith(
    companyId: location.companyId,
    areaId: area.id,
    annulParentAssetId: true,
  );
  setUp(() async {
    fixture = LocalDatabaseFixture();
    expect(
      (await locations().saveLocation(LocationModel.fromEntity(location))).data,
      isTrue,
    );
    expect(
      (await locations().saveArea(AreaModel.fromEntity(area))).data,
      isTrue,
    );
  });
  tearDown(() => fixture.dispose());

  test(
    'asset CRUD, clearing fields, and criticality survive database reopening',
    () async {
      expect(
        (await source().saveAsset(AssetModel.fromEntity(asset))).data,
        isTrue,
      );
      await fixture.reopen();
      var row = (await source().getAssetById(asset.id)).data!;
      expect(row.companyId, asset.companyId);
      expect(row.name, asset.name);
      expect(row.notes, asset.notes);
      final updated = asset.copyWith(
        name: 'Bomba revisada',
        criticality: AssetCriticality.high,
        annulNotes: true,
        annulSerialNumber: true,
        annulWarrantyExpiration: true,
        annulCategoryId: true,
      );
      expect(
        (await source().saveAsset(AssetModel.fromEntity(updated))).data,
        isTrue,
      );
      await fixture.reopen();
      row = (await source().getAssetById(asset.id)).data!;
      expect(row.name, 'Bomba revisada');
      expect(row.criticality, AssetCriticality.high);
      expect(row.notes, isNull);
      expect(row.serialNumber, isNull);
      expect(row.warrantyExpiration, isNull);
      expect(row.categoryId, isNull);
      expect((await source().deleteAsset(asset.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getAssets(asset.companyId)).data, isEmpty);
      expect(
        await source().getAssetById(asset.id),
        isA<FailureState<AssetModel>>(),
      );
    },
  );

  test(
    'moving an asset preserves its new area after the old area is deleted',
    () async {
      final newArea = AssetFactory.makeAreaEntity().copyWith(
        companyId: area.companyId,
        locationId: location.id,
      );
      expect(
        (await locations().saveArea(AreaModel.fromEntity(newArea))).data,
        isTrue,
      );
      expect(
        (await source().saveAsset(AssetModel.fromEntity(asset))).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().saveAsset(
          AssetModel.fromEntity(asset.copyWith(areaId: newArea.id)),
        )).data,
        isTrue,
      );
      expect((await locations().deleteArea(area.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getAssetById(asset.id)).data!.areaId, newArea.id);
      expect(
        (await source().getAssets(asset.companyId)).data!.single.id,
        asset.id,
      );
    },
  );

  test('deleting a parent location hides descendants after restart', () async {
    expect(
      (await source().saveAsset(AssetModel.fromEntity(asset))).data,
      isTrue,
    );
    await fixture.reopen();
    expect((await locations().deleteLocation(location.id)).data, isTrue);
    await fixture.reopen();
    expect((await source().getAssets(asset.companyId)).data, isEmpty);
    expect(
      await source().getAssetById(asset.id),
      isA<FailureState<AssetModel>>(),
    );
  });

  test(
    'parent-child links and repeat batch updates persist without duplication',
    () async {
      final child = AssetFactory.makeAssetEntity().copyWith(
        companyId: asset.companyId,
        areaId: area.id,
        parentAssetId: asset.id,
      );
      final batch = [
        AssetModel.fromEntity(asset),
        AssetModel.fromEntity(child),
      ];
      expect((await source().saveAssets(batch)).data, isTrue);
      await fixture.reopen();
      expect((await source().saveAssets(batch)).data, isTrue);
      await fixture.reopen();
      expect((await source().getAssets(asset.companyId)).data, hasLength(2));
      expect(
        (await source().getAssetById(child.id)).data!.parentAssetId,
        asset.id,
      );
      expect(
        (await source().saveAsset(
          AssetModel.fromEntity(child.copyWith(annulParentAssetId: true)),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getAssetById(child.id)).data!.parentAssetId,
        isNull,
      );
    },
  );
}
