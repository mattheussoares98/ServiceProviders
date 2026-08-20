import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/integration_config.dart';

/// Helper to initialize and manage live Supabase connection for integration tests.
class SupabaseIntegrationHelper {
  static SupabaseClient? _client;
  static SupabaseDatabaseClient? _databaseClient;

  static Future<void> initialize() async {
    if (_client != null) return;

    String? supabaseUrl;
    String? supabaseAnonKey;

    // Load .env file
    final envFile = File('.env');
    if (envFile.existsSync()) {
      await dotenv.load();
      supabaseUrl = dotenv.maybeGet('SUPABASE_URL');
      supabaseAnonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');

      if (supabaseUrl == null || supabaseAnonKey == null) {
        final lines = await envFile.readAsLines();
        for (final line in lines) {
          if (line.startsWith('SUPABASE_URL=')) {
            supabaseUrl = line.substring('SUPABASE_URL='.length).trim();
          } else if (line.startsWith('SUPABASE_ANON_KEY=')) {
            supabaseAnonKey = line
                .substring('SUPABASE_ANON_KEY='.length)
                .trim();
          }
        }
      }
    }

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be provided in .env',
      );
    }

    _client = SupabaseClient(supabaseUrl, supabaseAnonKey);
    _databaseClient = SupabaseDatabaseClientImpl(_client!);

    // Load integration config
    await IntegrationConfig.load();
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw StateError(
        'SupabaseIntegrationHelper must be initialized before accessing client',
      );
    }
    return _client!;
  }

  static SupabaseDatabaseClient get databaseClient {
    if (_databaseClient == null) {
      throw StateError(
        'SupabaseIntegrationHelper must be initialized before accessing databaseClient',
      );
    }
    return _databaseClient!;
  }

  /// Sign in with the admin user. Returns the user ID.
  static Future<String> signInAsAdmin() async {
    final authRes = await client.auth.signInWithPassword(
      email: IntegrationConfig.adminEmail,
      password: IntegrationConfig.adminPassword,
    );
    return authRes.user!.id;
  }

  /// Sign in with the technician user. Returns the user ID.
  static Future<String> signInAsTechnician() async {
    final authRes = await client.auth.signInWithPassword(
      email: IntegrationConfig.techEmail,
      password: IntegrationConfig.techPassword,
    );
    return authRes.user!.id;
  }
}
