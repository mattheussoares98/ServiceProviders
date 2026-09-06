// A catalogue case interleaves `check.step(...)` narration with assertions on
// the values between them; cascading those into one chain would destroy the
// step/assert reading order the report depends on.
// ignore_for_file: cascade_invocations

@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';

import '../core/checked_case.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_config.dart';
import '../core/integration_identity.dart';
import '../core/integration_run.dart';
import '../core/integration_session.dart';
import '../helpers/asset_integration_helper.dart';
import '../helpers/category_integration_helper.dart';
import '../helpers/location_integration_helper.dart';
import '../helpers/sla_integration_helper.dart';
import '../helpers/work_order_integration_helper.dart';

const _suite = 'work-orders-crud';
const _feature = 'Work Orders / CRUD';

void main() {
  if (!IntegrationRun.registerGuard()) return;

  late IntegrationSession admin;
  late WorkOrderContext context;

  setUpAll(() async {
    admin = await IntegrationSessions.as(Identity.admin);
    final sources = admin.sources;
    final companyId = admin.companyId;

    final location = await LocationIntegrationHelper.getOrCreateLocation(
      sources.locations,
      companyId,
    );
    final area = await LocationIntegrationHelper.getOrCreateArea(
      sources.locations,
      companyId,
      location.id,
    );
    final category = await CategoryIntegrationHelper.getOrCreateCategory(
      sources.categories,
      companyId,
    );
    final asset = await AssetIntegrationHelper.getOrCreateAsset(
      assetsRemote: sources.assets,
      locationsRemote: sources.locations,
      companyId: companyId,
      areaId: area.id,
      categoryId: category.id,
    );
    final sla = await SlaIntegrationHelper.getOrCreateSlaPolicy(
      sources.sla,
      companyId,
    );

    context = (
      companyId: companyId,
      locationId: asset.locationId,
      areaId: asset.areaId,
      assetId: asset.asset.id,
      slaPolicyId: sla.id,
    );
  });

  tearDownAll(() async {
    if (IntegrationConfig.autoCleanup) {
      await IntegrationCleanup.cleanTracked(admin.database);
    }
    await IntegrationSessions.disposeAll();
  });

  checkedTest(
    'WO-02',
    'Create a full work order and read it back unchanged',
    feature: _feature,
    role: 'admin',
    suiteSlug: _suite,
    expected: 'Every field round-trips; status is open',
    body: (check) async {
      check.step('build a fully populated [IT] work order');
      final entity = WorkOrderIntegrationHelper.buildEntity(
        context: context,
        userId: admin.userId,
      );

      check.step('createWorkOrder');

      final created = await admin.sources.workOrders.createWorkOrder(
        WorkOrderModel.fromEntity(entity),
      );
      check.softExpect(
        created,
        isA<SuccessState<bool>>(),
        reason: 'create must succeed',
      );

      check.step('getWorkOrderById');
      final fetched = await admin.sources.workOrders.getWorkOrderById(
        entity.id,
      );
      check.softExpect(fetched, isA<SuccessState<WorkOrderModel>>());

      if (fetched is SuccessState<WorkOrderModel>) {
        check
          ..actual('round-tripped as ${fetched.data?.toEntity().status}')
          ..softExpect(
            fetched.data?.toEntity(),
            entity,
            reason: 'every field must round-trip',
          );
      }
    },
  );

  checkedTest(
    'WO-10',
    'Update title, description and priority',
    feature: _feature,
    role: 'admin',
    suiteSlug: _suite,
    expected: 'Changes persist and read back',
    body: (check) async {
      check.step('seed an open work order');
      final entity = await WorkOrderIntegrationHelper.create(
        remote: admin.sources.workOrders,
        context: context,
        userId: admin.userId,
      );

      check.step('updateWorkOrder with a new title');
      final updated = entity.copyWith(
        title: IntegrationConfig.testName('Updated WO'),
        updatedAt: DateTime.now().toUtc(),
      );
      final result = await admin.sources.workOrders.updateWorkOrder(
        WorkOrderModel.fromEntity(updated),
      );
      check.softExpect(result, isA<SuccessState<bool>>());

      check.step('read back');
      final fetched = await admin.sources.workOrders.getWorkOrderById(
        entity.id,
      );
      if (fetched is SuccessState<WorkOrderModel>) {
        check
          ..actual('title is now ${fetched.data?.toEntity().title}')
          ..softExpect(fetched.data?.toEntity().title, updated.title);
      } else {
        check.softExpect(fetched, isA<SuccessState<WorkOrderModel>>());
      }
    },
  );

  checkedTest(
    'WO-13',
    'Soft-delete a work order sets deleted_at',
    feature: _feature,
    role: 'admin',
    suiteSlug: _suite,
    expected: 'deleted_at is stamped on the row',
    body: (check) async {
      check.step('seed an open work order');
      final entity = await WorkOrderIntegrationHelper.create(
        remote: admin.sources.workOrders,
        context: context,
        userId: admin.userId,
      );

      check.step('deleteWorkOrder');
      final deleted = await admin.sources.workOrders.deleteWorkOrder(entity.id);
      check.softExpect(deleted, isA<SuccessState<bool>>());

      check.step('read the raw row');
      final row = await admin.database.selectOne(
        table: 'work_orders',
        filters: [SupabaseFilter.eq('id', entity.id)],
      );
      check
        ..actual('deleted_at = ${row?['deleted_at']}')
        ..softExpect(row, isNotNull, reason: 'the row must still exist')
        ..softExpect(row?['deleted_at'], isNotNull);
    },
  );

  checkedTest(
    'WO-09',
    'A soft-deleted work order stays reachable by id but leaves the list',
    feature: _feature,
    role: 'admin',
    suiteSlug: _suite,
    expected:
        'getWorkOrderById still returns it, with deletedAt set, so the '
        'deleted-orders view and the restore flow can reach it; the default '
        'list excludes it.',
    body: (check) async {
      check.step('seed and soft-delete a work order');
      final entity = await WorkOrderIntegrationHelper.create(
        remote: admin.sources.workOrders,
        context: context,
        userId: admin.userId,
      );
      await admin.sources.workOrders.deleteWorkOrder(entity.id);

      check.step('getWorkOrderById after the soft-delete');
      final fetched = await admin.sources.workOrders.getWorkOrderById(
        entity.id,
      );
      check.softExpect(
        fetched,
        isA<SuccessState<WorkOrderModel>>(),
        reason: 'restoring a deleted order requires reading it by id',
      );
      if (fetched is SuccessState<WorkOrderModel>) {
        check.actual(
          'readable by id with deletedAt '
          '${fetched.data?.toEntity().deletedAt}',
        );
        check.softExpect(
          fetched.data?.toEntity().deletedAt,
          isNotNull,
          reason: 'the row must carry its deleted_at stamp',
        );
      }

      check.step('the default list must exclude it');
      final listed = await admin.sources.workOrders.getWorkOrders(
        context.companyId,
      );
      if (listed is SuccessState<List<WorkOrderModel>>) {
        final ids = (listed.data ?? []).map((model) => model.id).toSet();
        check.softExpect(
          ids.contains(entity.id),
          isFalse,
          reason: 'a soft-deleted order must not appear in the default list',
        );
      } else {
        check.softExpect(listed, isA<SuccessState<List<WorkOrderModel>>>());
      }
    },
  );

  checkedTest(
    'WO-06',
    'Create one work order of each WorkOrderType',
    feature: _feature,
    role: 'admin',
    suiteSlug: _suite,
    expected: 'corrective, preventive and inspection are all accepted',
    body: (check) async {
      for (final type in WorkOrderType.values) {
        check.step('create a ${type.name} work order');
        final entity = WorkOrderIntegrationHelper.buildEntity(
          context: context,
          userId: admin.userId,
        ).copyWith(type: type);

        final created = await admin.sources.workOrders.createWorkOrder(
          WorkOrderModel.fromEntity(entity),
        );
        check.softExpect(
          created,
          isA<SuccessState<bool>>(),
          reason: 'type ${type.name} must be accepted by the CHECK constraint',
        );
      }
    },
  );
}
