import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/requests/area_request_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';

import '../../../testing/mocks/factories/asset_factory.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';

/// Helper for getting or creating Locations and Areas in integration tests.
class LocationIntegrationHelper {
  const LocationIntegrationHelper._();

  /// Returns an existing location or creates a new `[IT]`-prefixed one.
  static Future<LocationModel> getOrCreateLocation(
    LocationsRemoteDataSource remote,
    String companyId,
  ) async {
    if (IntegrationConfig.useExistingData) {
      final result = await remote.getLocations(companyId);
      if (result is SuccessState<List<LocationModel>> &&
          (result.data?.isNotEmpty ?? false)) {
        return result.data!.first;
      }
    }

    final entity = AssetFactory.makeLocationEntity().copyWith(
      id: faker.guid.guid(),
      companyId: companyId,
      name: IntegrationConfig.testName(faker.address.city()),
      isActive: true,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final model = LocationModel.fromEntity(entity);
    final result = await remote.createLocation(model);
    final created = (result as SuccessState<LocationModel>).data!;
    IntegrationDataTracker.instance.track('locations', created.id);
    return created;
  }

  /// Returns an existing area for the given location or creates a new one.
  static Future<AreaModel> getOrCreateArea(
    LocationsRemoteDataSource remote,
    String companyId,
    String locationId,
  ) async {
    if (IntegrationConfig.useExistingData) {
      final result = await remote.getAreas(companyId);
      final validAreas = result.data
          ?.where((a) => a.locationId == locationId)
          .toList();
      if (validAreas != null && validAreas.isNotEmpty) {
        return validAreas.first;
      }
    }

    final entity = AssetFactory.makeAreaEntity().copyWith(
      id: faker.guid.guid(),
      companyId: companyId,
      locationId: locationId,
      name: IntegrationConfig.testName(faker.lorem.word()),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final model = AreaRequestModel.fromEntity(entity);
    final result = await remote.createArea(model);
    final created = (result as SuccessState<AreaModel>).data!;
    IntegrationDataTracker.instance.track('areas', created.id);
    return created;
  }

  /// Finds a location by `[IT]` prefix name. Returns null if not found.
  static Future<LocationEntity?> findByPrefix(
    LocationsRemoteDataSource remote,
    String companyId,
  ) async {
    final result = await remote.getLocations(companyId);
    if (result is SuccessState<List<LocationModel>>) {
      return result.data
          ?.cast<LocationEntity>()
          .where((l) => l.name.startsWith(IntegrationConfig.testDataPrefix))
          .firstOrNull;
    }
    return null;
  }

  /// Finds an area by `[IT]` prefix name. Returns null if not found.
  static Future<AreaEntity?> findAreaByPrefix(
    LocationsRemoteDataSource remote,
    String companyId,
  ) async {
    final result = await remote.getAreas(companyId);
    if (result is SuccessState<List<AreaModel>>) {
      return result.data
          ?.cast<AreaEntity>()
          .where((a) => a.name.startsWith(IntegrationConfig.testDataPrefix))
          .firstOrNull;
    }
    return null;
  }
}
