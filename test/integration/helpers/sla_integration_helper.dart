import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/models/responses/sla_policy_model.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_applies_to.dart';

import '../../../testing/mocks/entity_factory.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';

/// Helper for getting or creating SLA Policies in integration tests.
class SlaIntegrationHelper {
  const SlaIntegrationHelper._();

  /// Returns an existing SLA policy or creates a new [IT]-prefixed one.
  static Future<SlaPolicyModel> getOrCreateSlaPolicy(
    SlaRemoteDataSource remote,
    String companyId,
  ) async {
    if (IntegrationConfig.useExistingData) {
      final result = await remote.getSlaPolicies(companyId);
      if (result is SuccessState<List<SlaPolicyModel>> &&
          (result.data?.isNotEmpty ?? false)) {
        return result.data!.first;
      }
    }

    final entity = EntityFactory.makeSlaPolicyEntity().copyWith(
      id: faker.guid.guid(),
      companyId: companyId,
      name: IntegrationConfig.testName('SLA Policy ${faker.lorem.word()}'),
      targetHours: 24,
      appliesTo: SlaAppliesTo.both,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final model = SlaPolicyModel.fromEntity(entity);
    await remote.createSlaPolicy(model);
    IntegrationDataTracker.instance.track('sla_policies', model.id);
    return model;
  }
}
