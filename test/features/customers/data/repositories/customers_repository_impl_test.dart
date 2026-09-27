import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/customers/data/models/responses/customer_model.dart';
import 'package:o_jogo_da_obra/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/factories/customer_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockCustomersRemoteDataSource mockRemoteDataSource;
  late MockCustomersLocalDataSource mockLocalDataSource;
  late CustomersRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      CustomerModel.fromEntity(CustomerFactory.makeCustomerEntity()),
    );
    registerFallbackValue(<CustomerModel>[]);
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockCustomersRemoteDataSource();
    mockLocalDataSource = MockCustomersLocalDataSource();
    repository = CustomersRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tCustomerEntity = CustomerFactory.makeCustomerEntity();
  final tCustomerModel = CustomerModel.fromEntity(tCustomerEntity);
  final tCompanyId = faker.guid.guid();
  final tId = faker.guid.guid();

  group('CustomersRepositoryImpl', () {
    group('getCustomers', () {
      test('should fetch from remote and cache to local when online', () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getCustomers(any()),
        ).thenAnswer((_) async => SuccessState(data: [tCustomerModel]));
        when(
          () => mockLocalDataSource.saveCustomers(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getCustomers(tCompanyId);

        expect(result, isA<SuccessState<List<CustomerEntity>>>());
        expect(result.data!.first.id, equals(tCustomerEntity.id));
        verify(() => mockRemoteDataSource.getCustomers(tCompanyId)).called(1);
        verify(
          () => mockLocalDataSource.saveCustomers([tCustomerModel]),
        ).called(1);
      });

      test('should fetch from local when offline', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.getCustomers(any()),
        ).thenAnswer((_) async => SuccessState(data: [tCustomerModel]));

        final result = await repository.getCustomers(tCompanyId);

        expect(result, isA<SuccessState<List<CustomerEntity>>>());
        expect(result.data!.first.id, equals(tCustomerEntity.id));
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getCustomers(tCompanyId)).called(1);
      });
    });

    group('getCustomersByIds', () {
      test('should fetch from remote when online', () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getCustomersByIds(any()),
        ).thenAnswer((_) async => SuccessState(data: [tCustomerModel]));

        final result = await repository.getCustomersByIds([tId]);

        expect(result, isA<SuccessState<List<CustomerEntity>>>());
        expect(result.data!.first.id, equals(tCustomerEntity.id));
        verify(() => mockRemoteDataSource.getCustomersByIds([tId])).called(1);
      });
    });

    group('getCustomerById', () {
      test('should fetch from remote and cache to local when online', () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getCustomerById(any()),
        ).thenAnswer((_) async => SuccessState(data: tCustomerModel));
        when(
          () => mockLocalDataSource.saveCustomer(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getCustomerById(tId);

        expect(result, isA<SuccessState<CustomerEntity>>());
        expect(result.data!.id, equals(tCustomerEntity.id));
        verify(() => mockRemoteDataSource.getCustomerById(tId)).called(1);
        verify(
          () => mockLocalDataSource.saveCustomer(tCustomerModel),
        ).called(1);
      });

      test('should fetch from local when offline', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.getCustomerById(any()),
        ).thenAnswer((_) async => SuccessState(data: tCustomerModel));

        final result = await repository.getCustomerById(tId);

        expect(result, isA<SuccessState<CustomerEntity>>());
        expect(result.data!.id, equals(tCustomerEntity.id));
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getCustomerById(tId)).called(1);
      });
    });

    group('createCustomer', () {
      test(
        'should call remote and save to local on success when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.createCustomer(any()),
          ).thenAnswer((_) async => SuccessState(data: tCustomerModel));
          when(
            () => mockLocalDataSource.saveCustomer(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.createCustomer(tCustomerEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRemoteDataSource.createCustomer(any())).called(1);
          verify(() => mockLocalDataSource.saveCustomer(any())).called(1);
        },
      );

      test('should save to local when offline', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveCustomer(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createCustomer(tCustomerEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.saveCustomer(any())).called(1);
      });
    });

    group('updateCustomer', () {
      test(
        'should call remote and save to local on success when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateCustomer(any()),
          ).thenAnswer((_) async => SuccessState(data: tCustomerModel));
          when(
            () => mockLocalDataSource.saveCustomer(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.updateCustomer(tCustomerEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRemoteDataSource.updateCustomer(any())).called(1);
          verify(() => mockLocalDataSource.saveCustomer(any())).called(1);
        },
      );

      test('should save to local when offline', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveCustomer(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.updateCustomer(tCustomerEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.saveCustomer(any())).called(1);
      });
    });

    group('deleteCustomer', () {
      test(
        'should call remote and delete from local on success when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.deleteCustomer(any()),
          ).thenAnswer((_) async => SuccessState.nil);

          when(
            () => mockLocalDataSource.deleteCustomer(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.deleteCustomer(tId);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRemoteDataSource.deleteCustomer(tId)).called(1);
          verify(() => mockLocalDataSource.deleteCustomer(tId)).called(1);
        },
      );

      test('should delete from local when offline', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.deleteCustomer(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteCustomer(tId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.deleteCustomer(tId)).called(1);
      });
    });
  });
}
