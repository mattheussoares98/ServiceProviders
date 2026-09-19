import 'integration_identity.dart';

typedef TestCredentials = ({String email, String password, String companyId});

/// Resolves ordinary test actors without falling back to privileged accounts.
class IntegrationAccounts {
  IntegrationAccounts(Map<String, String> values) : _values = values {
    final a = _require('TEST_COMPANY_A_ID');
    final b = _require('TEST_COMPANY_B_ID');
    if (a == b) throw StateError('Test companies A and B must differ');
    final emails = <String>{};
    for (final identity in Identity.values) {
      final credentials = forIdentity(identity);
      if (!emails.add(credentials.email.toLowerCase().trim())) {
        throw StateError('Each test identity needs a distinct account');
      }
    }
  }

  final Map<String, String> _values;

  TestCredentials forIdentity(Identity identity) {
    final alias = switch (identity) {
      Identity.admin => 'ADMIN_A',
      Identity.technician => 'TECH_A',
      Identity.supervisor => 'SUPERVISOR_A',
      Identity.provider => 'PROVIDER_A',
      Identity.foreign => 'USER_B',
    };
    return (
      email: _require('TEST_${alias}_EMAIL'),
      password: _require('TEST_${alias}_PASSWORD'),
      companyId: _require(
        identity == Identity.foreign
            ? 'TEST_COMPANY_B_ID'
            : 'TEST_COMPANY_A_ID',
      ),
    );
  }

  String _require(String key) {
    final value = _values[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('Missing test key: $key');
    }
    return value;
  }
}
