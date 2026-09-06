import 'dart:convert';
import 'dart:io';

import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';

import 'integration_data_tracker.dart';
import 'integration_report.dart';

/// How a table's test rows can be removed, if at all.
enum CleanupStrategy {
  /// Stamp `deleted_at`. The normal path.
  softDelete,

  /// A real `DELETE`. Only where a unique index would otherwise block re-runs.
  hardDelete,

  /// No `deleted_at` and hard delete blocked by a trigger — the best available
  /// outcome is `is_active = false`.
  deactivate,

  /// Neither removable nor deactivatable. Reported, never pretended away.
  unreachable,
}

/// What a cleanup pass actually achieved, per table.
class CleanupOutcome {
  CleanupOutcome();

  final Map<String, int> softDeleted = {};
  final Map<String, int> hardDeleted = {};
  final Map<String, int> deactivated = {};
  final Map<String, int> unreachable = {};
  final List<String> errors = [];

  bool get isClean => unreachable.isEmpty && errors.isEmpty;

  Map<String, Object?> toJson() => {
    'softDeleted': softDeleted,
    'hardDeleted': hardDeleted,
    'deactivated': deactivated,
    'unreachable': unreachable,
    'errors': errors,
  };

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());
}

/// Removes the rows an integration run created from the live project.
///
/// Four strategies rather than one, because the schema genuinely offers four
/// different guarantees — and where it offers none, that is reported rather
/// than quietly dropped from the tracker.
class IntegrationCleanup {
  const IntegrationCleanup._();

  /// Children before parents: a soft-deleted parent whose children are still
  /// live trips the `check_*_before_delete` guards.
  static const List<({String table, String? nameColumn, CleanupStrategy how})>
  plan = [
    // Work order satellites.
    (
      table: 'work_order_change_requests',
      nameColumn: null,
      how: CleanupStrategy.softDelete,
    ),
    (
      table: 'work_order_observations',
      nameColumn: null,
      how: CleanupStrategy.softDelete,
    ),
    (table: 'tasks', nameColumn: 'title', how: CleanupStrategy.softDelete),
    (table: 'attachments', nameColumn: null, how: CleanupStrategy.softDelete),
    (
      table: 'work_order_pause_requests',
      nameColumn: null,
      how: CleanupStrategy.softDelete,
    ),
    (table: 'work_orders', nameColumn: 'title', how: CleanupStrategy.softDelete),
    // Checklists. Items do NOT cascade from their template, and their name
    // column is `label`, not `name`.
    (
      table: 'checklist_items',
      nameColumn: 'label',
      how: CleanupStrategy.softDelete,
    ),
    (
      table: 'checklist_templates',
      nameColumn: 'name',
      how: CleanupStrategy.softDelete,
    ),
    // Registries.
    (table: 'assets', nameColumn: 'name', how: CleanupStrategy.softDelete),
    (table: 'areas', nameColumn: 'name', how: CleanupStrategy.softDelete),
    (table: 'locations', nameColumn: 'name', how: CleanupStrategy.softDelete),
    (table: 'categories', nameColumn: 'name', how: CleanupStrategy.softDelete),
    (table: 'sectors', nameColumn: 'name', how: CleanupStrategy.softDelete),
    (table: 'sla_policies', nameColumn: 'name', how: CleanupStrategy.softDelete),
    (
      table: 'pause_reasons',
      nameColumn: 'name',
      how: CleanupStrategy.softDelete,
    ),
    (
      table: 'maintenance_plans',
      nameColumn: 'name',
      how: CleanupStrategy.softDelete,
    ),
    // Service providers. Profiles have no `deleted_at` and a hard delete is
    // blocked by a trigger, so deactivation is the ceiling. Invitations MUST be
    // hard-deleted: a unique index on (email, sp_company_id) blocks a re-run.
    (
      table: 'service_provider_invitations',
      nameColumn: null,
      how: CleanupStrategy.hardDelete,
    ),
    (
      table: 'service_provider_profiles',
      nameColumn: 'name',
      how: CleanupStrategy.deactivate,
    ),
    (
      table: 'service_provider_companies',
      nameColumn: 'name',
      how: CleanupStrategy.softDelete,
    ),
    // Permission groups created by PermissionFixture.
    (
      table: 'permission_groups',
      nameColumn: 'name',
      how: CleanupStrategy.softDelete,
    ),
    // Append-only logs.
    (table: 'audit_logs', nameColumn: null, how: CleanupStrategy.unreachable),
    (table: 'access_logs', nameColumn: null, how: CleanupStrategy.unreachable),
    (
      table: 'work_order_history',
      nameColumn: null,
      how: CleanupStrategy.unreachable,
    ),
    (table: 'sync_errors', nameColumn: null, how: CleanupStrategy.unreachable),
  ];

  /// Cleans the ids this run tracked.
  static Future<CleanupOutcome> cleanTracked(SupabaseDatabaseClient db) async {
    final outcome = CleanupOutcome();
    final tracker = IntegrationDataTracker.instance;
    final deletedAt = DateTime.now().toIsoUtcString();

    for (final entry in plan) {
      final ids = tracker.getIds(entry.table);
      if (ids.isEmpty) continue;

      if (entry.how == CleanupStrategy.unreachable) {
        outcome.unreachable[entry.table] = ids.length;
        continue;
      }

      for (final id in ids) {
        try {
          await _apply(db, entry.table, entry.how, id, deletedAt, outcome);
        } on Object catch (error) {
          outcome.errors.add('${entry.table}/$id: $error');
        }
      }
    }

    tracker.clear();
    _writeLedger(outcome);
    return outcome;
  }

  /// Cleans every `[IT]`-prefixed row in [companyId], including leftovers from
  /// earlier runs that crashed before their teardown.
  static Future<CleanupOutcome> cleanAll(
    SupabaseDatabaseClient db,
    String companyId,
  ) async {
    final outcome = await cleanTracked(db);
    final deletedAt = DateTime.now().toIsoUtcString();

    for (final entry in plan) {
      final nameColumn = entry.nameColumn;
      if (nameColumn == null || entry.how == CleanupStrategy.unreachable) {
        continue;
      }

      try {
        final rows = await db.selectList(
          table: entry.table,
          columns: 'id',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            if (entry.how == CleanupStrategy.softDelete)
              SupabaseFilter.isFilter('deleted_at', null),
            SupabaseFilter.ilike(nameColumn, '[IT] %'),
          ],
        );
        for (final row in rows) {
          final id = row['id'] as String?;
          if (id == null) continue;
          await _apply(db, entry.table, entry.how, id, deletedAt, outcome);
        }
      } on Object catch (error) {
        // A table this identity cannot read is not a cleanup failure worth
        // aborting the teardown for, but it is worth reporting.
        outcome.errors.add('${entry.table} sweep: $error');
      }
    }

    _writeLedger(outcome);
    return outcome;
  }

  static Future<void> _apply(
    SupabaseDatabaseClient db,
    String table,
    CleanupStrategy how,
    String id,
    String deletedAt,
    CleanupOutcome outcome,
  ) async {
    switch (how) {
      case CleanupStrategy.softDelete:
        await db.update(
          table: table,
          values: {'deleted_at': deletedAt},
          filters: [SupabaseFilter.eq('id', id)],
        );
        outcome.softDeleted[table] = (outcome.softDeleted[table] ?? 0) + 1;
      case CleanupStrategy.hardDelete:
        await db.delete(table: table, filters: [SupabaseFilter.eq('id', id)]);
        outcome.hardDeleted[table] = (outcome.hardDeleted[table] ?? 0) + 1;
      case CleanupStrategy.deactivate:
        await db.update(
          table: table,
          values: {'is_active': false},
          filters: [SupabaseFilter.eq('id', id)],
        );
        outcome.deactivated[table] = (outcome.deactivated[table] ?? 0) + 1;
      case CleanupStrategy.unreachable:
        outcome.unreachable[table] = (outcome.unreachable[table] ?? 0) + 1;
    }
  }

  /// Records what cleanup achieved next to the case reports, so the run's
  /// "Manual cleanup required" section reflects reality rather than intent.
  static void _writeLedger(CleanupOutcome outcome) {
    try {
      Directory(IntegrationReport.directory).createSync(recursive: true);
      File('${IntegrationReport.directory}/cleanup-$pid.json')
          .writeAsStringSync(outcome.toString(), flush: true);
    } on Object {
      // Never let a bookkeeping failure mask the test result.
    }
  }
}
