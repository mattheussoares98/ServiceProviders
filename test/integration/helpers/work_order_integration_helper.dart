import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';

import '../../../testing/mocks/entity_factory.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';

/// The registry ids every work order needs, resolved once per suite.
typedef WorkOrderContext = ({
  String companyId,
  String locationId,
  String areaId,
  String assetId,
  String slaPolicyId,
});

/// Builds work orders for the catalogue cases.
///
/// Every case that needs an order of its own creates one here rather than
/// sharing a fixture, so a failure in one case cannot cascade into the next.
class WorkOrderIntegrationHelper {
  const WorkOrderIntegrationHelper._();

  /// A fully populated, `[IT]`-tagged work order entity in [status].
  ///
  /// The `annul*` flags strip the fields `EntityFactory` fills with random
  /// values that the server owns (durations, completion metadata, provider
  /// authorship) — leaving them set would assert against values no lifecycle
  /// produced.
  static WorkOrderEntity buildEntity({
    required WorkOrderContext context,
    required String userId,
    WorkOrderStatus status = WorkOrderStatus.open,
    String? id,
    String? title,
  }) {
    final now = DateTime.now().toUtc();
    return EntityFactory.makeWorkOrderEntity().copyWith(
      id: id ?? faker.guid.guid(),
      companyId: context.companyId,
      locationId: context.locationId,
      areaId: context.areaId,
      assetId: context.assetId,
      slaPolicyId: context.slaPolicyId,
      assignedToId: userId,
      createdById: userId,
      title: title ?? IntegrationConfig.testName('WO ${faker.lorem.word()}'),
      status: status,
      createdAt: now,
      updatedAt: now,
      attachments: const [],
      annulServiceProviderCompanyId: true,
      annulProviderProfileId: true,
      annulMaintenancePlanId: true,
      annulStartedAt: true,
      annulCompletedAt: true,
      annulActualDuration: true,
      annulNetActiveDuration: true,
      annulCompletionReason: true,
      annulCompletionResponsibility: true,
      annulCompletionSectorId: true,
    );
  }

  /// Creates a work order remotely and registers it for cleanup.
  ///
  /// Tracking happens *before* the insert: a create that fails partway still
  /// needs the id in the cleanup ledger.
  static Future<WorkOrderEntity> create({
    required WorkOrdersRemoteDataSource remote,
    required WorkOrderContext context,
    required String userId,
    WorkOrderStatus status = WorkOrderStatus.open,
    String? title,
  }) async {
    final entity = buildEntity(
      context: context,
      userId: userId,
      status: status,
      title: title,
    );
    IntegrationDataTracker.instance.track('work_orders', entity.id);
    await remote.createWorkOrder(WorkOrderModel.fromEntity(entity));
    return entity;
  }
}
