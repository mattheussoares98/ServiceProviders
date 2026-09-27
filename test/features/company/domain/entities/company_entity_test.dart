import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';

import '../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  group('CompanyEntity', () {
    test('delegates workType helper getters correctly', () {
      final internalCompany = UserFactory.makeCompanyEntity().copyWith(
        workType: WorkType.internalOnly,
      );
      expect(internalCompany.requiresLocation, isTrue);
      expect(internalCompany.requiresCustomer, isFalse);
      expect(internalCompany.supportsOwnLocations, isTrue);
      expect(internalCompany.supportsCustomers, isFalse);
      expect(internalCompany.canHireServiceProviders, isTrue);
      expect(internalCompany.isInternalOnly, isTrue);
      expect(internalCompany.isServiceProviderOnly, isFalse);
      expect(internalCompany.isHybrid, isFalse);

      final providerCompany = UserFactory.makeCompanyEntity().copyWith(
        workType: WorkType.serviceProviderOnly,
      );
      expect(providerCompany.requiresLocation, isFalse);
      expect(providerCompany.requiresCustomer, isTrue);
      expect(providerCompany.supportsOwnLocations, isFalse);
      expect(providerCompany.supportsCustomers, isTrue);
      expect(providerCompany.canHireServiceProviders, isFalse);
      expect(providerCompany.isInternalOnly, isFalse);
      expect(providerCompany.isServiceProviderOnly, isTrue);
      expect(providerCompany.isHybrid, isFalse);

      final hybridCompany = UserFactory.makeCompanyEntity().copyWith(
        workType: WorkType.hybrid,
      );
      expect(hybridCompany.requiresLocation, isFalse);
      expect(hybridCompany.requiresCustomer, isFalse);
      expect(hybridCompany.supportsOwnLocations, isTrue);
      expect(hybridCompany.supportsCustomers, isTrue);
      expect(hybridCompany.canHireServiceProviders, isTrue);
      expect(hybridCompany.isInternalOnly, isFalse);
      expect(hybridCompany.isServiceProviderOnly, isFalse);
      expect(hybridCompany.isHybrid, isTrue);
    });

    test('copyWith updates workType correctly', () {
      final company = UserFactory.makeCompanyEntity().copyWith(
        workType: WorkType.internalOnly,
      );
      final updated = company.copyWith(workType: WorkType.hybrid);
      expect(updated.workType, WorkType.hybrid);
    });
  });
}
