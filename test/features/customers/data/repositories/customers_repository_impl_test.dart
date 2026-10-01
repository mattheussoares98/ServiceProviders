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
import '../../../../../testing/mocks/factories/system_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockCustomersRemoteDataSource mockRemoteDataSource;
  late MockCustomersLocalDataSource mockLocalDataSource;
  late MockSyncRepository mockSyncRepository;
  late MockSessionRepository mockSessionRepository;
  late CustomersRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      CustomerModel.fromEntity(CustomerFactory.makeCustomerEntity()),
    );
    registerFallbackValue(<CustomerModel>[]);
    registerFallbackValue(SystemFactory.makeSyncQueueItemEntity());
  });

  final tCompanyId = faker.guid.guid();
  final tId = faker.guid.guid();

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockCustomersRemoteDataSource();
    mockLocalDataSource = MockCustomersLocalDataSource();
    mockSyncRepository = MockSyncRepository();
    mockSessionRepository = MockSessionRepository();

    when(
      () => mockSessionRepository.userData,
    ).thenReturn(UserFactory.makeUserDataEntity());
    when(
      () => mockSessionRepository.getSelectedCompanyId(),
    ).thenReturn(tCompanyId);
    when(
      () => mockSyncRepository.enqueue(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));

    repository = CustomersRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      syncRepository: mockSyncRepository,
      sessionRepository: mockSessionRepository,
    );
  });

  final tCustomerEntity = CustomerFactory.makeCustomerEntity();
  final tCustomerModel = CustomerModel.fromEntity(tCustomerEntity);

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
          verifyZeroInteractions(mockSyncRepository);
        },
      );

      test(
        'should save to local and enqueue to sync repository when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.saveCustomer(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.createCustomer(tCustomerEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.saveCustomer(any())).called(1);
          verify(() => mockSyncRepository.enqueue(any())).called(1);
        },
      );
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
          verifyZeroInteractions(mockSyncRepository);
        },
      );

      test(
        'should save to local and enqueue to sync repository when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.saveCustomer(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.updateCustomer(tCustomerEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.saveCustomer(any())).called(1);
          verify(() => mockSyncRepository.enqueue(any())).called(1);
        },
      );
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
          verifyZeroInteractions(mockSyncRepository);
        },
      );

      test(
        'should delete from local and enqueue to sync repository when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.deleteCustomer(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.deleteCustomer(tId);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.deleteCustomer(tId)).called(1);
          verify(() => mockSyncRepository.enqueue(any())).called(1);
        },
      );
    });

    group('hasNonDeletedCustomers', () {
      test('should call remoteDataSource when online', () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.hasNonDeletedCustomers(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.hasNonDeletedCustomers(tCompanyId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(
          () => mockRemoteDataSource.hasNonDeletedCustomers(tCompanyId),
        ).called(1);
        verifyZeroInteractions(mockLocalDataSource);
      });

      test('should call localDataSource when offline', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.hasNonDeletedCustomers(any()),
        ).thenAnswer((_) async => const SuccessState(data: false));

        final result = await repository.hasNonDeletedCustomers(tCompanyId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isFalse);
        verify(
          () => mockLocalDataSource.hasNonDeletedCustomers(tCompanyId),
        ).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
      });
    });
  });
}
