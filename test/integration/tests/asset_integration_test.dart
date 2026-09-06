@Tags(['integration'])
library;

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/requests/asset_request_model.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/responses/asset_model.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';

import '../../../testing/mocks/entity_factory.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';
import '../core/integration_run.dart';
import '../helpers/category_integration_helper.dart';
import '../helpers/location_integration_helper.dart';
import '../supabase_integration_helper.dart';

void main() {
  if (!IntegrationRun.registerGuard()) return;

  late SupabaseDatabaseClient db;
  late AssetsRemoteDataSource assetsRemote;
  late LocationsRemoteDataSource locationsRemote;
  late CategoriesRemoteDataSource categoriesRemote;
  late String companyId;
  late String areaId;
  late String categoryId;

  setUpAll(() async {
    await SupabaseIntegrationHelper.initialize();
    db = SupabaseIntegrationHelper.databaseClient;
    assetsRemote = AssetsRemoteDataSourceImpl(
      database: db,
      realtimeClient: SupabaseIntegrationHelper.realtimeClient,
    );
    locationsRemote = LocationsRemoteDataSourceImpl(
      database: db,
      realtimeClient: SupabaseIntegrationHelper.realtimeClient,
    );
    categoriesRemote = CategoriesRemoteDataSourceImpl(database: db);
    companyId = IntegrationConfig.companyId;

    await SupabaseIntegrationHelper.signInAsAdmin();

    final location = await LocationIntegrationHelper.getOrCreateLocation(
      locationsRemote,
      companyId,
    );
    final area = await LocationIntegrationHelper.getOrCreateArea(
      locationsRemote,
      companyId,
      location.id,
    );
    areaId = area.id;

    final category = await CategoryIntegrationHelper.getOrCreateCategory(
      categoriesRemote,
      companyId,
    );
    categoryId = category.id;
  });

  tearDownAll(() async {
    if (IntegrationConfig.autoCleanup) {
      await IntegrationCleanup.cleanTracked(db);
    }
  });

  group('Asset Database Integration Tests', () {
    test('Create, read, update, and soft-delete an asset', () async {
      final assetId = faker.guid.guid();
      IntegrationDataTracker.instance.track('assets', assetId);

      final initialEntity = EntityFactory.makeAssetEntity().copyWith(
        id: assetId,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        name: IntegrationConfig.testName('Asset ${faker.company.name()}'),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        annulParentAssetId: true,
        annulInstallDate: true,
        annulWarrantyExpiration: true,
        annulRevisionForecast: true,
      );

      // 1. Create
      final createResult = await assetsRemote.createAsset(
        AssetRequestModel.fromEntity(initialEntity),
      );
      expect(createResult, isA<SuccessState<AssetModel>>());
      final createdAsset = (createResult as SuccessState<AssetModel>).data;
      expect(createdAsset?.toEntity(), initialEntity);

      // 2. Read by ID
      final getByIdResult = await assetsRemote.getAssetById(assetId);
      expect(getByIdResult, isA<SuccessState<AssetModel>>());
      final fetchedAsset = (getByIdResult as SuccessState<AssetModel>).data;
      expect(fetchedAsset?.toEntity(), initialEntity);

      // 3. Read list
      final listResult = await assetsRemote.getAssets(companyId);
      expect(listResult, isA<SuccessState<List<AssetModel>>>());
      final assets = (listResult as SuccessState<List<AssetModel>>).data!;
      final foundAsset = assets.firstWhere((a) => a.id == assetId);
      expect(foundAsset.toEntity(), initialEntity);

      // 4. Update
      final updatedName = IntegrationConfig.testName(
        'Updated Asset ${faker.company.name()}',
      );
      final updatedEntity = EntityFactory.makeAssetEntity().copyWith(
        id: assetId,
        companyId: companyId,
        areaId: areaId,
        categoryId: categoryId,
        name: updatedName,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        annulParentAssetId: true,
        annulInstallDate: true,
        annulWarrantyExpiration: true,
        annulRevisionForecast: true,
      );
      final updateResult = await assetsRemote.updateAsset(
        AssetRequestModel.fromEntity(updatedEntity),
      );
      expect(updateResult, isA<SuccessState<AssetModel>>());
      final updatedAsset = (updateResult as SuccessState<AssetModel>).data;
      expect(updatedAsset?.toEntity(), updatedEntity);

      // 5. Soft Delete
      if (IntegrationConfig.autoCleanup) {
        final deleteResult = await assetsRemote.deleteAsset(assetId);
        expect(deleteResult, isA<SuccessState<void>>());

        // 6. Verify deleted asset is excluded from active list
        final postDeleteList = await assetsRemote.getAssets(companyId);
        final activeList =
            (postDeleteList as SuccessState<List<AssetModel>>).data!;
        expect(activeList.any((a) => a.id == assetId), isFalse);
      }
    });
  });
}
