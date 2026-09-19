import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'integration_accounts.dart';
import 'integration_identity.dart';

/// Centralized configuration for integration tests, read from .env.
class IntegrationConfig {
  static bool _initialized = false;

  static late final IntegrationAccounts accounts;
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

    accounts = IntegrationAccounts({...dotenv.env, ...Platform.environment});
    final admin = accounts.forIdentity(Identity.admin);
    final tech = accounts.forIdentity(Identity.technician);
    final foreign = accounts.forIdentity(Identity.foreign);
    companyId = admin.companyId;
    adminEmail = admin.email;
    adminPassword = admin.password;
    techEmail = tech.email;
    techPassword = tech.password;
    // Mutation fixtures must never adopt pre-existing business rows.
    useExistingData = false;
    autoCleanup =
        (Platform.environment['INTEGRATION_TEST_AUTO_CLEANUP'] ??
            dotenv.maybeGet('INTEGRATION_TEST_AUTO_CLEANUP')) ==
        'true';
    foreignEmail = foreign.email;
    foreignPassword = foreign.password;
    foreignCompanyId = foreign.companyId;

    _initialized = true;
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
