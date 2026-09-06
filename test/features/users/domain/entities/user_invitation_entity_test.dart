import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  group('UserInvitationEntity', () {
    final tInvitation = UserFactory.makeUserInvitationEntity();

    test('isExpired returns false when confirmationSentAt is null', () {
      final invite = tInvitation.copyWith(annulConfirmationSentAt: true);
      expect(invite.isExpired, isFalse);
      expect(invite.isExpiredByHours(expiryHours: 12), isFalse);
    });

    test(
      'isExpired returns false when sent recently (less than default 24h)',
      () {
        final invite = tInvitation.copyWith(
          confirmationSentAt: DateTime.now().toUtc().subtract(
            const Duration(hours: 2),
          ),
        );
        expect(invite.isExpired, isFalse);
      },
    );

    test('isExpired returns true when sent more than default 24h ago', () {
      final invite = tInvitation.copyWith(
        confirmationSentAt: DateTime.now().toUtc().subtract(
          const Duration(hours: 25),
        ),
      );
      expect(invite.isExpired, isTrue);
    });

    test('isExpiredByHours respects custom company parameter expiry hours', () {
      final invite = tInvitation.copyWith(
        confirmationSentAt: DateTime.now().toUtc().subtract(
          const Duration(hours: 10),
        ),
      );

      // With default 24h, 10h is not expired
      expect(invite.isExpiredByHours(), isFalse);
      // With strict 8h limit, 10h is expired
      expect(invite.isExpiredByHours(expiryHours: 8), isTrue);
      // With generous 48h limit, 10h is not expired
      expect(invite.isExpiredByHours(expiryHours: 48), isFalse);
    });
  });
}
