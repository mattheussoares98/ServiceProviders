import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/customers/data/data_sources/customers_local_data_source.dart';
import 'package:o_jogo_da_obra/features/customers/data/models/responses/customer_model.dart';

import '../../../../../testing/mocks/factories/customer_factory.dart';

void main() {
  late AppDatabase database;
  late CustomersLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = CustomersLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertCompany(String companyId) async {
    await database
        .into(database.companies)
        .insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );
  }

  final tCompanyId = faker.guid.guid();
  final tCustomerModel = CustomerModel.fromEntity(
    CustomerFactory.makeCustomerEntity().copyWith(companyId: tCompanyId),
  );

  group('CustomersLocalDataSourceImpl', () {
    group('saveCustomer and getCustomerById', () {
      test('should insert customer and retrieve it by id', () async {
        await insertCompany(tCompanyId);

        final saveResult = await dataSource.saveCustomer(tCustomerModel);
        expect(saveResult, isA<SuccessState<bool>>());

        final getResult = await dataSource.getCustomerById(tCustomerModel.id);
        expect(getResult, isA<SuccessState<CustomerModel>>());
        expect(getResult.data!.id, equals(tCustomerModel.id));
        expect(getResult.data!.name, equals(tCustomerModel.name));
        expect(getResult.data!.companyId, equals(tCompanyId));
      });

      test('should return FailureState when customer is not found', () async {
        final result = await dataSource.getCustomerById('non-existent');
        expect(result, isA<FailureState<CustomerModel>>());
      });
    });

    group('getCustomers', () {
      test(
        'should return only active and non-deleted customers for company',
        () async {
          await insertCompany(tCompanyId);

          final otherCompanyId = faker.guid.guid();
          await insertCompany(otherCompanyId);

          final customer1 = CustomerModel.fromEntity(
            CustomerFactory.makeCustomerEntity().copyWith(
              companyId: tCompanyId,
            ),
          );
          final customer2 = CustomerModel.fromEntity(
            CustomerFactory.makeCustomerEntity().copyWith(
              companyId: tCompanyId,
            ),
          );
          final customerOther = CustomerModel.fromEntity(
            CustomerFactory.makeCustomerEntity().copyWith(
              companyId: otherCompanyId,
            ),
          );

          await dataSource.saveCustomers([customer1, customer2, customerOther]);

          final result = await dataSource.getCustomers(tCompanyId);

          expect(result, isA<SuccessState<List<CustomerModel>>>());
          expect(result.data!.length, equals(2));
          expect(
            result.data!.map((c) => c.id),
            containsAll([customer1.id, customer2.id]),
          );
        },
      );
    });

    group('deleteCustomer', () {
      test(
        'should soft-delete customer and not return it in getCustomers or getCustomerById',
        () async {
          await insertCompany(tCompanyId);

          await dataSource.saveCustomer(tCustomerModel);

          final deleteResult = await dataSource.deleteCustomer(
            tCustomerModel.id,
          );
          expect(deleteResult, isA<SuccessState<bool>>());

          final getResult = await dataSource.getCustomerById(tCustomerModel.id);
          expect(getResult, isA<FailureState<CustomerModel>>());

          final listResult = await dataSource.getCustomers(tCompanyId);
          expect(listResult.data, isEmpty);
        },
      );
    });

    group('hasNonDeletedCustomers', () {
      test('should return true when non-deleted customers exist', () async {
        await insertCompany(tCompanyId);
        await dataSource.saveCustomer(tCustomerModel);

        final result = await dataSource.hasNonDeletedCustomers(tCompanyId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
      });

      test('should return false when no customers exist', () async {
        final result = await dataSource.hasNonDeletedCustomers(tCompanyId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isFalse);
      });

      test('should return false when only deleted customers exist', () async {
        await insertCompany(tCompanyId);
        await dataSource.saveCustomer(tCustomerModel);
        await dataSource.deleteCustomer(tCustomerModel.id);

        final result = await dataSource.hasNonDeletedCustomers(tCompanyId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isFalse);
      });
    });
  });
}
