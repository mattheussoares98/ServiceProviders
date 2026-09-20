// Targeted flutter analyze passed; live tests were disabled.
import 'package:flutter_test/flutter_test.dart';

import '../integration/core/integration_accounts.dart';
import '../integration/core/integration_identity.dart';

void main() {
  Map<String, String> configuration() => {
    'TEST_COMPANY_A_ID': 'company-a',
    'TEST_COMPANY_B_ID': 'company-b',
    for (final alias in [
      'ADMIN_A',
      'TECH_A',
      'SUPERVISOR_A',
      'PROVIDER_A',
      'USER_B',
    ]) ...{
      'TEST_${alias}_EMAIL': '${alias.toLowerCase()}@example.invalid',
      'TEST_${alias}_PASSWORD': 'fixture-password',
    },
  };

  test('each role has a distinct account and explicit tenant', () {
    final accounts = IntegrationAccounts(configuration());
    final actors = Identity.values.map(accounts.forIdentity).toList();
    expect(actors.map((actor) => actor.email).toSet(), hasLength(5));
    for (final identity in Identity.values) {
      expect(
        accounts.forIdentity(identity).companyId,
        identity == Identity.foreign ? 'company-b' : 'company-a',
      );
    }
    expect(
      accounts.forIdentity(Identity.supervisor).email,
      'supervisor_a@example.invalid',
    );
    expect(
      accounts.forIdentity(Identity.provider).email,
      'provider_a@example.invalid',
    );
  });

  for (final key in configuration().keys) {
    test(
      'missing $key fails closed instead of using privileged credentials',
      () {
        final values = configuration()
          ..remove(key)
          ..addAll({
            'INTEGRATION_TEST_ADMIN_EMAIL': 'privileged@example.invalid',
            'INTEGRATION_TEST_ADMIN_PASSWORD': 'privileged-fixture-password',
            'INTEGRATION_TEST_COMPANY_ID': 'unrelated-company',
          });
        expect(() => IntegrationAccounts(values), throwsStateError);
      },
    );
  }

  test('foreign company cannot be the same as the primary company', () {
    final values = configuration()..['TEST_COMPANY_B_ID'] = 'company-a';
    expect(() => IntegrationAccounts(values), throwsStateError);
  });

  test('role aliases cannot share an email even with case or whitespace', () {
    final values = configuration()
      ..['TEST_SUPERVISOR_A_EMAIL'] = '  TECH_A@example.invalid  ';
    expect(() => IntegrationAccounts(values), throwsStateError);
  });

  test('empty credentials fail without disclosing other values', () {
    final values = configuration()..['TEST_TECH_A_PASSWORD'] = '  ';
    expect(
      () => IntegrationAccounts(values),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'safe error',
          'Missing test key: TEST_TECH_A_PASSWORD',
        ),
      ),
    );
  });
}
