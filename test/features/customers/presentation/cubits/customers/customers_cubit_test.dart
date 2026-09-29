import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/factories/asset_factory.dart';
import '../../../../../../testing/mocks/factories/customer_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetCustomersUseCase mockGetCustomers;
  late MockGetCustomerByIdUseCase mockGetCustomerById;
  late MockCreateCustomerUseCase mockCreateCustomer;
  late MockUpdateCustomerUseCase mockUpdateCustomer;
  late MockDeleteCustomerUseCase mockDeleteCustomer;
  late MockGetAddressByCepUseCase mockGetAddressByCep;
  late MockNavigationClient mockNavigationClient;

  late CustomersCubit cubit;
  late CustomerEntity tCustomer;
  const tCompanyId = 'company-123';

  setUpAll(() {
    registerFallbackValue(CustomerFactory.makeCustomerEntity());
  });

  setUp(() {
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockGetCustomers = MockGetCustomersUseCase();
    mockGetCustomerById = MockGetCustomerByIdUseCase();
    mockCreateCustomer = MockCreateCustomerUseCase();
    mockUpdateCustomer = MockUpdateCustomerUseCase();
    mockDeleteCustomer = MockDeleteCustomerUseCase();
    mockGetAddressByCep = MockGetAddressByCepUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tCustomer = CustomerFactory.makeCustomerEntity().copyWith(
      companyId: tCompanyId,
      document: '12345678901',
    );

    when(() => mockGetActiveCompanyId.call()).thenReturn(tCompanyId);

    final useCases = CustomersCubitUseCases(
      getActiveCompanyId: mockGetActiveCompanyId,
      getCustomers: mockGetCustomers,
      getCustomerById: mockGetCustomerById,
      createCustomer: mockCreateCustomer,
      updateCustomer: mockUpdateCustomer,
      deleteCustomer: mockDeleteCustomer,
      getAddressByCep: mockGetAddressByCep,
    );

    cubit = CustomersCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('CustomersCubit Tests', () {
    group('loadCustomers', () {
      blocTest<CustomersCubit, CustomersState>(
        'should emit running and success when customers load successfully',
        build: () {
          final tCustomers = [tCustomer];
          when(
            () => mockGetCustomers.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tCustomers));
          return cubit;
        },
        act: (cubit) => cubit.loadCustomers(),
        expect: () => [
          isA<CustomersState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<CustomersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.customers, 'customers', [tCustomer]),
        ],
        verify: (_) {
          verify(() => mockGetCustomers.call(tCompanyId)).called(1);
        },
      );

      blocTest<CustomersCubit, CustomersState>(
        'should not emit running when emitLoading is false',
        build: () {
          final tCustomers = [tCustomer];
          when(
            () => mockGetCustomers.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tCustomers));
          return cubit;
        },
        act: (cubit) => cubit.loadCustomers(emitLoading: false),
        expect: () => [
          isA<CustomersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.customers, 'customers', [tCustomer]),
        ],
        verify: (_) {
          verify(() => mockGetCustomers.call(tCompanyId)).called(1);
        },
      );

      blocTest<CustomersCubit, CustomersState>(
        'should emit running and error when getCustomers fails',
        build: () {
          when(
            () => mockGetCustomers.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Network error'));
          return cubit;
        },
        act: (cubit) => cubit.loadCustomers(),
        expect: () => [
          isA<CustomersState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<CustomersState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.error('Network error'),
          ),
        ],
      );
    });

    group('saveCustomer', () {
      blocTest<CustomersCubit, CustomersState>(
        'should reject empty name without calling use case',
        build: () => cubit,
        act: (cubit) async {
          final result = await cubit.saveCustomer(id: null, name: '   ');
          expect(result, isFalse);
        },
        expect: () => [
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.save],
            'sections[save]',
            isA<SectionState>().having(
              (s) => s.status,
              'status',
              SectionStatus.error,
            ),
          ),
        ],
        verify: (_) {
          verifyNever(() => mockCreateCustomer.call(any()));
        },
      );

      blocTest<CustomersCubit, CustomersState>(
        'should reject document with invalid length',
        build: () => cubit,
        act: (cubit) async {
          final result = await cubit.saveCustomer(
            id: null,
            name: 'Customer Valid',
            document: '12345',
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.save],
            'sections[save]',
            isA<SectionState>().having(
              (s) => s.status,
              'status',
              SectionStatus.error,
            ),
          ),
        ],
        verify: (_) {
          verifyNever(() => mockCreateCustomer.call(any()));
        },
      );

      blocTest<CustomersCubit, CustomersState>(
        'should reject duplicate document already existing in state',
        seed: () => cubit.state.copyWith(customers: [tCustomer]),
        build: () => cubit,
        act: (cubit) async {
          final result = await cubit.saveCustomer(
            id: null,
            name: 'Another Customer',
            document: tCustomer.document,
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.save],
            'sections[save]',
            isA<SectionState>().having(
              (s) => s.status,
              'status',
              SectionStatus.error,
            ),
          ),
        ],
        verify: (_) {
          verifyNever(() => mockCreateCustomer.call(any()));
        },
      );

      blocTest<CustomersCubit, CustomersState>(
        'should call createCustomer when id is null, emit running/success, and reload',
        build: () {
          when(
            () => mockCreateCustomer.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetCustomers.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tCustomer]));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.saveCustomer(
            id: null,
            name: tCustomer.name,
            document: tCustomer.document,
            contactName: tCustomer.contactName,
            contactEmail: tCustomer.contactEmail,
            contactPhone: tCustomer.contactPhone,
            address: tCustomer.address,
            number: tCustomer.number,
            complement: tCustomer.complement,
            neighborhood: tCustomer.neighborhood,
            city: tCustomer.city,
            stateAddress: tCustomer.state,
            postalCode: tCustomer.postalCode,
            notes: tCustomer.notes,
            isActive: tCustomer.isActive,
            createdAt: tCustomer.createdAt,
          );
          expect(result, isTrue);
        },
        verify: (_) {
          final captured =
              verify(
                    () => mockCreateCustomer.call(captureAny()),
                  ).captured.single
                  as CustomerEntity;
          expect(captured.id, isNotEmpty);
          expect(captured.companyId, tCompanyId);
          expect(captured.name, tCustomer.name);
          expect(captured.document, tCustomer.document);
          verify(() => mockGetCustomers.call(tCompanyId)).called(1);
        },
        expect: () => [
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.save],
            'sections[save]',
            const SectionState.running(),
          ),
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.save],
            'sections[save]',
            const SectionState.success(),
          ),
          isA<CustomersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.customers, 'customers', [tCustomer]),
        ],
      );

      blocTest<CustomersCubit, CustomersState>(
        'should call updateCustomer when id is provided, emit running/success, and reload',
        build: () {
          when(
            () => mockUpdateCustomer.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetCustomers.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tCustomer]));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.saveCustomer(
            id: tCustomer.id,
            name: tCustomer.name,
            document: tCustomer.document,
          );
          expect(result, isTrue);
        },
        verify: (_) {
          final captured =
              verify(
                    () => mockUpdateCustomer.call(captureAny()),
                  ).captured.single
                  as CustomerEntity;
          expect(captured.id, tCustomer.id);
          expect(captured.companyId, tCompanyId);
          expect(captured.name, tCustomer.name);
          verify(() => mockGetCustomers.call(tCompanyId)).called(1);
        },
        expect: () => [
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.save],
            'sections[save]',
            const SectionState.running(),
          ),
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.save],
            'sections[save]',
            const SectionState.success(),
          ),
          isA<CustomersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.customers, 'customers', [tCustomer]),
        ],
      );

      blocTest<CustomersCubit, CustomersState>(
        'should emit error when createCustomer fails',
        build: () {
          when(
            () => mockCreateCustomer.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Creation failed'));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.saveCustomer(
            id: null,
            name: tCustomer.name,
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.save],
            'sections[save]',
            const SectionState.running(),
          ),
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.save],
            'sections[save]',
            const SectionState.error(),
          ),
        ],
        verify: (_) {
          verifyNever(() => mockGetCustomers.call(any()));
        },
      );
    });

    group('deleteCustomer', () {
      blocTest<CustomersCubit, CustomersState>(
        'should call deleteCustomer, update local list, and reload on success',
        seed: () => cubit.state.copyWith(customers: [tCustomer]),
        build: () {
          when(
            () => mockDeleteCustomer.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetCustomers.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.deleteCustomer(tCustomer.id);
          expect(result, isTrue);
        },
        verify: (_) {
          verify(() => mockDeleteCustomer.call(tCustomer.id)).called(1);
          verify(() => mockGetCustomers.call(tCompanyId)).called(1);
        },
        expect: () => [
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.delete],
            'sections[delete]',
            const SectionState.running(),
          ),
          isA<CustomersState>()
              .having(
                (s) => s.sections[CustomersSections.delete],
                'sections[delete]',
                const SectionState.success(),
              )
              .having((s) => s.customers, 'customers', isEmpty),
          isA<CustomersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.customers, 'customers', isEmpty),
        ],
      );

      blocTest<CustomersCubit, CustomersState>(
        'should emit error when deleteCustomer fails',
        seed: () => cubit.state.copyWith(customers: [tCustomer]),
        build: () {
          when(
            () => mockDeleteCustomer.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Deletion failed'));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.deleteCustomer(tCustomer.id);
          expect(result, isFalse);
        },
        verify: (_) {
          verify(() => mockDeleteCustomer.call(tCustomer.id)).called(1);
          verifyNever(() => mockGetCustomers.call(any()));
        },
        expect: () => [
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.delete],
            'sections[delete]',
            const SectionState.running(),
          ),
          isA<CustomersState>().having(
            (s) => s.sections[CustomersSections.delete],
            'sections[delete]',
            const SectionState.error(),
          ),
        ],
      );
    });

    group('getAddressByCep', () {
      final tAddress = AssetFactory.makeAddressEntity();

      test('should return null when cep is invalid length', () async {
        final result = await cubit.getAddressByCep('123');
        expect(result, isNull);
        verifyNever(() => mockGetAddressByCep.call(any()));
      });

      test(
        'should emit running and success and return address on success',
        () async {
          when(
            () => mockGetAddressByCep.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAddress));

          final result = await cubit.getAddressByCep('01001-000');

          expect(result, tAddress);
          expect(
            cubit.state.sections[CustomersSections.loadAddressByCep],
            const SectionState.success(),
          );
          verify(() => mockGetAddressByCep.call('01001000')).called(1);
        },
      );

      test('should emit error and return null on failure', () async {
        when(
          () => mockGetAddressByCep.call(any()),
        ).thenAnswer((_) async => FailureState(message: 'CEP not found'));

        final result = await cubit.getAddressByCep('01001-000');

        expect(result, isNull);
        expect(
          cubit.state.sections[CustomersSections.loadAddressByCep],
          const SectionState.error(),
        );
      });
    });

    group('popRoute', () {
      test('should call maybePop on navigation client', () {
        when(
          () => mockNavigationClient.maybePop(),
        ).thenAnswer((_) async => true);
        cubit.popRoute();
        verify(() => mockNavigationClient.maybePop()).called(1);
      });
    });
  });
}
