import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';

import 'integration_data_tracker.dart';

/// Cleans up integration test data by soft-deleting rows created during tests.
///
/// Uses two strategies:
/// 1. Tracked IDs from [IntegrationDataTracker] — precise, per-run.
/// 2. `[IT]` prefix name matching — catches leftovers from failed runs.
class IntegrationCleanup {
  const IntegrationCleanup._();

  /// Tables with soft-delete in reverse dependency order for safe cleanup.
  static const _tablesWithNameColumn = {
    'work_orders': 'title',
    'assets': 'name',
    'areas': 'name',
    'locations': 'name',
    'categories': 'name',
    'sectors': 'name',
    'sla_policies': 'name',
    'pause_reasons': 'name',
  };

  /// Clean only tracked IDs created by the current test suite.
  static Future<void> cleanTracked(SupabaseDatabaseClient db) async {
    final tracker = IntegrationDataTracker.instance;
    final deletedAt = DateTime.now().toIsoUtcString();

    for (final table in _tablesWithNameColumn.keys) {
      for (final id in tracker.getIds(table)) {
        await db.update(
          table: table,
          values: {'deleted_at': deletedAt},
          filters: [SupabaseFilter.eq('id', id)],
        );
      }
    }
    tracker.clear();
  }

  /// Clean all `[IT]`-prefixed rows and tracked IDs.
  static Future<void> cleanAll(
    SupabaseDatabaseClient db,
    String companyId,
  ) async {
    await cleanTracked(db);

    final deletedAt = DateTime.now().toIsoUtcString();

    // Clean by [IT] prefix for any leftovers from previous failed runs
    for (final entry in _tablesWithNameColumn.entries) {
      final nameColumn = entry.value;

      final rows = await db.selectList(
        table: entry.key,
        filters: [
          SupabaseFilter.eq('company_id', companyId),
          SupabaseFilter.isFilter('deleted_at', null),
          SupabaseFilter.ilike(nameColumn, '[IT] %'),
        ],
      );

      for (final row in rows) {
        final id = row['id'] as String?;
        if (id == null) continue;
        await db.update(
          table: entry.key,
          values: {'deleted_at': deletedAt},
          filters: [SupabaseFilter.eq('id', id)],
        );
      }
    }
  }
}
