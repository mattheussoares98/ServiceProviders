import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_model.dart';

import '../../../testing/mocks/factories/system_factory.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';

/// Helper for getting or creating Sectors in integration tests.
class SectorIntegrationHelper {
  const SectorIntegrationHelper._();

  /// Returns an existing Sector or creates a new `[IT]`-prefixed one.
  static Future<SectorModel> getOrCreateSector(
    SectorsRemoteDataSource remote,
    String companyId,
  ) async {
    if (IntegrationConfig.useExistingData) {
      final result = await remote.getSectors(companyId);
      if (result is SuccessState<List<SectorModel>> &&
          (result.data?.isNotEmpty ?? false)) {
        return result.data!.first;
      }
    }

    final entity = SystemFactory.makeSectorEntity().copyWith(
      id: faker.guid.guid(),
      companyId: companyId,
      name: IntegrationConfig.testName('Sector ${faker.lorem.word()}'),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final model = SectorModel.fromEntity(entity);
    final result = await remote.createSector(model);
    final created = (result as SuccessState<SectorModel>).data!;
    IntegrationDataTracker.instance.track('sectors', created.id);
    return created;
  }
}
