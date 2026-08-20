import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/requests/area_request_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';

import '../../../testing/mocks/entity_factory.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';
import '../helpers/location_integration_helper.dart';
import '../supabase_integration_helper.dart';

void main() {
  late SupabaseDatabaseClient db;
  late LocationsRemoteDataSource locationsRemote;
  late String companyId;
  late String locationId;

  setUpAll(() async {
    await SupabaseIntegrationHelper.initialize();
    db = SupabaseIntegrationHelper.databaseClient;
    locationsRemote = LocationsRemoteDataSourceImpl(database: db);
    companyId = IntegrationConfig.companyId;

    await SupabaseIntegrationHelper.signInAsAdmin();

    final location = await LocationIntegrationHelper.getOrCreateLocation(
      locationsRemote,
      companyId,
    );
    locationId = location.id;
  });

  tearDownAll(() async {
    if (IntegrationConfig.autoCleanup) {
      await IntegrationCleanup.cleanTracked(db);
    }
  });

  group('Area Database Integration Tests', () {
    test('Create, read, update, and soft-delete an area', () async {
      final areaId = faker.guid.guid();
      IntegrationDataTracker.instance.track('areas', areaId);

      final initialEntity = EntityFactory.makeAreaEntity().copyWith(
        id: areaId,
        companyId: companyId,
        locationId: locationId,
        name: IntegrationConfig.testName('Area ${faker.lorem.word()}'),
        floor: '2',
        description: 'Integration test area description',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      // 1. Create
      final createResult = await locationsRemote.createArea(
        AreaRequestModel.fromEntity(initialEntity),
      );
      expect(createResult, isA<SuccessState<AreaModel>>());
      final createdArea = (createResult as SuccessState<AreaModel>).data;
      expect(createdArea?.toEntity(), initialEntity);

      // 2. Read (list)
      final listResult = await locationsRemote.getAreas(companyId);
      expect(listResult, isA<SuccessState<List<AreaModel>>>());
      final areas = (listResult as SuccessState<List<AreaModel>>).data!;
      final foundArea = areas.firstWhere((a) => a.id == areaId);
      expect(foundArea.toEntity(), initialEntity);

      // 3. Update
      final updatedName = IntegrationConfig.testName(
        'Updated Area ${faker.lorem.word()}',
      );
      final updateEntity = initialEntity.copyWith(
        name: updatedName,
        floor: '3',
        updatedAt: DateTime.now().toUtc(),
      );
      final updateResult = await locationsRemote.updateArea(
        AreaRequestModel.fromEntity(updateEntity),
      );
      expect(updateResult, isA<SuccessState<AreaModel>>());
      final updatedArea = (updateResult as SuccessState<AreaModel>).data;
      expect(updatedArea?.toEntity(), updateEntity);

      // 4. Soft Delete
      final deleteResult = await locationsRemote.deleteArea(areaId);
      expect(deleteResult, isA<SuccessState<void>>());

      // 5. Verify deleted area is excluded from active list
      final postDeleteList = await locationsRemote.getAreas(companyId);
      final activeList =
          (postDeleteList as SuccessState<List<AreaModel>>).data!;
      expect(activeList.any((a) => a.id == areaId), isFalse);
    });
  });
}
