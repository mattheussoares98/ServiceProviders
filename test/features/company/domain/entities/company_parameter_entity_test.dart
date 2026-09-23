import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/plan_type.dart';

import '../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  group('CompanyParameterEntity Quota Helpers', () {
    test(
      'canCreateWorkOrder respects maxDailyWorkOrders and unlimited (0)',
      () {
        final limited = UserFactory.makeCompanyParameterEntity().copyWith(
          maxDailyWorkOrders: 3,
        );
        expect(limited.hasUnlimitedDailyWorkOrders, isFalse);
        expect(limited.canCreateWorkOrder(0), isTrue);
        expect(limited.canCreateWorkOrder(2), isTrue);
        expect(limited.canCreateWorkOrder(3), isFalse);
        expect(limited.canCreateWorkOrder(4), isFalse);

        final unlimited = UserFactory.makeCompanyParameterEntity().copyWith(
          maxDailyWorkOrders: 0,
        );
        expect(unlimited.hasUnlimitedDailyWorkOrders, isTrue);
        expect(unlimited.canCreateWorkOrder(0), isTrue);
        expect(unlimited.canCreateWorkOrder(100), isTrue);
      },
    );

    test(
      'canAddAttachment respects maxAttachmentsPerWorkOrder and unlimited (0)',
      () {
        final limited = UserFactory.makeCompanyParameterEntity().copyWith(
          maxAttachmentsPerWorkOrder: 2,
        );
        expect(limited.canAddAttachment(0), isTrue);
        expect(limited.canAddAttachment(1), isTrue);
        expect(limited.canAddAttachment(2), isFalse);
        expect(limited.canAddAttachment(3), isFalse);

        final unlimited = UserFactory.makeCompanyParameterEntity().copyWith(
          maxAttachmentsPerWorkOrder: 0,
        );
        expect(unlimited.canAddAttachment(0), isTrue);
        expect(unlimited.canAddAttachment(10), isTrue);
      },
    );

    test(
      'canAddObservation respects maxObservationsPerWorkOrder and unlimited (0)',
      () {
        final limited = UserFactory.makeCompanyParameterEntity().copyWith(
          maxObservationsPerWorkOrder: 2,
        );
        expect(limited.canAddObservation(0), isTrue);
        expect(limited.canAddObservation(1), isTrue);
        expect(limited.canAddObservation(2), isFalse);
        expect(limited.canAddObservation(3), isFalse);

        final unlimited = UserFactory.makeCompanyParameterEntity().copyWith(
          maxObservationsPerWorkOrder: 0,
        );
        expect(unlimited.canAddObservation(0), isTrue);
        expect(unlimited.canAddObservation(10), isTrue);
      },
    );

    test('maintenancePlansEnabled disambiguates with PlanType', () {
      final entity = UserFactory.makeCompanyParameterEntity().copyWith(
        maxMaintenancePlans: 0,
      );

      // On free plan with 0 limit -> disabled
      expect(entity.maintenancePlansEnabled(PlanType.free), isFalse);
      // On paid plan with 0 limit -> unlimited/enabled
      expect(entity.maintenancePlansEnabled(PlanType.paid), isTrue);

      final withCustomLimit = entity.copyWith(maxMaintenancePlans: 5);
      expect(withCustomLimit.maintenancePlansEnabled(PlanType.free), isTrue);
      expect(withCustomLimit.maintenancePlansEnabled(PlanType.paid), isTrue);
    });

    test('serviceProvidersEnabled disambiguates with PlanType', () {
      final entity = UserFactory.makeCompanyParameterEntity().copyWith(
        maxServiceProviders: 0,
      );

      // On free plan with 0 limit -> disabled
      expect(entity.serviceProvidersEnabled(PlanType.free), isFalse);
      // On paid plan with 0 limit -> unlimited/enabled
      expect(entity.serviceProvidersEnabled(PlanType.paid), isTrue);

      final withCustomLimit = entity.copyWith(maxServiceProviders: 5);
      expect(withCustomLimit.serviceProvidersEnabled(PlanType.free), isTrue);
      expect(withCustomLimit.serviceProvidersEnabled(PlanType.paid), isTrue);
    });
  });
}
