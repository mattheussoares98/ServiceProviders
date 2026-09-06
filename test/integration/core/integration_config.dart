import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized configuration for integration tests, read from .env.
class IntegrationConfig {
  static bool _initialized = false;

  static late final String companyId;
  static late final String adminEmail;
  static late final String adminPassword;
  static late final String techEmail;
  static late final String techPassword;
  static late final bool useExistingData;
  static late final bool autoCleanup;

  /// Optional second-tenant identity, used only by the cross-company denial
  /// cases. Absent in most environments; dependent cases record as SKIPPED
  /// rather than silently passing.
  static String? foreignEmail;
  static String? foreignPassword;
  static String? foreignCompanyId;

  /// Whether the cross-tenant identity is configured.
  static bool get hasForeignIdentity =>
      (foreignEmail?.isNotEmpty ?? false) &&
      (foreignPassword?.isNotEmpty ?? false);

  /// Every invite-sending case targets this address: it is the only recipient
  /// the project's SMTP can actually deliver to.
  static const String inviteRecipient = 'mattheussbarosa98@gmail.com';

  /// Gmail `+tag` addressing, so each invite case gets a distinct address while
  /// still landing in the one deliverable mailbox.
  static String inviteAddress(String tag) {
    final unique = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final local = inviteRecipient.split('@').first;
    final domain = inviteRecipient.split('@').last;
    return '$local+it-$tag$unique@$domain';
  }

  /// Prefix prepended to all test-created row names for identification.
  static const String testDataPrefix = '[IT] ';

  static Future<void> load() async {
    if (_initialized) return;

    final envFile = File('.env');
    if (envFile.existsSync()) {
      await dotenv.load();
    }

    companyId = _require('INTEGRATION_TEST_COMPANY_ID');
    adminEmail = _require('INTEGRATION_TEST_ADMIN_EMAIL');
    adminPassword = _require('INTEGRATION_TEST_ADMIN_PASSWORD');
    techEmail = _require('INTEGRATION_TEST_TECH_EMAIL');
    techPassword = _require('INTEGRATION_TEST_TECH_PASSWORD');
    useExistingData =
        dotenv.maybeGet('INTEGRATION_TEST_USE_EXISTING_DATA') == 'true';
    autoCleanup =
        dotenv.maybeGet('INTEGRATION_TEST_AUTO_CLEANUP') == 'true';
    foreignEmail = dotenv.maybeGet('INTEGRATION_TEST_FOREIGN_EMAIL');
    foreignPassword = dotenv.maybeGet('INTEGRATION_TEST_FOREIGN_PASSWORD');
    foreignCompanyId = dotenv.maybeGet('INTEGRATION_TEST_FOREIGN_COMPANY_ID');

    _initialized = true;
  }

  static String _require(String key) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError('Missing required .env key: $key');
    }
    return value;
  }

  static int _nameCounter = 0;

  /// Creates a test-identifiable name from an EntityFactory-generated name.
  ///
  /// A short run-unique suffix is appended because the fixture names come from
  /// `faker.lorem.word()` and friends, whose vocabulary is small enough to
  /// collide with the `[IT]` rows left behind by earlier runs — every affected
  /// table has a case-insensitive unique index on (company_id, name).
  static String testName(String baseName) {
    final unique = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return '$testDataPrefix$baseName $unique${_nameCounter++}';
  }
}
