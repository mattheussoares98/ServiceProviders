import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';

import '../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  group('CompanyParameterEntity', () {
    test(
      'instantiates with default values for advance warning and escalation',
      () {
        final entity = CompanyParameterEntity(
          id: 'param-1',
          companyId: 'comp-1',
          maxOfflineDurationHours: 2,
          maxOfflinePendingRequests: 10,
          offlineAlertThrottleFrequency: 3,
          maxImageSizeMb: 20,
          maxVideoSizeMb: 500,
          maxPdfSizeMb: 10,
          maxDocumentSizeMb: 5,
          sandboxQuotaMb: 1024,
          maxSyncAttempts: 3,
          inviteExpiryHours: 24,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          deletedAt: null,
        );

        expect(entity.advanceWarningMinutes, 60);
        expect(entity.advanceWarningGroupIds, isEmpty);
        expect(entity.delayedNotificationIntervalMinutes, 60);
        expect(entity.escalationGroupIds, isEmpty);
      },
    );

    test(
      'copyWith updates advance warning and escalation fields correctly',
      () {
        final entity = UserFactory.makeCompanyParameterEntity();
        final updated = entity.copyWith(
          advanceWarningMinutes: 30,
          advanceWarningGroupIds: ['group-1', 'group-2'],
          delayedNotificationIntervalMinutes: 45,
          escalationGroupIds: ['group-a', 'group-b', 'group-c'],
        );

        expect(updated.advanceWarningMinutes, 30);
        expect(updated.advanceWarningGroupIds, ['group-1', 'group-2']);
        expect(updated.delayedNotificationIntervalMinutes, 45);
        expect(updated.escalationGroupIds, ['group-a', 'group-b', 'group-c']);
      },
    );

    test('props equality holds for same attributes', () {
      final entity1 = UserFactory.makeCompanyParameterEntity();
      final entity2 = entity1.copyWith();

      expect(entity1, equals(entity2));
    });
  });
}
