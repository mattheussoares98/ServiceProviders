import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';

import 'factory_helpers.dart';

abstract final class CustomerFactory {
  static CustomerEntity makeCustomerEntity() {
    return CustomerEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name:
          '${FactoryHelpers.makeCompanyName()} ${FactoryHelpers.makeId().substring(0, 5)}',
      document: faker.randomGenerator.numbers(9, 11).join(),

      contactName: FactoryHelpers.makePersonName(),
      contactEmail: FactoryHelpers.makeEmail(),
      contactPhone: faker.phoneNumber.us(),
      address: faker.address.streetAddress(),
      number: FactoryHelpers.makeInt(100, min: 1).toString(),
      complement: FactoryHelpers.makePhrase(),
      neighborhood: FactoryHelpers.makeWord(),
      city: faker.address.city(),
      state: faker.address.state(),
      postalCode: FactoryHelpers.makeString(8),
      notes: FactoryHelpers.makePhrase(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<CustomerEntity> makeCustomerEntityList() {
    return [makeCustomerEntity(), makeCustomerEntity(), makeCustomerEntity()];
  }
}
