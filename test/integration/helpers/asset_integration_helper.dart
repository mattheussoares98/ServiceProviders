import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/requests/asset_request_model.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/responses/asset_model.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';

import '../../../testing/mocks/entity_factory.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';

/// Holds an asset along with its resolved area/location IDs.
class AssetSetupResult {
  const AssetSetupResult({
    required this.asset,
    required this.areaId,
    required this.locationId,
  });

  final AssetModel asset;
  final String areaId;
  final String locationId;
}

/// Helper for getting or creating Assets in integration tests.
class AssetIntegrationHelper {
  const AssetIntegrationHelper._();

  /// Returns an existing asset (with its area/location synced) or creates one.
  ///
  /// When using existing data, syncs [areaId] and `[locationId]` from the
  /// asset's actual relationships to avoid DB constraint violations.
  static Future<AssetSetupResult> getOrCreateAsset({
    required AssetsRemoteDataSource assetsRemote,
    required LocationsRemoteDataSource locationsRemote,
    required String companyId,
    required String areaId,
    required String categoryId,
  }) async {
    if (IntegrationConfig.useExistingData) {
      final result = await assetsRemote.getAssets(companyId);
      if (result is SuccessState<List<AssetModel>> &&
          (result.data?.isNotEmpty ?? false)) {
        final existing = result.data!.first;
        // Sync area and location from asset's actual relationships
        var resolvedAreaId = existing.areaId;
        var resolvedLocationId = '';

        final areas = await locationsRemote.getAreas(companyId);
        final assetArea = areas.data?.firstWhere(
          (a) => a.id == resolvedAreaId,
          orElse: () => areas.data!.first,
        );
        if (assetArea != null) {
          resolvedAreaId = assetArea.id;
          resolvedLocationId = assetArea.locationId;
        }

        return AssetSetupResult(
          asset: existing,
          areaId: resolvedAreaId,
          locationId: resolvedLocationId,
        );
      }
    }

    final entity = EntityFactory.makeAssetEntity().copyWith(
      id: faker.guid.guid(),
      companyId: companyId,
      areaId: areaId,
      categoryId: categoryId,
      name: IntegrationConfig.testName(faker.company.name()),
      status: AssetStatus.active,
      criticality: AssetCriticality.medium,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      annulParentAssetId: true,
      annulInstallDate: true,
      annulWarrantyExpiration: true,
      annulRevisionForecast: true,
    );
    final model = AssetRequestModel.fromEntity(entity);
    final result = await assetsRemote.createAsset(model);
    final created = (result as SuccessState<AssetModel>).data!;
    IntegrationDataTracker.instance.track('assets', created.id);

    // Resolve locationId from areaId
    var resolvedLocationId = '';
    final areas = await locationsRemote.getAreas(companyId);
    final assetArea = areas.data?.firstWhere(
      (a) => a.id == areaId,
      orElse: () => areas.data!.first,
    );
    if (assetArea != null) {
      resolvedLocationId = assetArea.locationId;
    }

    return AssetSetupResult(
      asset: created,
      areaId: areaId,
      locationId: resolvedLocationId,
    );
  }
}
