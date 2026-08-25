import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  group('UserProfileEntity', () {
    test(
      'isSuperAdmin returns true for allowed emails (case-insensitive and trimmed)',
      () {
        final emails = [
          'mattheussbarosa98@gmail.com',
          'mattheussbarbosa@hotmail.com',
          'thiago.saraiva@kephasengenharia.com.br',
          '  MATTHEUSSBAROSA98@GMAIL.COM  ',
          'Thiago.Saraiva@KephasEngenharia.com.br',
        ];

        for (final email in emails) {
          final user = EntityFactory.makeUserProfileEntity().copyWith(
            email: email,
          );
          expect(
            user.isSuperAdmin,
            isTrue,
            reason: 'Expected $email to be super admin',
          );
        }
      },
    );

    test('isSuperAdmin returns false for any other email', () {
      final user = EntityFactory.makeUserProfileEntity().copyWith(
        email: 'other_user@example.com',
      );
      expect(user.isSuperAdmin, isFalse);
    });
  });
}
