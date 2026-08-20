import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';

import '../../../testing/mocks/entity_factory.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';
import '../helpers/asset_integration_helper.dart';
import '../helpers/category_integration_helper.dart';
import '../helpers/location_integration_helper.dart';
import '../helpers/sla_integration_helper.dart';
import '../supabase_integration_helper.dart';

void main() {
  late SupabaseDatabaseClient db;
  late LocationsRemoteDataSource locationsRemote;
  late CategoriesRemoteDataSource categoriesRemote;
  late AssetsRemoteDataSource assetsRemote;
  late SlaRemoteDataSource slaRemote;
  late WorkOrdersRemoteDataSource workOrdersRemote;

  late String companyId;
  late String userId;
  late String locationId;
  late String areaId;
  late String assetId;
  late String slaPolicyId;

  setUpAll(() async {
    await SupabaseIntegrationHelper.initialize();
    db = SupabaseIntegrationHelper.databaseClient;

    locationsRemote = LocationsRemoteDataSourceImpl(database: db);
    categoriesRemote = CategoriesRemoteDataSourceImpl(database: db);
    assetsRemote = AssetsRemoteDataSourceImpl(database: db);
    slaRemote = SlaRemoteDataSourceImpl(database: db);
    workOrdersRemote = WorkOrdersRemoteDataSourceImpl(database: db);

    companyId = IntegrationConfig.companyId;
    userId = await SupabaseIntegrationHelper.signInAsAdmin();

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

    // 3. Asset (synced with area/location)
    final assetResult = await AssetIntegrationHelper.getOrCreateAsset(
      assetsRemote: assetsRemote,
      locationsRemote: locationsRemote,
      companyId: companyId,
      areaId: area.id,
      categoryId: category.id,
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
  });

  tearDownAll(() async {
    if (IntegrationConfig.autoCleanup) {
      await IntegrationCleanup.cleanTracked(db);
    }
  });

  group('Work Order CRUD Database Integration Tests', () {
    test('Create, read, update, and soft-delete a work order', () async {
      final workOrderId = faker.guid.guid();
      IntegrationDataTracker.instance.track('work_orders', workOrderId);

      final initialEntity = EntityFactory.makeWorkOrderEntity().copyWith(
        id: workOrderId,
        companyId: companyId,
        locationId: locationId,
        areaId: areaId,
        assetId: assetId,
        assignedToId: userId,
        createdById: userId,
        title: IntegrationConfig.testName('WO ${faker.lorem.sentence()}'),
        status: WorkOrderStatus.open,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        attachments: const [],
        slaPolicyId: slaPolicyId,
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

      // 1. Create
      final createResult = await workOrdersRemote.createWorkOrder(
        WorkOrderModel.fromEntity(initialEntity),
      );
      expect(createResult, isA<SuccessState<bool>>());

      // 2. Read by ID
      final getByIdResult = await workOrdersRemote.getWorkOrderById(
        workOrderId,
      );
      expect(getByIdResult, isA<SuccessState<WorkOrderModel>>());
      final createdWO = (getByIdResult as SuccessState<WorkOrderModel>).data;
      expect(createdWO?.toEntity(), initialEntity);

      // 3. Update
      final updatedTitle = IntegrationConfig.testName(
        'Updated WO ${faker.lorem.sentence()}',
      );
      final updatedEntity = EntityFactory.makeWorkOrderEntity().copyWith(
        id: workOrderId,
        companyId: companyId,
        locationId: locationId,
        areaId: areaId,
        assetId: assetId,
        assignedToId: userId,
        createdById: userId,
        title: updatedTitle,
        status: WorkOrderStatus.open,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        attachments: const [],
        slaPolicyId: slaPolicyId,
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
      final updateResult = await workOrdersRemote.updateWorkOrder(
        WorkOrderModel.fromEntity(updatedEntity),
      );
      expect(updateResult, isA<SuccessState<bool>>());

      final getAfterUpdate = await workOrdersRemote.getWorkOrderById(
        workOrderId,
      );
      final updatedWO = (getAfterUpdate as SuccessState<WorkOrderModel>).data;
      expect(updatedWO?.toEntity(), updatedEntity);

      // 4. Soft Delete
      if (IntegrationConfig.autoCleanup) {
        final deleteResult = await workOrdersRemote.deleteWorkOrder(workOrderId);
        expect(deleteResult, isA<SuccessState<bool>>());

        // 5. Verify excluded from getWorkOrderById
        final postDeleteFetch = await workOrdersRemote.getWorkOrderById(
          workOrderId,
        );
        expect(postDeleteFetch, isA<FailureState<WorkOrderModel>>());

        // 6. Verify deleted_at is set in the database
        final rawRow = await db.selectOne(
          table: 'work_orders',
          filters: [SupabaseFilter.eq('id', workOrderId)],
        );
        expect(rawRow, isNotNull);
        expect(rawRow!['deleted_at'], isNotNull);
      }
    });
  });
}
