import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';

import '../../../testing/mocks/entity_factory.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';
import '../helpers/asset_integration_helper.dart';
import '../helpers/category_integration_helper.dart';
import '../helpers/location_integration_helper.dart';
import '../helpers/pause_reason_integration_helper.dart';
import '../helpers/sector_integration_helper.dart';
import '../helpers/sla_integration_helper.dart';
import '../supabase_integration_helper.dart';

void main() {
  late SupabaseDatabaseClient db;
  late LocationsRemoteDataSource locationsRemote;
  late CategoriesRemoteDataSource categoriesRemote;
  late AssetsRemoteDataSource assetsRemote;
  late SlaRemoteDataSource slaRemote;
  late SectorsRemoteDataSource sectorsRemote;
  late WorkOrdersRemoteDataSource workOrdersRemote;
  late PauseRemoteDataSource pauseRemote;

  late String companyId;
  late String adminUserId;
  late String locationId;
  late String areaId;
  late String categoryId;
  late String assetId;
  late String slaPolicyId;
  late String sectorId;
  late String pauseReasonId;

  setUpAll(() async {
    await SupabaseIntegrationHelper.initialize();
    db = SupabaseIntegrationHelper.databaseClient;

    locationsRemote = LocationsRemoteDataSourceImpl(database: db);
    categoriesRemote = CategoriesRemoteDataSourceImpl(database: db);
    assetsRemote = AssetsRemoteDataSourceImpl(database: db);
    slaRemote = SlaRemoteDataSourceImpl(database: db);
    sectorsRemote = SectorsRemoteDataSourceImpl(database: db);
    workOrdersRemote = WorkOrdersRemoteDataSourceImpl(database: db);
    pauseRemote = PauseRemoteDataSourceImpl(database: db);

    companyId = IntegrationConfig.companyId;
    adminUserId = await SupabaseIntegrationHelper.signInAsAdmin();

    // 1. Location & Area
    final location = await LocationIntegrationHelper.getOrCreateLocation(
      locationsRemote,
      companyId,
    );
    final area = await LocationIntegrationHelper.getOrCreateArea(
      locationsRemote,
      companyId,
      location.id,
    );

    // 2. Category
    final category = await CategoryIntegrationHelper.getOrCreateCategory(
      categoriesRemote,
      companyId,
    );
    categoryId = category.id;

    // 3. Asset (synced with area/location)
    final assetResult = await AssetIntegrationHelper.getOrCreateAsset(
      assetsRemote: assetsRemote,
      locationsRemote: locationsRemote,
      companyId: companyId,
      areaId: area.id,
      categoryId: categoryId,
    );
    assetId = assetResult.asset.id;
    areaId = assetResult.areaId;
    locationId = assetResult.locationId;

    // 4. SLA Policy
    final sla = await SlaIntegrationHelper.getOrCreateSlaPolicy(
      slaRemote,
      companyId,
    );
    slaPolicyId = sla.id;

    // 5. Sector
    final sector = await SectorIntegrationHelper.getOrCreateSector(
      sectorsRemote,
      companyId,
    );
    sectorId = sector.id;

    // 6. Pause Reason
    final pauseReason =
        await PauseReasonIntegrationHelper.getOrCreatePauseReason(
          pauseRemote: pauseRemote,
          db: db,
          companyId: companyId,
        );
    pauseReasonId = pauseReason.id;
  });

  tearDownAll(() async {
    if (IntegrationConfig.autoCleanup) {
      await IntegrationCleanup.cleanTracked(db);
    }
  });

  group('Work Orders Supabase Database End-to-End Flow', () {
    test(
      'Complete Lifecycle: Create -> Start -> Pending Pause -> Resume -> Review Pause -> Request Completion -> Approve Completion',
      () async {
        final workOrderId = faker.guid.guid();
        IntegrationDataTracker.instance.track('work_orders', workOrderId);

        // -------------------------------------------------------------
        // STEP 1: CREATE WORK ORDER
        // -------------------------------------------------------------
        final initialEntity = EntityFactory.makeWorkOrderEntity().copyWith(
          id: workOrderId,
          companyId: companyId,
          locationId: locationId,
          areaId: areaId,
          assetId: assetId,
          assignedToId: adminUserId,
          createdById: adminUserId,
          title: IntegrationConfig.testName(
            'Live Lifecycle WO ${faker.lorem.sentence()}',
          ),
          description: 'Testing live Supabase database flow',
          priority: Priority.high,
          status: WorkOrderStatus.open,
          type: WorkOrderType.corrective,
          scheduledDate: DateTime.now().toUtc().add(const Duration(days: 1)),
          estimatedDuration: 120,
          laborCost: 150,
          partsCost: 50,
          totalCost: 200,
          notes: 'Integration initial note',
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
          attachments: const [],
          slaPolicyId: slaPolicyId,
          slaDeadlineAt: DateTime.now().toUtc().add(const Duration(hours: 24)),
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

        final createResult = await workOrdersRemote.createWorkOrder(
          WorkOrderModel.fromEntity(initialEntity),
        );
        expect(
          createResult,
          isA<SuccessState<bool>>(),
          reason: 'Work order creation in Supabase should succeed',
        );

        // Verify WO exists in DB and matches initialEntity
        final fetchedWO = await workOrdersRemote.getWorkOrderById(workOrderId);
        expect(fetchedWO, isA<SuccessState<WorkOrderModel>>());
        expect(
          (fetchedWO as SuccessState<WorkOrderModel>).data?.toEntity(),
          initialEntity,
        );

        // -------------------------------------------------------------
        // STEP 2: START WORK (Transition to inProgress)
        // -------------------------------------------------------------
        final startWorkOrder = (fetchedWO.data!).copyWith(
          status: WorkOrderStatus.inProgress,
          startedAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );
        final updateStartRes = await workOrdersRemote.updateWorkOrder(
          WorkOrderModel.fromEntity(startWorkOrder),
        );
        expect(updateStartRes, isA<SuccessState<bool>>());

        final inProgressWO = await workOrdersRemote.getWorkOrderById(
          workOrderId,
        );
        expect(
          (inProgressWO as SuccessState<WorkOrderModel>).data?.toEntity(),
          startWorkOrder,
        );

        // -------------------------------------------------------------
        // STEP 3: RULE 1 - REQUEST PENDING PAUSE (Standard/Provider user)
        // -------------------------------------------------------------
        final pauseRequestId = faker.guid.guid();
        IntegrationDataTracker.instance.track(
          'work_order_pause_requests',
          pauseRequestId,
        );

        final pauseEntity = EntityFactory.makePauseRequestEntity().copyWith(
          id: pauseRequestId,
          companyId: companyId,
          workOrderId: workOrderId,
          requestedById: adminUserId,
          eventType: PauseEventType.pause,
          reasonId: pauseReasonId,
          customReason: 'Awaiting specialized parts',
          observation: 'Technician paused work',
          sectorId: sectorId,
          status: PauseRequestStatus.pending,
          pausedAt: DateTime.now().toUtc(),
          affectsSla: true,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
          annulResumedAt: true,
          annulResumedById: true,
          annulReviewedById: true,
          annulReviewObservation: true,
          annulResponsibility: true,
        );

        final pauseRes = await pauseRemote.requestPause(
          PauseRequestModel.fromEntity(pauseEntity),
        );
        expect(pauseRes, isA<SuccessState<bool>>());

        // Update Work Order to onHold (as per business rule 1)
        final pausedWO = startWorkOrder.copyWith(
          status: WorkOrderStatus.onHold,
          updatedAt: DateTime.now().toUtc(),
        );
        await workOrdersRemote.updateWorkOrder(
          WorkOrderModel.fromEntity(pausedWO),
        );

        final onHoldWO = await workOrdersRemote.getWorkOrderById(workOrderId);
        expect(
          (onHoldWO as SuccessState<WorkOrderModel>).data?.toEntity(),
          pausedWO,
        );

        final pauseRequests = await pauseRemote.getPauseRequests(workOrderId);
        final foundPause = pauseRequests.data?.firstWhere(
          (p) => p.id == pauseRequestId,
        );
        expect(foundPause?.toEntity(), pauseEntity);

        // -------------------------------------------------------------
        // STEP 4: RULE 5 - RESUME WORK (Retomar)
        // -------------------------------------------------------------
        final resumeTime = DateTime.now().toUtc();
        final cancelPauseRes = await pauseRemote.cancelPause(
          id: pauseRequestId,
          workOrderId: workOrderId,
          resumedAt: resumeTime,
          resumedById: adminUserId,
        );
        expect(cancelPauseRes, isA<SuccessState<bool>>());

        // Verify WO transitioned back to inProgress
        final resumedWO = await workOrdersRemote.getWorkOrderById(workOrderId);
        expect(
          (resumedWO as SuccessState<WorkOrderModel>).data?.status,
          WorkOrderStatus.inProgress,
        );

        final postResumeRequests = await pauseRemote.getPauseRequests(
          workOrderId,
        );
        final resumedPause = postResumeRequests.data?.firstWhere(
          (p) => p.id == pauseRequestId,
        );
        expect(resumedPause?.resumedAt, resumeTime);
        expect(resumedPause?.status, PauseRequestStatus.pending);

        // -------------------------------------------------------------
        // STEP 5: REVIEW PAUSE & DESIGNATE RESPONSIBILITY (Supervisor)
        // -------------------------------------------------------------
        final reviewPauseRes = await pauseRemote.reviewPause(
          id: pauseRequestId,
          workOrderId: workOrderId,
          status: PauseRequestStatus.approved.value,
          reviewedById: adminUserId,
          reviewObservation: 'Approved delay due to contractor logistics',
          responsibility: PauseResponsibility.contractor.value,
          reasonId: pauseReasonId,
        );
        expect(reviewPauseRes, isA<SuccessState<bool>>());

        final postReviewRequests = await pauseRemote.getPauseRequests(
          workOrderId,
        );
        final reviewedPause = postReviewRequests.data?.firstWhere(
          (p) => p.id == pauseRequestId,
        );
        expect(reviewedPause?.status, PauseRequestStatus.approved);
        expect(reviewedPause?.responsibility, PauseResponsibility.contractor);

        // WO status remains inProgress
        final afterReviewWO = await workOrdersRemote.getWorkOrderById(
          workOrderId,
        );
        expect(
          (afterReviewWO as SuccessState<WorkOrderModel>).data?.status,
          WorkOrderStatus.inProgress,
        );

        // -------------------------------------------------------------
        // STEP 6: RULE 3 - REQUEST COMPLETION (Pending Conclusion)
        // -------------------------------------------------------------
        final completionRequestId = faker.guid.guid();
        IntegrationDataTracker.instance.track(
          'work_order_pause_requests',
          completionRequestId,
        );

        final completionEntity = EntityFactory.makePauseRequestEntity()
            .copyWith(
              id: completionRequestId,
              companyId: companyId,
              workOrderId: workOrderId,
              requestedById: adminUserId,
              eventType: PauseEventType.completion,
              customReason: 'Maintenance finished successfully',
              observation: 'Ready for final inspection',
              sectorId: sectorId,
              status: PauseRequestStatus.pending,
              pausedAt: DateTime.now().toUtc(),
              affectsSla: false,
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
              annulReasonId: true,
              annulResumedAt: true,
              annulResumedById: true,
              annulReviewedById: true,
              annulReviewObservation: true,
              annulResponsibility: true,
            );

        final reqCompletionRes = await pauseRemote.requestPause(
          PauseRequestModel.fromEntity(completionEntity),
        );
        expect(reqCompletionRes, isA<SuccessState<bool>>());

        // Update WO to pendingConclusionApproval (Rule 3)
        final pendingApprovalWO = (afterReviewWO.data!).copyWith(
          status: WorkOrderStatus.pendingConclusionApproval,
          updatedAt: DateTime.now().toUtc(),
        );
        await workOrdersRemote.updateWorkOrder(
          WorkOrderModel.fromEntity(pendingApprovalWO),
        );

        final currentPendingWO = await workOrdersRemote.getWorkOrderById(
          workOrderId,
        );
        expect(
          (currentPendingWO as SuccessState<WorkOrderModel>).data?.toEntity(),
          pendingApprovalWO,
        );

        final completionRequests = await pauseRemote.getPauseRequests(
          workOrderId,
        );
        final foundCompletion = completionRequests.data?.firstWhere(
          (p) => p.id == completionRequestId,
        );
        expect(foundCompletion?.toEntity(), completionEntity);

        // -------------------------------------------------------------
        // STEP 7: REVIEW COMPLETION -> APPROVE (Rule 4 / Conclusion)
        // -------------------------------------------------------------
        final reviewCompletionRes = await pauseRemote.reviewCompletion(
          id: completionRequestId,
          workOrderId: workOrderId,
          status: PauseRequestStatus.approved.value,
          reviewedById: adminUserId,
          reviewObservation: 'Quality check passed',
          responsibility: PauseResponsibility.provider.value,
          completionReason: 'Completed as requested',
          completionSectorId: sectorId,
        );
        expect(reviewCompletionRes, isA<SuccessState<bool>>());

        // Verify WO transitioned to 'completed' with completedAt timestamp set
        final finalCompletedWO = await workOrdersRemote.getWorkOrderById(
          workOrderId,
        );
        expect(
          (finalCompletedWO as SuccessState<WorkOrderModel>).data?.status,
          WorkOrderStatus.completed,
        );
        expect(finalCompletedWO.data?.completedAt, isNotNull);
        expect(
          finalCompletedWO.data?.completionResponsibility,
          PauseResponsibility.provider,
        );
      },
    );
  });
}
