@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';

import '../core/checked_case.dart';
import '../core/integration_identity.dart';
import '../core/integration_run.dart';
import '../core/integration_session.dart';

void main() {
  if (!IntegrationRun.registerGuard()) return;
  tearDownAll(IntegrationSessions.disposeAll);

  for (final identity in Identity.values) {
    checkedTest(
      'READY-${identity.name}',
      'ordinary ${identity.name} authenticates with the intended membership',
      feature: 'Readiness',
      suiteSlug: 'readiness',
      role: identity.name,
      body: (check) async {
        final session = await IntegrationSessions.as(identity);
        expect(
          await session.database.rpc(functionName: 'is_super_admin'),
          isFalse,
        );
        if (identity == Identity.provider) {
          final admin = await IntegrationSessions.as(Identity.admin);
          final providerCompany = await admin.database.selectOne(
            table: 'service_provider_companies',
            columns: 'company_id',
            filters: [
              SupabaseFilter.eq('id', session.serviceProviderCompanyId!),
            ],
          );
          expect(providerCompany?['company_id'], admin.companyId);
        }
        check.actual('Authenticated; ordinary role and tenant verified');
      },
    );
  }

  for (final permission in [
    'work_orders.read',
    'work_orders.update',
    'work_orders.manage_pending_requests',
  ]) {
    checkedTest(
      'READY-supervisor-$permission',
      'supervisor has the application permission $permission',
      feature: 'Readiness',
      suiteSlug: 'readiness',
      role: 'supervisor',
      body: (check) async {
        final supervisor = await IntegrationSessions.as(Identity.supervisor);
        final actual = await supervisor.database.rpc(
          functionName: 'has_permission',
          params: {'permission_key': permission},
        );
        check.actual('$permission=$actual');
        expect(
          actual,
          isTrue,
          reason: 'Provisioning must match application permission keys',
        );
      },
    );
  }

  for (final permission in [
    'work_orders.manage_pending_requests',
    'work_orders.reassign',
    'work_orders.manage_financials',
    'users.update',
  ]) {
    checkedTest(
      'READY-technician-$permission',
      'technician cannot exercise restricted action $permission',
      feature: 'Readiness',
      suiteSlug: 'readiness',
      role: 'technician',
      body: (check) async {
        final technician = await IntegrationSessions.as(Identity.technician);
        final actual = await technician.database.rpc(
          functionName: 'has_permission',
          params: {'permission_key': permission},
        );
        check.actual('$permission=$actual');
        expect(actual, isFalse);
      },
    );
  }

  checkedTest(
    'READY-independent',
    'fresh sessions preserve distinct actors and tenants',
    feature: 'Readiness',
    suiteSlug: 'readiness',
    body: (check) async {
      final sessions = <IntegrationSession>[];
      try {
        for (final identity in Identity.values) {
          sessions.add(await IntegrationSessions.fresh(identity));
        }
        expect(sessions.map((session) => session.userId).toSet(), hasLength(5));
        expect(sessions.last.companyId, isNot(sessions.first.companyId));
        check.actual(
          'Five distinct ordinary accounts; company A differs from B',
        );
      } finally {
        for (final session in sessions) {
          await session.client.auth.signOut();
          await session.client.dispose();
        }
      }
    },
  );
}
