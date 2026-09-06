// A catalogue case interleaves `check.step(...)` narration with assertions on
// the values between them; cascading those into one chain would destroy the
// step/assert reading order the report depends on.
// ignore_for_file: cascade_invocations

@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/permission_group_model.dart';

import '../core/checked_case.dart';
import '../core/integration_cleanup.dart';
import '../core/integration_config.dart';
import '../core/integration_error.dart';
import '../core/integration_identity.dart';
import '../core/integration_permission_fixture.dart';
import '../core/integration_run.dart';
import '../core/integration_session.dart';
import '../core/rls_matchers.dart';
import '../helpers/asset_integration_helper.dart';
import '../helpers/category_integration_helper.dart';
import '../helpers/location_integration_helper.dart';
import '../helpers/sla_integration_helper.dart';
import '../helpers/work_order_integration_helper.dart';

const _suite = 'work-order-permissions';
const _feature = 'Work Orders / Permissions & RLS';

void main() {
  if (!IntegrationRun.registerGuard()) return;

  late IntegrationSession admin;
  late IntegrationSession tech;
  late WorkOrderContext context;

  setUpAll(() async {
    admin = await IntegrationSessions.as(Identity.admin);
    tech = await IntegrationSessions.as(Identity.technician);

    // Repair anything a previous run was killed in the middle of.
    await PermissionFixture.recoverLedger(admin.database);

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
    'WOL-29',
    'update_scope=assigned lets the technician update a work order assigned to them',
    feature: _feature,
    role: 'technician (scoped)',
    suiteSlug: _suite,
    expected: 'The update is applied',
    body: (check) async {
      check.step('admin seeds a work order assigned to the technician');
      final entity = await WorkOrderIntegrationHelper.create(
        remote: admin.sources.workOrders,
        context: context,
        userId: tech.userId,
      );

      check.step('technician is scoped to update_scope=assigned');
      await PermissionFixture.applyScopedTechnician(tech);

      check.step('technician updates the title');
      final newTitle = IntegrationConfig.testName('Scoped update');
      final updated = await tech.database.update(
        table: 'work_orders',
        values: {'title': newTitle},
        filters: [SupabaseFilter.eq('id', entity.id)],
      );

      check.actual('update returned ${updated.length} row(s)');
      check.softExpect(
        updated,
        isNotEmpty,
        reason: 'an assigned work order must be updatable under scope=assigned',
      );
    },
  );

  checkedTest(
    'WOL-30',
    'update_scope=assigned denies updating a work order assigned to someone else',
    feature: _feature,
    role: 'technician (scoped)',
    suiteSlug: _suite,
    expected: 'Zero rows updated, and the title is unchanged',
    body: (check) async {
      check.step('admin seeds a work order assigned to the admin');
      final entity = await WorkOrderIntegrationHelper.create(
        remote: admin.sources.workOrders,
        context: context,
        userId: admin.userId,
      );

      check.step('technician is scoped to update_scope=assigned');
      await PermissionFixture.applyScopedTechnician(tech);

      check.step('technician attempts the update');
      await expectRlsDeniesUpdate(
        tech.database,
        table: 'work_orders',
        id: entity.id,
        values: {'title': IntegrationConfig.testName('Should not apply')},
      );

      check.step('confirm the row is untouched');
      await expectUnchanged(
        admin.database,
        table: 'work_orders',
        id: entity.id,
        column: 'title',
        expected: entity.title,
      );
      check.actual('title still ${entity.title}');
    },
  );

  checkedTest(
    'WOL-32',
    'update_scope=none denies every work order update',
    feature: _feature,
    role: 'technician (scoped)',
    suiteSlug: _suite,
    expected: 'Zero rows updated even for an assigned work order',
    body: (check) async {
      check.step('admin seeds a work order assigned to the technician');
      final entity = await WorkOrderIntegrationHelper.create(
        remote: admin.sources.workOrders,
        context: context,
        userId: tech.userId,
      );

      check.step('technician is scoped to update_scope=none');
      await PermissionFixture.applyScopedTechnician(
        tech,
        updateScope: 'none',
      );

      check.step('technician attempts to update their own assigned order');
      await expectRlsDeniesUpdate(
        tech.database,
        table: 'work_orders',
        id: entity.id,
        values: {'title': IntegrationConfig.testName('Should not apply')},
      );

      await expectUnchanged(
        admin.database,
        table: 'work_orders',
        id: entity.id,
        column: 'title',
        expected: entity.title,
      );
      check.actual('scope=none blocked the update on an assigned order');
    },
  );

  checkedTest(
    'WOL-33',
    'read_scope=assigned filters the list server-side, not in the client',
    feature: _feature,
    role: 'technician (scoped)',
    suiteSlug: _suite,
    expected: 'A work order assigned to someone else is absent from the list',
    body: (check) async {
      check.step('admin seeds one order for the technician and one for itself');
      final mine = await WorkOrderIntegrationHelper.create(
        remote: admin.sources.workOrders,
        context: context,
        userId: tech.userId,
      );
      final theirs = await WorkOrderIntegrationHelper.create(
        remote: admin.sources.workOrders,
        context: context,
        userId: admin.userId,
      );

      check.step('technician is scoped to read_scope=assigned');
      await PermissionFixture.applyScopedTechnician(tech);

      check.step('technician reads the raw table');
      final rows = await tech.database.selectList(
        table: 'work_orders',
        columns: 'id, assigned_to_id',
        filters: [
          SupabaseFilter.eq('company_id', context.companyId),
          SupabaseFilter.isFilter('deleted_at', null),
        ],
        limit: 500,
      );
      final ids = rows.map((row) => row['id']).toSet();

      check.actual(
        'technician sees ${rows.length} rows; own=${ids.contains(mine.id)} '
        'foreign=${ids.contains(theirs.id)}',
      );
      check.softExpect(
        ids.contains(mine.id),
        isTrue,
        reason: 'the assigned order must be visible',
      );
      check.softExpect(
        ids.contains(theirs.id),
        isFalse,
        reason: 'an order assigned to someone else must be hidden by RLS',
      );
    },
  );

  checkedTest(
    'RLS-04',
    'has_permission() must deny a permission whose key is present but false',
    feature: _feature,
    role: 'technician (scoped)',
    suiteSlug: _suite,
    expected:
        'Denied. Predicted to FAIL (F1): has_permission ends in '
        '`v_permissions ? key`, and on a JSONB object `?` tests key existence, '
        'so "key": false grants access.',
    body: (check) async {
      check.step('grant the technician a group where every key is false');
      await PermissionFixture.apply(
        session: tech,
        label: 'false-keys',
        permissions: {
          'work_orders.read': true,
          'work_orders.read_scope': 'all',
          'locations.create': false,
        },
      );

      check.step('attempt an insert gated by locations.create');
      var denied = false;
      String? observed;
      try {
        final rows = await tech.database.insert(
          table: 'locations',
          values: {
            'company_id': context.companyId,
            'name': IntegrationConfig.testName('F1 probe'),
            'is_active': true,
          },
        );
        observed = 'insert succeeded (${rows.length} row)';
      } on Object catch (error) {
        final parsed = IntegrationError.from(error).code;
        denied = parsed == PgCode.rlsDenied;
        observed = 'insert raised ${parsed ?? error.runtimeType}';
      }

      check.actual(observed);
      if (!denied) {
        check.note(
          'F1 reproduced: "locations.create": false did not deny the insert. '
          'Any group in production that spells a permission out as false is '
          'granting it.',
        );
      }
      check.softExpect(
        denied,
        isTrue,
        reason: '"locations.create": false must deny, not grant',
      );
    },
  );

  checkedTest(
    'RLS-10',
    'PermissionGroupModel round-trip must preserve the admin wildcard',
    feature: _feature,
    role: 'admin',
    layer: 'model',
    suiteSlug: _suite,
    expected:
        'The wildcard survives. Predicted to FAIL (F4): toJson() rebuilds the '
        'JSONB from Map<ResourceType, Set<PermissionAction>>, which has no '
        'representation for "*" or for the commented-out resource families.',
    body: (check) async {
      check.step('read every real permission group in this company');
      final rows = await admin.database.selectList(
        table: 'permission_groups',
        filters: [
          SupabaseFilter.eq('company_id', admin.companyId),
          SupabaseFilter.isFilter('deleted_at', null),
        ],
      );
      final realGroups = rows
          .where((row) => !(row['name'] as String? ?? '').startsWith('[IT] '))
          .toList();

      if (realGroups.isEmpty) {
        check.skip('this company has no permission groups to round-trip');
        return;
      }

      check.step('round-trip each one through PermissionGroupModel');
      var anyLost = false;
      for (final group in realGroups) {
        final before = (group['permissions'] as Map?) ?? const {};
        final after =
            (PermissionGroupModel.fromJson(group).toJson()['permissions']
                as Map?) ??
            const {};

        final lost = before.keys
            .where((key) => !after.containsKey(key))
            .cast<String>()
            .toList();
        if (lost.isEmpty) continue;

        anyLost = true;
        check.note(
          'Group "${group['name']}" loses ${lost.length} key(s) on a '
          'read-modify-write through the model: ${lost.join(', ')}.',
        );
      }

      check.actual(
        anyLost
            ? 'at least one real group loses permissions through the model'
            : 'every real group round-trips losslessly',
      );

      if (anyLost) {
        check.note(
          'F4 reproduced. The dropped keys are those with no ResourceType: '
          '"*" plus checklists / reports / maintenance_plans, which are '
          'commented out in ResourceType. Saving any affected group through '
          'the app silently strips them.',
        );
      }

      check.softExpect(
        anyLost,
        isFalse,
        reason: 'a read-modify-write through the model must be lossless',
      );
    },
  );

  checkedTest(
    'WOL-12',
    'A technician without the reassign sub-action cannot reassign a work order',
    feature: _feature,
    role: 'technician (scoped)',
    suiteSlug: _suite,
    expected: 'assigned_to_id is unchanged',
    body: (check) async {
      check.step('admin seeds an order assigned to the technician');
      final entity = await WorkOrderIntegrationHelper.create(
        remote: admin.sources.workOrders,
        context: context,
        userId: tech.userId,
      );

      check.step('technician gets update_scope=assigned but no reassign');
      await PermissionFixture.applyScopedTechnician(tech);

      check.step('technician attempts to reassign the order to the admin');
      await expectRlsDeniesUpdate(
        tech.database,
        table: 'work_orders',
        id: entity.id,
        values: {'assigned_to_id': admin.userId},
      );

      check.step('confirm the assignee is unchanged');
      final row = await admin.database.selectOne(
        table: 'work_orders',
        columns: 'id, assigned_to_id',
        filters: [SupabaseFilter.eq('id', entity.id)],
      );
      check.actual('assigned_to_id is still ${row?['assigned_to_id']}');
      check.softExpect(
        row?['assigned_to_id'],
        tech.userId,
        reason: 'reassignment must require the reassign sub-action',
      );
    },
  );
}
