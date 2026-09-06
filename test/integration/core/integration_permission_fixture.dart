import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

import 'integration_config.dart';
import 'integration_data_tracker.dart';
import 'integration_report.dart';
import 'integration_session.dart';

/// Temporarily grants an identity a different permission set.
///
/// The fixture never edits the company's shared `Técnico` / `Supervisor` groups:
/// that would be a live permission change for real users of a production tenant
/// for the duration of the run. It creates a private `[IT]` group, repoints one
/// profile at it, and restores the original `permission_group_id` afterwards.
///
/// Restore is registered with `addTearDown` **inside** [apply], so it runs on a
/// thrown exception, a failed expectation and a timeout alike. A ledger line is
/// written *before* each mutation, so a run killed between the write and the
/// restore can be repaired by [recoverLedger] on the next start.
class PermissionFixture {
  const PermissionFixture._();

  static String get _ledgerPath =>
      '${IntegrationReport.directory}/permission_ledger.jsonl';

  /// Grants [permissions] to [session]'s profile for the rest of the test.
  ///
  /// [permissions] is written as **raw JSONB**, never through
  /// `PermissionGroupModel`: that model rebuilds the object from
  /// `Map<ResourceType, Set<PermissionAction>>`, and `ResourceType` has
  /// `checklists`, `reports` and `maintenance_plans` commented out, so a
  /// read-modify-write through it silently drops `"*": true` and those three
  /// resource families (finding F4).
  ///
  /// Note on revoking: since the F1 fix
  /// (`20260906120000_fix_has_permission_object_format.sql`) `has_permission()`
  /// reads the *value*, so `"x.y": false` denies. Omitting the key denies too;
  /// both shapes are exercised by `RLS-04`.
  static Future<String> apply({
    required IntegrationSession session,
    required MapDynamic permissions,
    String label = 'fixture',
  }) => applyRaw(session: session, permissions: permissions, label: label);

  /// The JSONB-typed entry point behind [apply].
  ///
  /// [permissions] is written verbatim, so it may be the flat object the app
  /// writes today **or** the legacy array (`["work_orders.read"]`) that
  /// `has_permission()` still supports — see [applyLegacyArray] and `RLS-09`.
  static Future<String> applyRaw({
    required IntegrationSession session,
    required Object permissions,
    String label = 'fixture',
  }) async {
    final db = session.database;

    final profile = await db.selectOne(
      table: 'user_profiles',
      columns: 'id, name, permission_group_id, is_admin',
      filters: [SupabaseFilter.eq('id', session.userId)],
    );
    if (profile == null) {
      throw StateError('No user_profiles row for ${session.email}');
    }

    final originalGroupId = profile['permission_group_id'] as String?;

    _assertNotDemotingAdmin(session, profile);

    final groupName = IntegrationConfig.testName('Group $label');
    final inserted = await db.insert(
      table: 'permission_groups',
      values: {
        'company_id': session.companyId,
        'name': groupName,
        'permissions': permissions,
        'is_default': false,
      },
    );
    final groupId = inserted.first['id'] as String;
    IntegrationDataTracker.instance.track('permission_groups', groupId);

    _appendLedger({
      'at': DateTime.now().toIso8601String(),
      'label': label,
      'profileId': session.userId,
      'email': session.email,
      'originalGroupId': originalGroupId,
      'fixtureGroupId': groupId,
    });

    await db.update(
      table: 'user_profiles',
      values: {'permission_group_id': groupId},
      filters: [SupabaseFilter.eq('id', session.userId)],
    );

    addTearDown(() async {
      await restore(
        db: db,
        profileId: session.userId,
        originalGroupId: originalGroupId,
      );
    });

    return groupId;
  }

  /// Convenience for the supervisor identity: the technician profile granted
  /// `work_orders.manage_pending_requests` for the duration of one case.
  static Future<String> applySupervisor(IntegrationSession session) => apply(
    session: session,
    label: 'supervisor',
    permissions: {
      'work_orders.read': true,
      'work_orders.update': true,
      'work_orders.create': true,
      'work_orders.manage_pending_requests': true,
      'work_orders.read_scope': 'all',
      'work_orders.update_scope': 'all',
    },
  );

  /// Grants [keys] in the **legacy array** permission format.
  ///
  /// Groups seeded before `20260717000000_two_tier_permissions.sql` still hold
  /// this shape, and `has_permission()` keeps a branch for it where membership
  /// alone is the grant. `RLS-09` pins that branch against the object one.
  static Future<String> applyLegacyArray(
    IntegrationSession session,
    List<String> keys, {
    String label = 'legacy-array',
  }) => applyRaw(session: session, permissions: keys, label: label);

  /// Convenience for the scope cases. `work_orders` updates are not gated by a
  /// boolean at all, so the scope keys are what actually vary.
  static Future<String> applyScopedTechnician(
    IntegrationSession session, {
    String readScope = 'assigned',
    String updateScope = 'assigned',
  }) => apply(
    session: session,
    label: 'scope-$readScope-$updateScope',
    permissions: {
      'assets.read': true,
      'work_orders.read': true,
      'work_orders.read_scope': readScope,
      'work_orders.update_scope': updateScope,
    },
  );

  /// Puts [profileId] back on its original group.
  static Future<void> restore({
    required SupabaseDatabaseClient db,
    required String profileId,
    required String? originalGroupId,
  }) async {
    await db.update(
      table: 'user_profiles',
      values: {'permission_group_id': originalGroupId},
      filters: [SupabaseFilter.eq('id', profileId)],
    );
  }

  /// Re-applies any ledger entry a previous run left unrestored.
  ///
  /// Called from a suite's `setUpAll` so an interrupted run cannot leave a real
  /// production profile pointing at a throwaway `[IT]` group.
  static Future<void> recoverLedger(SupabaseDatabaseClient db) async {
    final file = File(_ledgerPath);
    if (!file.existsSync()) return;

    for (final line in file.readAsLinesSync()) {
      if (line.trim().isEmpty) continue;
      try {
        final entry = jsonDecode(line) as MapDynamic;
        await restore(
          db: db,
          profileId: entry['profileId'] as String,
          originalGroupId: entry['originalGroupId'] as String?,
        );
      } on Object {
        // Recovery is best-effort; a bad line must not block the run.
      }
    }
    file.deleteSync();
  }

  /// `tr_sync_user_profile_admin_status` clears `is_admin` for any group whose
  /// name is not `administrador`, so pointing the admin identity at a fixture
  /// group would silently strip its admin rights for the rest of the run — and
  /// the restore would not bring them back.
  static void _assertNotDemotingAdmin(
    IntegrationSession session,
    MapDynamic profile,
  ) {
    if (profile['is_admin'] == true) {
      throw StateError(
        'Refusing to repoint ${session.email}: it is a company admin, and '
        'tr_sync_user_profile_admin_status would clear is_admin when the '
        'fixture group is applied. Apply fixtures to the technician identity.',
      );
    }
  }

  static void _appendLedger(Map<String, Object?> entry) {
    Directory(IntegrationReport.directory).createSync(recursive: true);
    File(_ledgerPath).writeAsStringSync(
      '${jsonEncode(entry)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}
