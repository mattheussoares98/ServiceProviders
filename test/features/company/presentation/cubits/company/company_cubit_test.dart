import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/update_company_logo_use_case.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

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
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;
  late MockUpdateCompanyLogoUseCase mockUpdateCompanyLogoUseCase;
  late MockPickAttachmentUseCase mockPickAttachmentUseCase;
  late CompanyCubit companyCubit;
  late UserProfileEntity userSession;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeCompanyEntity());
    registerFallbackValue(
      const PickAttachmentParams(
        source: AttachmentSource.gallery,
        workOrderId: '',
        companyId: '',
        userId: '',
        multiple: false,
      ),
    );
    registerFallbackValue(
      UpdateCompanyLogoParams(
        company: EntityFactory.makeCompanyEntity(),
        localPath: '',
      ),
    );
  });

  setUp(() {
    mockCreateCompanyUseCase = MockCreateCompanyUseCase();
    mockNavigationClient = MockNavigationClient();
    mockGetSessionUserUseCase = MockGetSessionUserUseCase();
    mockGetCompanyUseCase = MockGetCompanyUseCase();
    mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();
    mockUpdateCompanyLogoUseCase = MockUpdateCompanyLogoUseCase();
    mockPickAttachmentUseCase = MockPickAttachmentUseCase();

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
        getActiveCompanyId: mockGetActiveCompanyIdUseCase,
        updateCompanyLogo: mockUpdateCompanyLogoUseCase,
        pickAttachment: mockPickAttachmentUseCase,
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
        when(
          () => mockGetActiveCompanyIdUseCase.call(),
        ).thenReturn(userSession.companyId);
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
        when(
          () => mockGetActiveCompanyIdUseCase.call(),
        ).thenReturn(userSession.companyId);
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
        when(() => mockGetActiveCompanyIdUseCase.call()).thenReturn('');
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
        when(
          () => mockGetActiveCompanyIdUseCase.call(),
        ).thenReturn(userSession.companyId);
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

  group('changeLogo', () {
    final tCompany = EntityFactory.makeCompanyEntity();
    final tAttachment = EntityFactory.makeAttachmentEntity();

    blocTest<CompanyCubit, CompanyState>(
      'should not emit anything when company in state is null',
      build: () => companyCubit,
      act: (cubit) => cubit.changeLogo(AttachmentSource.gallery),
      expect: () => <CompanyState>[],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should show error toast and not proceed when user is not admin',
      build: () {
        when(() => mockGetSessionUserUseCase.call()).thenAnswer(
          (_) => EntityFactory.makeUserProfileEntity().copyWith(isAdmin: false),
        );
        return CompanyCubit(
          useCases: CompanyCubitUseCases(
            createCompany: mockCreateCompanyUseCase,
            getSessionUser: mockGetSessionUserUseCase,
            getCompany: mockGetCompanyUseCase,
            getActiveCompanyId: mockGetActiveCompanyIdUseCase,
            updateCompanyLogo: mockUpdateCompanyLogoUseCase,
            pickAttachment: mockPickAttachmentUseCase,
          ),
        )..emit(CompanyState(status: StateStatus.loaded, company: tCompany));
      },
      act: (cubit) => cubit.changeLogo(AttachmentSource.gallery),
      expect: () => <CompanyState>[],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit saving and loaded when pickAttachment returns empty',
      build: () {
        when(
          () => mockPickAttachmentUseCase.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: []));
        return CompanyCubit(
          useCases: CompanyCubitUseCases(
            createCompany: mockCreateCompanyUseCase,
            getSessionUser: mockGetSessionUserUseCase,
            getCompany: mockGetCompanyUseCase,
            getActiveCompanyId: mockGetActiveCompanyIdUseCase,
            updateCompanyLogo: mockUpdateCompanyLogoUseCase,
            pickAttachment: mockPickAttachmentUseCase,
          ),
        )..emit(CompanyState(status: StateStatus.loaded, company: tCompany));
      },
      act: (cubit) => cubit.changeLogo(AttachmentSource.gallery),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          StateStatus.saving,
        ),
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          StateStatus.loaded,
        ),
      ],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit saving and savingError when updateCompanyLogo fails',
      build: () {
        when(
          () => mockPickAttachmentUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: [tAttachment]));
        when(
          () => mockUpdateCompanyLogoUseCase.call(any()),
        ).thenAnswer((_) async => FailureState(message: 'Upload failed'));
        return CompanyCubit(
          useCases: CompanyCubitUseCases(
            createCompany: mockCreateCompanyUseCase,
            getSessionUser: mockGetSessionUserUseCase,
            getCompany: mockGetCompanyUseCase,
            getActiveCompanyId: mockGetActiveCompanyIdUseCase,
            updateCompanyLogo: mockUpdateCompanyLogoUseCase,
            pickAttachment: mockPickAttachmentUseCase,
          ),
        )..emit(CompanyState(status: StateStatus.loaded, company: tCompany));
      },
      act: (cubit) => cubit.changeLogo(AttachmentSource.gallery),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          StateStatus.saving,
        ),
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          StateStatus.savingError,
        ),
      ],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit saving and loaded with updated company when update succeeds',
      build: () {
        final updatedCompany = tCompany.copyWith(logoUrl: 'https://logo.png');
        when(
          () => mockPickAttachmentUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: [tAttachment]));
        when(
          () => mockUpdateCompanyLogoUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: updatedCompany));
        return CompanyCubit(
          useCases: CompanyCubitUseCases(
            createCompany: mockCreateCompanyUseCase,
            getSessionUser: mockGetSessionUserUseCase,
            getCompany: mockGetCompanyUseCase,
            getActiveCompanyId: mockGetActiveCompanyIdUseCase,
            updateCompanyLogo: mockUpdateCompanyLogoUseCase,
            pickAttachment: mockPickAttachmentUseCase,
          ),
        )..emit(CompanyState(status: StateStatus.loaded, company: tCompany));
      },
      act: (cubit) => cubit.changeLogo(AttachmentSource.gallery),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          StateStatus.saving,
        ),
        isA<CompanyState>()
            .having((state) => state.status, 'status', StateStatus.loaded)
            .having(
              (state) => state.company?.logoUrl,
              'logoUrl',
              'https://logo.png',
            ),
      ],
    );
  });
}
