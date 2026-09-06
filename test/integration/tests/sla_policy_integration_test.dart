@Tags(['integration'])
library;

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/models/responses/sla_policy_model.dart';

import '../../../testing/mocks/factories/system_factory.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';
import '../core/integration_run.dart';
import '../supabase_integration_helper.dart';

void main() {
  if (!IntegrationRun.registerGuard()) return;

  late SupabaseDatabaseClient db;
  late SlaRemoteDataSource slaRemote;
  late String companyId;

  setUpAll(() async {
    await SupabaseIntegrationHelper.initialize();
    db = SupabaseIntegrationHelper.databaseClient;
    slaRemote = SlaRemoteDataSourceImpl(
      database: db,
      realtimeClient: SupabaseIntegrationHelper.realtimeClient,
    );
    companyId = IntegrationConfig.companyId;

    await SupabaseIntegrationHelper.signInAsAdmin();
  });

  tearDownAll(() async {
    if (IntegrationConfig.autoCleanup) {
      await IntegrationCleanup.cleanTracked(db);
    }
  });

  group('SLA Policy Database Integration Tests', () {
    test('Create, read, update, and soft-delete an SLA policy', () async {
      final policyId = faker.guid.guid();
      IntegrationDataTracker.instance.track('sla_policies', policyId);

      final initialEntity = SystemFactory.makeSlaPolicyEntity().copyWith(
        id: policyId,
        companyId: companyId,
        name: IntegrationConfig.testName('SLA Policy ${faker.lorem.word()}'),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      // 1. Create
      final createResult = await slaRemote.createSlaPolicy(
        SlaPolicyModel.fromEntity(initialEntity),
      );
      expect(createResult, isA<SuccessState<bool>>());

      // 2. Read by ID
      final getByIdResult = await slaRemote.getSlaPolicyById(policyId);
      expect(getByIdResult, isA<SuccessState<SlaPolicyModel>>());
      final createdPolicy =
          (getByIdResult as SuccessState<SlaPolicyModel>).data;
      expect(createdPolicy?.toEntity(), initialEntity);

      // 3. Read list
      final listResult = await slaRemote.getSlaPolicies(companyId);
      expect(listResult, isA<SuccessState<List<SlaPolicyModel>>>());
      final policies = (listResult as SuccessState<List<SlaPolicyModel>>).data!;
      final foundPolicy = policies.firstWhere((p) => p.id == policyId);
      expect(foundPolicy.toEntity(), initialEntity);

      // 4. Update
      final updatedName = IntegrationConfig.testName(
        'Updated SLA ${faker.lorem.word()}',
      );
      final updatedEntity = SystemFactory.makeSlaPolicyEntity().copyWith(
        id: policyId,
        companyId: companyId,
        name: updatedName,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      final updateResult = await slaRemote.updateSlaPolicy(
        SlaPolicyModel.fromEntity(updatedEntity),
      );
      expect(updateResult, isA<SuccessState<bool>>());

      final getAfterUpdate = await slaRemote.getSlaPolicyById(policyId);
      final updatedPolicy =
          (getAfterUpdate as SuccessState<SlaPolicyModel>).data;
      expect(updatedPolicy?.toEntity(), updatedEntity);

      // 5. Soft Delete
      if (IntegrationConfig.autoCleanup) {
        final deleteResult = await slaRemote.deleteSlaPolicy(policyId);
        expect(deleteResult, isA<SuccessState<void>>());

        // 6. Verify deleted SLA policy is excluded from active list
        final postDeleteList = await slaRemote.getSlaPolicies(companyId);
        final activeList =
            (postDeleteList as SuccessState<List<SlaPolicyModel>>).data!;
        expect(activeList.any((p) => p.id == policyId), isFalse);
      }
    });
  });
}
