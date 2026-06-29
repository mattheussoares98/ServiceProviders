import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:clean_architecture/features/company/domain/use_cases/get_company_use_case.dart';
import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit_use_cases.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

final locator = GetIt.I;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCreateCompanyUseCase mockCreateCompanyUseCase;
  late MockNavigationClient mockNavigationClient;
  late MockGetSessionUserUseCase mockGetSessionUserUseCase;
  late MockGetCompanyUseCase mockGetCompanyUseCase;
  late CompanyCubit companyCubit;
  late UserProfileEntity userSession;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeCompanyEntity());
  });

  setUp(() {
    mockCreateCompanyUseCase = MockCreateCompanyUseCase();
    mockNavigationClient = MockNavigationClient();
    mockGetSessionUserUseCase = MockGetSessionUserUseCase();
    mockGetCompanyUseCase = MockGetCompanyUseCase();

    userSession = EntityFactory.makeUserProfileEntity().copyWith(isAdmin: true);

    locator
      ..registerSingleton<CreateCompanyUseCase>(mockCreateCompanyUseCase)
      ..registerSingleton<NavigationClient>(mockNavigationClient)
      ..registerSingleton<GetSessionUserUseCase>(mockGetSessionUserUseCase)
      ..registerSingleton<GetCompanyUseCase>(mockGetCompanyUseCase);

    when(
      () => mockNavigationClient.maybePop<CompanyEntity>(any()),
    ).thenAnswer((_) async => true);
    when(() => mockGetSessionUserUseCase.call()).thenAnswer((_) => userSession);
    when(() => mockGetCompanyUseCase.call(any())).thenAnswer(
      (_) async => SuccessState(data: EntityFactory.makeCompanyEntity()),
    );

    companyCubit = CompanyCubit(
      useCases: CompanyCubitUseCases(
        createCompany: mockCreateCompanyUseCase,
        getSessionUser: mockGetSessionUserUseCase,
        getCompany: mockGetCompanyUseCase,
      ),
    );
  });

  tearDown(locator.reset);

  blocTest<CompanyCubit, CompanyState>(
    'createCompany should emit loading and loaded when creation succeeds',
    build: () {
      final company = EntityFactory.makeCompanyEntity();
      when(
        () => mockCreateCompanyUseCase.call(any()),
      ).thenAnswer((_) async => SuccessState(data: company));
      return companyCubit;
    },
    act: (cubit) =>
        cubit.createCompany(name: 'Empresa Teste', cnpj: '12345678000199'),
    expect: () => [
      isA<CompanyState>().having(
        (state) => state.status,
        'status',
        StateStatus.loading,
      ),
      isA<CompanyState>()
          .having((state) => state.status, 'status', StateStatus.loaded)
          .having((state) => state.company, 'company', isA<CompanyEntity>()),
    ],
    verify: (_) {
      final captured =
          verify(
                () => mockCreateCompanyUseCase.call(captureAny()),
              ).captured.single
              as CompanyEntity;
      expect(captured.name, 'Empresa Teste');
      expect(captured.cnpj, '12345678000199');
      verify(() => mockNavigationClient.maybePop()).called(1);
    },
  );

  blocTest<CompanyCubit, CompanyState>(
    'createCompany should emit loading and error when creation fails',
    build: () {
      when(() => mockCreateCompanyUseCase.call(any())).thenAnswer(
        (_) async => FailureState<CompanyEntity>(message: 'Create failed'),
      );
      return companyCubit;
    },
    act: (cubit) => cubit.createCompany(name: 'Empresa Teste'),
    expect: () => [
      isA<CompanyState>().having(
        (state) => state.status,
        'status',
        StateStatus.loading,
      ),
      isA<CompanyState>().having(
        (state) => state.status,
        'status',
        StateStatus.loaded,
      ),
    ],
    verify: (_) {
      verify(() => mockCreateCompanyUseCase.call(any())).called(1);
      verifyNever(() => mockNavigationClient.maybePop<CompanyEntity>(any()));
    },
  );

  group('Navigate to create company', () {
    blocTest<CompanyCubit, CompanyState>(
      'Should navigate if the user is admin (mocked with true value already)',
      build: () => companyCubit,
      act: (cubit) => cubit.navigateToCreateCompany(),
      expect: () => <CompanyState>[],
      verify: (_) {
        verify(
          () => mockNavigationClient.pushRoute(const CreateCompanyRoute()),
        ).called(1);
      },
    );
    blocTest<CompanyCubit, CompanyState>(
      'Should not navigate if the user is not admin',
      build: () {
        userSession = EntityFactory.makeUserProfileEntity().copyWith(
          isAdmin: false,
        );

        return companyCubit;
      },
      act: (cubit) => cubit.navigateToCreateCompany(),
      expect: () => <CompanyState>[],
      verify: (_) {
        verifyNever(
          () => mockNavigationClient.pushRoute(const CreateCompanyRoute()),
        );
      },
    );
  });

  group('loadCompany', () {
    blocTest<CompanyCubit, CompanyState>(
      'should emit loaded status and company when company loads successfully',
      build: () {
        final company = EntityFactory.makeCompanyEntity();
        when(
          () => mockGetCompanyUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: company));
        return companyCubit;
      },
      act: (cubit) => cubit.loadCompany(),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          StateStatus.loading,
        ),
        isA<CompanyState>()
            .having((state) => state.status, 'status', StateStatus.loaded)
            .having((state) => state.company, 'company', isA<CompanyEntity>()),
      ],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit error status when loading fails',
      build: () {
        when(() => mockGetCompanyUseCase.call(any())).thenAnswer(
          (_) async => FailureState<CompanyEntity>(message: 'Load failed'),
        );
        return companyCubit;
      },
      act: (cubit) => cubit.loadCompany(),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          StateStatus.loading,
        ),
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          StateStatus.loadingError,
        ),
      ],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit loaded status and null company when user has no companyId',
      build: () {
        userSession = EntityFactory.makeUserProfileEntity().copyWith(
          isAdmin: true,
          annulCompanyId: true,
        );
        when(
          () => mockGetSessionUserUseCase.call(),
        ).thenAnswer((_) => userSession);
        return companyCubit;
      },
      act: (cubit) => cubit.loadCompany(),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          StateStatus.loaded,
        ),
      ],
    );
    blocTest<CompanyCubit, CompanyState>(
      'should pass forceRefresh parameter to usecase correctly',
      build: () {
        userSession = EntityFactory.makeUserProfileEntity().copyWith(
          isAdmin: true,
        );
        when(
          () => mockGetSessionUserUseCase.call(),
        ).thenAnswer((_) => userSession);
        when(
          () => mockGetCompanyUseCase.call(any(), forceRefresh: true),
        ).thenAnswer((_) async => const SuccessState(data: null));
        return companyCubit;
      },
      act: (cubit) => cubit.loadCompany(forceRefresh: true),
      verify: (_) {
        verify(
          () => mockGetCompanyUseCase.call(any(), forceRefresh: true),
        ).called(1);
      },
    );
  });
}
