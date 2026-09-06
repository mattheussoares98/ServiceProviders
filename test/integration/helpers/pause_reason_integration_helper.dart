import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pauses/pause_reason_model.dart';

import '../../../testing/mocks/factories/work_order_factory.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';

/// Helper for getting or creating Pause Reasons in integration tests.
class PauseReasonIntegrationHelper {
  const PauseReasonIntegrationHelper._();

  /// Returns an existing Pause Reason or creates a new `[IT]`-prefixed one.
  static Future<PauseReasonModel> getOrCreatePauseReason({
    required PauseRemoteDataSource pauseRemote,
    required SupabaseDatabaseClient db,
    required String companyId,
  }) async {
    if (IntegrationConfig.useExistingData) {
      final result = await pauseRemote.getPauseReasons(companyId);
      if (result is SuccessState<List<PauseReasonModel>> &&
          (result.data?.isNotEmpty ?? false)) {
        return result.data!.first;
      }
    }

    final entity = WorkOrderFactory.makePauseReasonEntity().copyWith(
      id: faker.guid.guid(),
      companyId: companyId,
      name: IntegrationConfig.testName('Pause Reason ${faker.lorem.word()}'),
      isActive: true,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final model = PauseReasonModel.fromEntity(entity);
    await db.insert(table: 'pause_reasons', values: model.toJson());
    IntegrationDataTracker.instance.track('pause_reasons', model.id);
    return model;
  }
}
