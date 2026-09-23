import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/plan_type.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';

void main() {
  group('PlanType', () {
    test('isFree and isPaid work correctly', () {
      expect(PlanType.free.isFree, isTrue);
      expect(PlanType.free.isPaid, isFalse);

      expect(PlanType.paid.isPaid, isTrue);
      expect(PlanType.paid.isFree, isFalse);
    });

    test('fromCode maps correctly and returns null for invalid codes', () {
      expect(PlanType.fromCode('free'), PlanType.free);
      expect(PlanType.fromCode('paid'), PlanType.paid);
      expect(PlanType.fromCode('invalid'), isNull);
      expect(PlanType.fromCode(null), isNull);
    });
  });

  group('WorkType', () {
    test('supportsOwnLocations is true for internalOnly and hybrid', () {
      expect(WorkType.internalOnly.supportsOwnLocations, isTrue);
      expect(WorkType.hybrid.supportsOwnLocations, isTrue);
      expect(WorkType.serviceProviderOnly.supportsOwnLocations, isFalse);
    });

    test('supportsCustomers is true for serviceProviderOnly and hybrid', () {
      expect(WorkType.serviceProviderOnly.supportsCustomers, isTrue);
      expect(WorkType.hybrid.supportsCustomers, isTrue);
      expect(WorkType.internalOnly.supportsCustomers, isFalse);
    });

    test('canUpgradeTo allows upgrade from single to hybrid only', () {
      expect(WorkType.internalOnly.canUpgradeTo(WorkType.hybrid), isTrue);
      expect(
        WorkType.serviceProviderOnly.canUpgradeTo(WorkType.hybrid),
        isTrue,
      );

      expect(
        WorkType.internalOnly.canUpgradeTo(WorkType.serviceProviderOnly),
        isFalse,
      );
      expect(
        WorkType.serviceProviderOnly.canUpgradeTo(WorkType.internalOnly),
        isFalse,
      );
      expect(WorkType.hybrid.canUpgradeTo(WorkType.internalOnly), isFalse);
      expect(
        WorkType.hybrid.canUpgradeTo(WorkType.serviceProviderOnly),
        isFalse,
      );
      expect(WorkType.hybrid.canUpgradeTo(WorkType.hybrid), isFalse);
    });

    test('fromCode maps correctly and returns null for invalid codes', () {
      expect(WorkType.fromCode('internal_only'), WorkType.internalOnly);
      expect(
        WorkType.fromCode('service_provider_only'),
        WorkType.serviceProviderOnly,
      );
      expect(WorkType.fromCode('hybrid'), WorkType.hybrid);
      expect(WorkType.fromCode('other'), isNull);
      expect(WorkType.fromCode(null), isNull);
    });
  });
}
