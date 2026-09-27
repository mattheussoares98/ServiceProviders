import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/create_customer_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/delete_customer_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/get_customer_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/get_customers_by_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/get_customers_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/update_customer_use_case.dart';

import '../../../../../testing/mocks/factories/customer_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockCustomersRepository mockRepository;

  late CreateCustomerUseCase createCustomerUseCase;
  late UpdateCustomerUseCase updateCustomerUseCase;
  late DeleteCustomerUseCase deleteCustomerUseCase;
  late GetCustomersUseCase getCustomersUseCase;
  late GetCustomersByIdsUseCase getCustomersByIdsUseCase;
  late GetCustomerByIdUseCase getCustomerByIdUseCase;

  setUpAll(() {
    registerFallbackValue(CustomerFactory.makeCustomerEntity());
  });

  setUp(() {
    mockRepository = MockCustomersRepository();
    createCustomerUseCase = CreateCustomerUseCase(
      customersRepository: mockRepository,
    );
    updateCustomerUseCase = UpdateCustomerUseCase(
      customersRepository: mockRepository,
    );
    deleteCustomerUseCase = DeleteCustomerUseCase(
      customersRepository: mockRepository,
    );
    getCustomersUseCase = GetCustomersUseCase(
      customersRepository: mockRepository,
    );
    getCustomersByIdsUseCase = GetCustomersByIdsUseCase(
      customersRepository: mockRepository,
    );
    getCustomerByIdUseCase = GetCustomerByIdUseCase(
      customersRepository: mockRepository,
    );
  });

  final tCustomerEntity = CustomerFactory.makeCustomerEntity();
  final tCustomerList = CustomerFactory.makeCustomerEntityList();
  final tId = faker.guid.guid();

  group('Customers Use Cases', () {
    group('CreateCustomerUseCase', () {
      test(
        'should call repository.createCustomer and return SuccessState',
        () async {
          when(
            () => mockRepository.createCustomer(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await createCustomerUseCase(tCustomerEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRepository.createCustomer(tCustomerEntity),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(
          () => mockRepository.createCustomer(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        final result = await createCustomerUseCase(tCustomerEntity);

        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.createCustomer(tCustomerEntity)).called(1);
      });
    });

    group('UpdateCustomerUseCase', () {
      test(
        'should call repository.updateCustomer and return SuccessState',
        () async {
          when(
            () => mockRepository.updateCustomer(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await updateCustomerUseCase(tCustomerEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRepository.updateCustomer(tCustomerEntity),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(
          () => mockRepository.updateCustomer(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        final result = await updateCustomerUseCase(tCustomerEntity);

        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.updateCustomer(tCustomerEntity)).called(1);
      });
    });

    group('DeleteCustomerUseCase', () {
      test(
        'should call repository.deleteCustomer and return SuccessState',
        () async {
          when(
            () => mockRepository.deleteCustomer(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await deleteCustomerUseCase(tId);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRepository.deleteCustomer(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(
          () => mockRepository.deleteCustomer(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        final result = await deleteCustomerUseCase(tId);

        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.deleteCustomer(tId)).called(1);
      });
    });

    group('GetCustomersUseCase', () {
      test(
        'should call repository.getCustomers and return list of customers',
        () async {
          when(
            () => mockRepository.getCustomers(any()),
          ).thenAnswer((_) async => SuccessState(data: tCustomerList));

          final result = await getCustomersUseCase(tId);

          expect(result, isA<SuccessState<List<CustomerEntity>>>());
          expect(result.data, equals(tCustomerList));
          verify(() => mockRepository.getCustomers(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(() => mockRepository.getCustomers(any())).thenAnswer(
          (_) async => FailureState<List<CustomerEntity>>(message: 'Error'),
        );

        final result = await getCustomersUseCase(tId);

        expect(result, isA<FailureState<List<CustomerEntity>>>());
        verify(() => mockRepository.getCustomers(tId)).called(1);
      });
    });

    group('GetCustomersByIdsUseCase', () {
      test(
        'should call repository.getCustomersByIds and return list of customers',
        () async {
          when(
            () => mockRepository.getCustomersByIds(any()),
          ).thenAnswer((_) async => SuccessState(data: tCustomerList));

          final result = await getCustomersByIdsUseCase([tId]);

          expect(result, isA<SuccessState<List<CustomerEntity>>>());
          expect(result.data, equals(tCustomerList));
          verify(() => mockRepository.getCustomersByIds([tId])).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(() => mockRepository.getCustomersByIds(any())).thenAnswer(
          (_) async => FailureState<List<CustomerEntity>>(message: 'Error'),
        );

        final result = await getCustomersByIdsUseCase([tId]);

        expect(result, isA<FailureState<List<CustomerEntity>>>());
        verify(() => mockRepository.getCustomersByIds([tId])).called(1);
      });
    });

    group('GetCustomerByIdUseCase', () {
      test(
        'should call repository.getCustomerById and return CustomerEntity',
        () async {
          when(
            () => mockRepository.getCustomerById(any()),
          ).thenAnswer((_) async => SuccessState(data: tCustomerEntity));

          final result = await getCustomerByIdUseCase(tId);

          expect(result, isA<SuccessState<CustomerEntity>>());
          expect(result.data, equals(tCustomerEntity));
          verify(() => mockRepository.getCustomerById(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(() => mockRepository.getCustomerById(any())).thenAnswer(
          (_) async => FailureState<CustomerEntity>(message: 'Error'),
        );

        final result = await getCustomerByIdUseCase(tId);

        expect(result, isA<FailureState<CustomerEntity>>());
        verify(() => mockRepository.getCustomerById(tId)).called(1);
      });
    });
  });
}
