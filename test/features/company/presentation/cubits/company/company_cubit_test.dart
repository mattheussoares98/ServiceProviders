import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit_use_cases.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
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
  late CompanyCubit companyCubit;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeCompanyEntity());
  });

  setUp(() {
    mockCreateCompanyUseCase = MockCreateCompanyUseCase();
    mockNavigationClient = MockNavigationClient();

    locator
      ..registerSingleton<CreateCompanyUseCase>(mockCreateCompanyUseCase)
      ..registerSingleton<NavigationClient>(mockNavigationClient);

    when(
      () => mockNavigationClient.maybePop<CompanyEntity>(any()),
    ).thenAnswer((_) async => true);

    companyCubit = CompanyCubit(
      useCases: CompanyCubitUseCases(createCompany: mockCreateCompanyUseCase),
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
}
