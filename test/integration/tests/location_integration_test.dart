import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';

import '../../../testing/mocks/entity_factory.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';
import '../supabase_integration_helper.dart';

void main() {
  late SupabaseDatabaseClient db;
  late LocationsRemoteDataSource locationsRemote;
  late String companyId;

  setUpAll(() async {
    await SupabaseIntegrationHelper.initialize();
    db = SupabaseIntegrationHelper.databaseClient;
    locationsRemote = LocationsRemoteDataSourceImpl(database: db);
    companyId = IntegrationConfig.companyId;

    await SupabaseIntegrationHelper.signInAsAdmin();
  });

  tearDownAll(() async {
    if (IntegrationConfig.autoCleanup) {
      await IntegrationCleanup.cleanTracked(db);
    }
  });

  group('Location Database Integration Tests', () {
    test('Create, read, update, and soft-delete a location', () async {
      final locationId = faker.guid.guid();
      IntegrationDataTracker.instance.track('locations', locationId);

      final initialEntity = EntityFactory.makeLocationEntity().copyWith(
        id: locationId,
        companyId: companyId,
        name: IntegrationConfig.testName('Location ${faker.address.city()}'),
        address: faker.address.streetAddress(),
        city: faker.address.city(),
        state: faker.address.state(),
        isActive: true,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      // 1. Create
      final createResult = await locationsRemote.createLocation(
        LocationModel.fromEntity(initialEntity),
      );
      expect(createResult, isA<SuccessState<LocationModel>>());
      final createdLocation =
          (createResult as SuccessState<LocationModel>).data;
      expect(createdLocation?.toEntity(), initialEntity);

      // 2. Read (list)
      final listResult = await locationsRemote.getLocations(companyId);
      expect(listResult, isA<SuccessState<List<LocationModel>>>());
      final locations = (listResult as SuccessState<List<LocationModel>>).data!;
      final foundLocation = locations.firstWhere((l) => l.id == locationId);
      expect(foundLocation.toEntity(), initialEntity);

      // 3. Update
      final updatedName = IntegrationConfig.testName(
        'Updated ${faker.address.city()}',
      );
      final updateEntity = initialEntity.copyWith(
        name: updatedName,
        updatedAt: DateTime.now().toUtc(),
      );
      final updateResult = await locationsRemote.updateLocation(
        LocationModel.fromEntity(updateEntity),
      );
      expect(updateResult, isA<SuccessState<LocationModel>>());
      final updatedLocation =
          (updateResult as SuccessState<LocationModel>).data;
      expect(updatedLocation?.toEntity(), updateEntity);

      // 4. Soft Delete
      final deleteResult = await locationsRemote.deleteLocation(locationId);
      expect(deleteResult, isA<SuccessState<void>>());

      // 5. Verify deleted location is excluded from active list
      final postDeleteList = await locationsRemote.getLocations(companyId);
      final activeList =
          (postDeleteList as SuccessState<List<LocationModel>>).data!;
      expect(activeList.any((l) => l.id == locationId), isFalse);
    });
  });
}
