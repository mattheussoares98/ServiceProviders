import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'integration_config.dart';
import 'integration_data_sources.dart';
import 'integration_identity.dart';
import 'integration_run.dart';

/// One authenticated identity, with every client and data source bound to it.
///
/// Holding a whole [SupabaseClient] per identity is what lets a single test act
/// as several users at once. The rejected alternatives:
///
/// * **Sequential sign-in on one shared client** — data sources captured in
///   `setUpAll` would silently change identity mid-test, a failure would strand
///   the process signed in as the wrong user, and realtime sockets keep the
///   token they had at connect time.
/// * **The `accessToken:` callback** — `SupabaseClient.auth` throws when it is
///   set, so `signOut`/session inspection become unavailable.
///
/// Per-instance auth is safe: each [SupabaseClient] builds its own in-memory
/// `GoTrueClient`, and its REST client resolves the bearer token per request.
final class IntegrationSession {
  IntegrationSession._({
    required this.identity,
    required this.userId,
    required this.email,
    required this.client,
    required this.database,
    required this.realtime,
    required this.auth,
    required this.sources,
    required this.companyId,
    this.providerProfileId,
    this.serviceProviderCompanyId,
  });

  final Identity identity;

  /// `auth.users.id` — the value RLS predicates compare against `auth.uid()`.
  final String userId;
  final String email;

  final SupabaseClient client;
  final SupabaseDatabaseClient database;
  final SupabaseRealtimeClient realtime;
  final SupabaseAuthClient auth;
  final IntegrationDataSources sources;

  /// The tenant this identity belongs to. For [Identity.provider] this is the
  /// *hiring* tenant under test, not the provider company.
  final String companyId;

  /// `service_provider_profiles.id`, resolved for [Identity.provider] only.
  final String? providerProfileId;

  /// `service_provider_companies.id` owning [providerProfileId].
  final String? serviceProviderCompanyId;

  @override
  String toString() => 'IntegrationSession(${identity.name}, $email)';
}

/// Lazily signs in and caches one [IntegrationSession] per [Identity].
///
/// Sessions are process-wide and shared across the suites in one file. Because
/// `flutter test` isolates each file, there is no cross-file leakage.
final class IntegrationSessions {
  const IntegrationSessions._();

  static final Map<Identity, IntegrationSession> _sessions = {};
  static final Map<Identity, String> _unavailable = {};

  static String? _url;
  static String? _anonKey;

  /// Signs in [identity] (once per process) and returns its session.
  ///
  /// Throws when a required identity cannot be authenticated. For the optional
  /// [Identity.foreign], prefer [maybeAs], which returns null instead.
  static Future<IntegrationSession> as(Identity identity) async {
    IntegrationRun.assertEnabled();
    final session = await maybeAs(identity);
    if (session == null) {
      throw StateError(
        'Identity ${identity.name} is unavailable: '
        '${_unavailable[identity] ?? 'unknown reason'}',
      );
    }
    return session;
  }

  /// Like [as], but returns null when the identity cannot be provisioned, so a
  /// case can record itself as SKIPPED rather than fail.
  static Future<IntegrationSession?> maybeAs(Identity identity) async {
    IntegrationRun.assertEnabled();
    final cached = _sessions[identity];
    if (cached != null) return cached;
    if (_unavailable.containsKey(identity)) return null;

    await _loadEnvironment();

    final credentials = _credentialsFor(identity);
    if (credentials == null) {
      _unavailable[identity] =
          'no credentials configured (set INTEGRATION_TEST_FOREIGN_EMAIL / '
          '_PASSWORD in .env to enable cross-tenant cases)';
      return null;
    }

    try {
      final session = await _signIn(identity, credentials);
      _sessions[identity] = session;
      return session;
    } on Object catch (error) {
      _unavailable[identity] = error.toString();
      if (identity.isRequired) rethrow;
      return null;
    }
  }

  /// Why an identity could not be provisioned, for the report's SKIPPED reason.
  static String? unavailableReason(Identity identity) => _unavailable[identity];

  /// Signs every cached identity out. Registered by the suite's `tearDownAll`.
  static Future<void> disposeAll() async {
    for (final session in _sessions.values) {
      try {
        await session.client.auth.signOut();
        await session.client.dispose();
      } on Object {
        // A failed sign-out must never mask the real test failure.
      }
    }
    _sessions.clear();
    _unavailable.clear();
  }

  static Future<IntegrationSession> _signIn(
    Identity identity,
    ({String email, String password, String? companyId}) credentials,
  ) async {
    final client = SupabaseClient(_url!, _anonKey!);
    final response = await client.auth.signInWithPassword(
      email: credentials.email,
      password: credentials.password,
    );
    final user = response.user;
    if (user == null) {
      throw StateError('Sign-in returned no user for ${identity.name}');
    }

    final database = SupabaseDatabaseClientImpl(client);
    final realtime = SupabaseRealtimeClientImpl(client);

    String? providerProfileId;
    String? serviceProviderCompanyId;
    if (identity == Identity.provider) {
      final profile = await database.selectOne(
        table: 'service_provider_profiles',
        filters: [
          SupabaseFilter.eq('auth_user_id', user.id),
          SupabaseFilter.eq('is_active', true),
        ],
      );
      if (profile == null) {
        throw StateError(
          '${credentials.email} has no active service_provider_profiles row, '
          'so provider mode cannot be exercised.',
        );
      }
      providerProfileId = profile['id'] as String?;
      serviceProviderCompanyId =
          profile['service_provider_company_id'] as String?;
    }

    return IntegrationSession._(
      identity: identity,
      userId: user.id,
      email: credentials.email,
      client: client,
      database: database,
      realtime: realtime,
      auth: SupabaseAuthClientImpl(client.auth),
      sources: IntegrationDataSources.forClient(
        database: database,
        realtime: realtime,
        auth: SupabaseAuthClientImpl(client.auth),
      ),
      companyId: credentials.companyId ?? IntegrationConfig.companyId,
      providerProfileId: providerProfileId,
      serviceProviderCompanyId: serviceProviderCompanyId,
    );
  }

  /// [Identity.supervisor] and [Identity.provider] deliberately reuse the
  /// technician's credentials.
  ///
  /// * *supervisor* is the same principal as *technician*; what separates them
  ///   is `PermissionFixture`, which repoints the profile at a throwaway group
  ///   holding `work_orders.manage_pending_requests` for the duration of a case.
  ///   Consequence: a case cannot hold technician and supervisor powers at the
  ///   same instant — act as the technician first, then apply the fixture.
  /// * *provider* is the same account resolved through its
  ///   `service_provider_profiles` row, which is exactly the dual identity the
  ///   real app builds via `ModeSwitcherCubit`.
  static ({String email, String password, String? companyId})? _credentialsFor(
    Identity identity,
  ) {
    switch (identity) {
      case Identity.admin:
        return (
          email: IntegrationConfig.adminEmail,
          password: IntegrationConfig.adminPassword,
          companyId: null,
        );
      case Identity.technician:
      case Identity.supervisor:
      case Identity.provider:
        return (
          email: IntegrationConfig.techEmail,
          password: IntegrationConfig.techPassword,
          companyId: null,
        );
      case Identity.foreign:
        if (!IntegrationConfig.hasForeignIdentity) return null;
        return (
          email: IntegrationConfig.foreignEmail!,
          password: IntegrationConfig.foreignPassword!,
          companyId: IntegrationConfig.foreignCompanyId,
        );
    }
  }

  static Future<void> _loadEnvironment() async {
    if (_url != null && _anonKey != null) return;

    if (File('.env').existsSync()) {
      await dotenv.load();
    }
    _url = dotenv.maybeGet('SUPABASE_URL');
    _anonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');
    if (_url == null || _anonKey == null) {
      throw StateError('SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env');
    }
    await IntegrationConfig.load();
  }
}
