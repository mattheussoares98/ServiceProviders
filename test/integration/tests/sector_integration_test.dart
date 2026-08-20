import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_model.dart';

import '../../../testing/mocks/entity_factory.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';
import '../supabase_integration_helper.dart';

void main() {
  late SupabaseDatabaseClient db;
  late SectorsRemoteDataSource sectorsRemote;
  late String companyId;

  setUpAll(() async {
    await SupabaseIntegrationHelper.initialize();
    db = SupabaseIntegrationHelper.databaseClient;
    sectorsRemote = SectorsRemoteDataSourceImpl(database: db);
    companyId = IntegrationConfig.companyId;

    await SupabaseIntegrationHelper.signInAsAdmin();
  });

  tearDownAll(() async {
    if (IntegrationConfig.autoCleanup) {
      await IntegrationCleanup.cleanTracked(db);
    }
  });

  group('Sector Database Integration Tests', () {
    test('Create, read, update, and soft-delete a sector', () async {
      final sectorId = faker.guid.guid();
      IntegrationDataTracker.instance.track('sectors', sectorId);

      final initialEntity = EntityFactory.makeSectorEntity().copyWith(
        id: sectorId,
        companyId: companyId,
        name: IntegrationConfig.testName('Sector ${faker.lorem.word()}'),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      // 1. Create
      final createResult = await sectorsRemote.createSector(
        SectorModel.fromEntity(initialEntity),
      );
      expect(createResult, isA<SuccessState<SectorModel>>());
      final createdSector = (createResult as SuccessState<SectorModel>).data;
      expect(createdSector?.toEntity(), initialEntity);

      // 2. Read (list)
      final listResult = await sectorsRemote.getSectors(companyId);
      expect(listResult, isA<SuccessState<List<SectorModel>>>());
      final sectors = (listResult as SuccessState<List<SectorModel>>).data!;
      final foundSector = sectors.firstWhere((s) => s.id == sectorId);
      expect(foundSector.toEntity(), initialEntity);

      // 3. Update
      final updatedName = IntegrationConfig.testName(
        'Updated Sector ${faker.lorem.word()}',
      );
      final updateEntity = initialEntity.copyWith(
        name: updatedName,
        updatedAt: DateTime.now().toUtc(),
      );
      final updateResult = await sectorsRemote.updateSector(
        SectorModel.fromEntity(updateEntity),
      );
      expect(updateResult, isA<SuccessState<SectorModel>>());
      final updatedSector = (updateResult as SuccessState<SectorModel>).data;
      expect(updatedSector?.toEntity(), updateEntity);

      // 4. Soft Delete
      final deleteResult = await sectorsRemote.deleteSector(sectorId);
      expect(deleteResult, isA<SuccessState<void>>());

      // 5. Verify deleted sector is excluded from active list
      final postDeleteList = await sectorsRemote.getSectors(companyId);
      final activeList =
          (postDeleteList as SuccessState<List<SectorModel>>).data!;
      expect(activeList.any((s) => s.id == sectorId), isFalse);
    });
  });
}
