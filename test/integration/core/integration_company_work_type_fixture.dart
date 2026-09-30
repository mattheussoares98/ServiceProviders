import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';

import 'integration_identity.dart';
import 'integration_session.dart';

/// Temporarily alters a test company's `work_type` in the real database,
/// restoring the original setting in [addTearDown].
class CompanyWorkTypeFixture {
  const CompanyWorkTypeFixture._();

  /// Sets the company's `work_type` in Supabase to [workType] for the current test.
  /// Automatically registers a teardown that restores the original `work_type`.
  static Future<void> apply({
    required IntegrationSession adminSession,
    required WorkType workType,
    String? targetCompanyId,
  }) async {
    final companyId = targetCompanyId ?? adminSession.companyId;
    final db = (await IntegrationSessions.as(Identity.admin)).database;

    final existing = await db.selectOne(
      table: 'companies',
      columns: 'work_type',
      filters: [SupabaseFilter.eq('id', companyId)],
    );

    final originalWorkType = existing?['work_type'] as String?;

    addTearDown(() async {
      await db.update(
        table: 'companies',
        values: {'work_type': originalWorkType},
        filters: [SupabaseFilter.eq('id', companyId)],
      );
    });

    await db.update(
      table: 'companies',
      values: {'work_type': workType.name},
      filters: [SupabaseFilter.eq('id', companyId)],
    );
  }
}
