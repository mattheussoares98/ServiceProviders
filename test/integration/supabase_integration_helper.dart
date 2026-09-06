import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/integration_identity.dart';
import 'core/integration_run.dart';
import 'core/integration_session.dart';

/// Thin facade over [IntegrationSessions] for the single-identity suites.
///
/// New suites should use `IntegrationSessions.as(Identity.x)` directly — it is
/// the only way to hold several identities at once, which every RLS and scope
/// case needs. This facade exists so the suites written before per-identity
/// sessions keep compiling and passing unchanged; every getter here resolves to
/// the **admin** session.
class SupabaseIntegrationHelper {
  static IntegrationSession? _admin;

  static Future<void> initialize() async {
    IntegrationRun.assertEnabled();
    _admin ??= await IntegrationSessions.as(Identity.admin);
  }

  static IntegrationSession get _session {
    final session = _admin;
    if (session == null) {
      throw StateError(
        'SupabaseIntegrationHelper.initialize() must be awaited first',
      );
    }
    return session;
  }

  static SupabaseClient get client => _session.client;

  static SupabaseDatabaseClient get databaseClient => _session.database;

  static SupabaseRealtimeClient get realtimeClient => _session.realtime;

  /// Returns the admin user id. The session is established by [initialize];
  /// this no longer performs a sign-in of its own.
  static Future<String> signInAsAdmin() async {
    await initialize();
    return _session.userId;
  }
}
