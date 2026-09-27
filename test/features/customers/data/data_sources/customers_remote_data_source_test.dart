import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/customers/data/data_sources/customers_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/customers/data/models/responses/customer_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/customer_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockSupabaseDatabaseClient;
  late CustomersRemoteDataSourceImpl dataSource;

  setUp(() {
    mockSupabaseDatabaseClient = MockSupabaseDatabaseClient();
    dataSource = CustomersRemoteDataSourceImpl(
      database: mockSupabaseDatabaseClient,
    );
  });

  final tCustomerEntity = CustomerFactory.makeCustomerEntity();
  final tCustomerModel = CustomerModel.fromEntity(tCustomerEntity);
  final tCompanyId = faker.guid.guid();
  final tId = faker.guid.guid();

  group('CustomersRemoteDataSourceImpl', () {
    group('getCustomers', () {
      test(
        'should return SuccessState<List<CustomerModel>> on success',
        () async {
          when(
            () => mockSupabaseDatabaseClient.selectList(
              table: any(named: 'table'),
              columns: any(named: 'columns'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => [tCustomerModel.toJson()]);

          final result = await dataSource.getCustomers(tCompanyId);

          expect(result, isA<SuccessState<List<CustomerModel>>>());
          expect(result.data!.first.id, equals(tCustomerModel.id));
          verify(
            () => mockSupabaseDatabaseClient.selectList(
              table: 'customers',
              filters: any(named: 'filters'),
            ),
          ).called(1);
        },
      );
    });

    group('getCustomersByIds', () {
      test(
        'should return empty list when ids is empty without calling database',
        () async {
          final result = await dataSource.getCustomersByIds([]);

          expect(result, isA<SuccessState<List<CustomerModel>>>());
          expect(result.data, isEmpty);
          verifyZeroInteractions(mockSupabaseDatabaseClient);
        },
      );

      test('should query database when ids is not empty', () async {
        when(
          () => mockSupabaseDatabaseClient.selectList(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tCustomerModel.toJson()]);

        final result = await dataSource.getCustomersByIds([tId]);

        expect(result, isA<SuccessState<List<CustomerModel>>>());
        expect(result.data!.first.id, equals(tCustomerModel.id));
        verify(
          () => mockSupabaseDatabaseClient.selectList(
            table: 'customers',
            filters: any(named: 'filters'),
          ),
        ).called(1);
      });
    });

    group('getCustomerById', () {
      test('should return CustomerModel on success', () async {
        when(
          () => mockSupabaseDatabaseClient.selectOne(
            table: any<String>(named: 'table'),
            columns: any<String>(named: 'columns'),
            filters: any<List<SupabaseFilter>>(named: 'filters'),
          ),
        ).thenAnswer((_) async => tCustomerModel.toJson());

        final result = await dataSource.getCustomerById(tId);

        expect(result, isA<SuccessState<CustomerModel>>());
        expect(result.data!.id, equals(tCustomerModel.id));
      });
    });

    group('createCustomer', () {
      test('should return created CustomerModel on success', () async {
        when(
          () => mockSupabaseDatabaseClient.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tCustomerModel.toJson()]);

        final result = await dataSource.createCustomer(tCustomerModel);

        expect(result, isA<SuccessState<CustomerModel>>());
        expect(result.data!.id, equals(tCustomerModel.id));
        verify(
          () => mockSupabaseDatabaseClient.insert(
            table: 'customers',
            values: any(named: 'values'),
          ),
        ).called(1);
      });
    });

    group('updateCustomer', () {
      test('should return updated CustomerModel on success', () async {
        when(
          () => mockSupabaseDatabaseClient.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tCustomerModel.toJson()]);

        final result = await dataSource.updateCustomer(tCustomerModel);

        expect(result, isA<SuccessState<CustomerModel>>());
        expect(result.data!.id, equals(tCustomerModel.id));
        verify(
          () => mockSupabaseDatabaseClient.update(
            table: 'customers',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
      });
    });

    group('deleteCustomer', () {
      test('should soft-delete customer via database update', () async {
        when(
          () => mockSupabaseDatabaseClient.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => []);

        final result = await dataSource.deleteCustomer(tId);

        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockSupabaseDatabaseClient.update(
            table: 'customers',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
      });
    });
  });
}
