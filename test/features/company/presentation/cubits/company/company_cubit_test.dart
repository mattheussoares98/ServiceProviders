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
  late MockGetAllCompaniesUseCase mockGetAllCompaniesUseCase;
  late MockSetSelectedCompanyIdUseCase mockSetSelectedCompanyIdUseCase;
  late MockUpdateUserProfileUseCase mockUpdateUserProfileUseCase;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;
  late MockUpdateCompanyLogoUseCase mockUpdateCompanyLogoUseCase;
  late MockPickAttachmentUseCase mockPickAttachmentUseCase;
  late MockGetCompanyParametersUseCase mockGetCompanyParametersUseCase;
  late MockSaveCompanyParametersUseCase mockSaveCompanyParametersUseCase;
  late MockGetPermissionGroupsUseCase mockGetPermissionGroupsUseCase;
  late CompanyCubit companyCubit;
  late UserProfileEntity userSession;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeCompanyEntity());
    registerFallbackValue(EntityFactory.makeUserProfileEntity());
    registerFallbackValue(EntityFactory.makeCompanyParameterEntity());
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
    mockGetAllCompaniesUseCase = MockGetAllCompaniesUseCase();
    mockSetSelectedCompanyIdUseCase = MockSetSelectedCompanyIdUseCase();
    mockUpdateUserProfileUseCase = MockUpdateUserProfileUseCase();
    mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();
    mockUpdateCompanyLogoUseCase = MockUpdateCompanyLogoUseCase();
    mockPickAttachmentUseCase = MockPickAttachmentUseCase();
    mockGetCompanyParametersUseCase = MockGetCompanyParametersUseCase();
    mockSaveCompanyParametersUseCase = MockSaveCompanyParametersUseCase();
    mockGetPermissionGroupsUseCase = MockGetPermissionGroupsUseCase();

    userSession = EntityFactory.makeUserProfileEntity().copyWith(
      isAdmin: true,
      email: 'regular@example.com',
    );

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
    when(() => mockGetAllCompaniesUseCase.call()).thenAnswer(
      (_) async => SuccessState(data: EntityFactory.makeCompanyEntityList()),
    );
    when(
      () => mockSetSelectedCompanyIdUseCase.call(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockUpdateUserProfileUseCase.call(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(() => mockGetCompanyParametersUseCase.call(any())).thenAnswer(
      (_) async =>
          SuccessState(data: EntityFactory.makeCompanyParameterEntity()),
    );
    when(
      () => mockSaveCompanyParametersUseCase.call(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockGetPermissionGroupsUseCase.call(any()),
    ).thenAnswer((_) async => const SuccessState(data: []));

    companyCubit = CompanyCubit(
      useCases: CompanyCubitUseCases(
        createCompany: mockCreateCompanyUseCase,
        getSessionUser: mockGetSessionUserUseCase,
        getCompany: mockGetCompanyUseCase,
        getAllCompanies: mockGetAllCompaniesUseCase,
        setSelectedCompanyId: mockSetSelectedCompanyIdUseCase,
        updateUserProfile: mockUpdateUserProfileUseCase,
        getActiveCompanyId: mockGetActiveCompanyIdUseCase,
        updateCompanyLogo: mockUpdateCompanyLogoUseCase,
        pickAttachment: mockPickAttachmentUseCase,
        getCompanyParameters: mockGetCompanyParametersUseCase,
        saveCompanyParameters: mockSaveCompanyParametersUseCase,
        getPermissionGroups: mockGetPermissionGroupsUseCase,
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
        DataStatus.loading,
      ),
      isA<CompanyState>()
          .having((state) => state.status, 'status', DataStatus.loaded)
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
        DataStatus.loading,
      ),
      isA<CompanyState>().having(
        (state) => state.status,
        'status',
        DataStatus.loaded,
      ),
    ],
    verify: (_) {
      verify(() => mockCreateCompanyUseCase.call(any())).called(1);
      verifyNever(() => mockNavigationClient.maybePop<CompanyEntity>(any()));
    },
  );

  group('Navigate to create company', () {
    blocTest<CompanyCubit, CompanyState>(
      'Should navigate if the user is super admin',
      build: () {
        userSession = EntityFactory.makeUserProfileEntity().copyWith(
          email: 'mattheussbarosa98@gmail.com',
        );
        return companyCubit;
      },
      act: (cubit) => cubit.navigateToCreateCompany(),
      expect: () => <CompanyState>[],
      verify: (_) {
        verify(
          () => mockNavigationClient.pushRoute(const CreateCompanyRoute()),
        ).called(1);
      },
    );
    blocTest<CompanyCubit, CompanyState>(
      'Should not navigate if the user is not super admin',
      build: () {
        userSession = EntityFactory.makeUserProfileEntity().copyWith(
          email: 'regular_user@example.com',
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
          DataStatus.loading,
        ),
        isA<CompanyState>()
            .having((state) => state.status, 'status', DataStatus.loaded)
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
          DataStatus.loading,
        ),
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          DataStatus.loadingError,
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
          DataStatus.loading,
        ),
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          DataStatus.loaded,
        ),
      ],
    );
    blocTest<CompanyCubit, CompanyState>(
      'should pass forceRefresh parameter to usecase correctly',
      build: () {
        userSession = EntityFactory.makeUserProfileEntity().copyWith(
          isAdmin: true,
          email: 'regular@example.com',
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

    blocTest<CompanyCubit, CompanyState>(
      'should call getAllCompanies when user is super admin',
      build: () {
        final superAdmin = EntityFactory.makeUserProfileEntity().copyWith(
          email: 'mattheussbarosa98@gmail.com',
        );
        final companies = EntityFactory.makeCompanyEntityList();
        when(() => mockGetSessionUserUseCase.call()).thenReturn(superAdmin);
        when(
          () => mockGetAllCompaniesUseCase.call(),
        ).thenAnswer((_) async => SuccessState(data: companies));
        when(
          () => mockGetActiveCompanyIdUseCase.call(),
        ).thenReturn(companies.first.id);
        return companyCubit;
      },
      act: (cubit) => cubit.loadCompany(),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          DataStatus.loading,
        ),
        isA<CompanyState>()
            .having((state) => state.status, 'status', DataStatus.loaded)
            .having((state) => state.companies.length, 'companies.length', 3)
            .having((state) => state.company?.id, 'company.id', isNotEmpty),
      ],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit loadingError when getAllCompanies fails for super admin',
      build: () {
        final superAdmin = EntityFactory.makeUserProfileEntity().copyWith(
          email: 'mattheussbarosa98@gmail.com',
        );
        when(() => mockGetSessionUserUseCase.call()).thenReturn(superAdmin);
        when(
          () => mockGetAllCompaniesUseCase.call(),
        ).thenAnswer((_) async => FailureState(message: 'Failed to load all'));
        return companyCubit;
      },
      act: (cubit) => cubit.loadCompany(),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          DataStatus.loading,
        ),
        isA<CompanyState>().having(
          (state) => state.status,
          'status',
          DataStatus.loadingError,
        ),
      ],
    );
  });

  group('switchCompany', () {
    final companies = EntityFactory.makeCompanyEntityList();

    blocTest<CompanyCubit, CompanyState>(
      'should do nothing when user is not super admin',
      build: () {
        final regularUser = EntityFactory.makeUserProfileEntity().copyWith(
          email: 'regular@example.com',
        );
        when(() => mockGetSessionUserUseCase.call()).thenReturn(regularUser);
        return companyCubit;
      },
      act: (cubit) => cubit.switchCompany('target_company_id'),
      expect: () => <CompanyState>[],
      verify: (_) {
        verifyNever(() => mockUpdateUserProfileUseCase.call(any()));
        verifyNever(() => mockSetSelectedCompanyIdUseCase.call(any()));
      },
    );

    blocTest<CompanyCubit, CompanyState>(
      'should call updateUserProfile and setSelectedCompanyId and update company in state when user is super admin and update succeeds',
      build: () {
        final superAdmin = EntityFactory.makeUserProfileEntity().copyWith(
          email: 'mattheussbarosa98@gmail.com',
        );
        when(() => mockGetSessionUserUseCase.call()).thenReturn(superAdmin);
        when(
          () => mockUpdateUserProfileUseCase.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockSetSelectedCompanyIdUseCase.call(any()),
        ).thenAnswer((_) async {});
        return companyCubit..emit(
          CompanyState(
            status: DataStatus.loaded,
            companies: companies,
            company: companies.first,
          ),
        );
      },
      act: (cubit) => cubit.switchCompany(companies[1].id),
      expect: () => [
        isA<CompanyState>().having(
          (s) => s.sections[CompanySections.switchCompany],
          'sections[switchCompany]',
          SectionStatus.running,
        ),
        isA<CompanyState>()
            .having(
              (s) => s.sections[CompanySections.switchCompany],
              'sections[switchCompany]',
              SectionStatus.success,
            )
            .having(
              (s) => s.selectedCompanyId,
              'selectedCompanyId',
              companies[1].id,
            )
            .having((s) => s.company?.id, 'company.id', companies[1].id),
      ],
      verify: (_) {
        verify(() => mockUpdateUserProfileUseCase.call(any())).called(1);
        verify(
          () => mockSetSelectedCompanyIdUseCase.call(companies[1].id),
        ).called(1);
      },
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit error when updateUserProfile fails',
      build: () {
        final superAdmin = EntityFactory.makeUserProfileEntity().copyWith(
          email: 'mattheussbarosa98@gmail.com',
        );
        when(() => mockGetSessionUserUseCase.call()).thenReturn(superAdmin);
        when(
          () => mockUpdateUserProfileUseCase.call(any()),
        ).thenAnswer((_) async => FailureState(message: 'Failed'));
        return companyCubit..emit(
          CompanyState(
            status: DataStatus.loaded,
            companies: companies,
            company: companies.first,
          ),
        );
      },
      act: (cubit) => cubit.switchCompany(companies[1].id),
      expect: () => [
        isA<CompanyState>().having(
          (s) => s.sections[CompanySections.switchCompany],
          'sections[switchCompany]',
          SectionStatus.running,
        ),
        isA<CompanyState>().having(
          (s) => s.sections[CompanySections.switchCompany],
          'sections[switchCompany]',
          SectionStatus.error,
        ),
      ],
    );
  });

  group('changeLogo', () {
    final tCompany = EntityFactory.makeCompanyEntity();
    final tAttachment = EntityFactory.makeAttachmentEntity().copyWith(
      localPath: '/tmp/logo.png',
    );

    blocTest<CompanyCubit, CompanyState>(
      'should do nothing when company in state is null',
      build: () => companyCubit,
      act: (cubit) => cubit.changeLogo(AttachmentSource.gallery),
      expect: () => <CompanyState>[],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should do nothing when user is not admin',
      build: () {
        when(() => mockGetSessionUserUseCase.call()).thenAnswer(
          (_) => EntityFactory.makeUserProfileEntity().copyWith(isAdmin: false),
        );
        return companyCubit
          ..emit(CompanyState(status: DataStatus.loaded, company: tCompany));
      },
      act: (cubit) => cubit.changeLogo(AttachmentSource.gallery),
      expect: () => <CompanyState>[],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit running and idle when pickAttachment returns empty',
      build: () {
        when(
          () => mockPickAttachmentUseCase.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: []));
        return companyCubit
          ..emit(CompanyState(status: DataStatus.loaded, company: tCompany));
      },
      act: (cubit) => cubit.changeLogo(AttachmentSource.gallery),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.sections[CompanySections.changeLogo],
          'sections[changeLogo]',
          SectionStatus.running,
        ),
        isA<CompanyState>().having(
          (state) => state.sections[CompanySections.changeLogo],
          'sections[changeLogo]',
          SectionStatus.idle,
        ),
      ],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit running and error when updateCompanyLogo fails',
      build: () {
        when(
          () => mockPickAttachmentUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: [tAttachment]));
        when(
          () => mockUpdateCompanyLogoUseCase.call(any()),
        ).thenAnswer((_) async => FailureState(message: 'Upload failed'));
        return companyCubit
          ..emit(CompanyState(status: DataStatus.loaded, company: tCompany));
      },
      act: (cubit) => cubit.changeLogo(AttachmentSource.gallery),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.sections[CompanySections.changeLogo],
          'sections[changeLogo]',
          SectionStatus.running,
        ),
        isA<CompanyState>().having(
          (state) => state.sections[CompanySections.changeLogo],
          'sections[changeLogo]',
          SectionStatus.error,
        ),
      ],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit running and success with updated company when update succeeds',
      build: () {
        final updatedCompany = tCompany.copyWith(logoUrl: 'https://logo.png');
        when(
          () => mockPickAttachmentUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: [tAttachment]));
        when(
          () => mockUpdateCompanyLogoUseCase.call(any()),
        ).thenAnswer((_) async => SuccessState(data: updatedCompany));
        return companyCubit
          ..emit(CompanyState(status: DataStatus.loaded, company: tCompany));
      },
      act: (cubit) => cubit.changeLogo(AttachmentSource.gallery),
      expect: () => [
        isA<CompanyState>().having(
          (state) => state.sections[CompanySections.changeLogo],
          'sections[changeLogo]',
          SectionStatus.running,
        ),
        isA<CompanyState>()
            .having(
              (state) => state.sections[CompanySections.changeLogo],
              'sections[changeLogo]',
              SectionStatus.success,
            )
            .having(
              (state) => state.company?.logoUrl,
              'logoUrl',
              'https://logo.png',
            ),
      ],
    );
  });

  group('updateEscalationParameters', () {
    final tParams = EntityFactory.makeCompanyParameterEntity();

    blocTest<CompanyCubit, CompanyState>(
      'should do nothing when parameters in state is null',
      build: () => companyCubit,
      act: (cubit) =>
          cubit.updateEscalationParameters(advanceWarningMinutes: 30),
      expect: () => <CompanyState>[],
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit running and success with updated parameters on success',
      build: () {
        when(
          () => mockSaveCompanyParametersUseCase.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return companyCubit
          ..emit(CompanyState(status: DataStatus.loaded, parameters: tParams));
      },
      act: (cubit) => cubit.updateEscalationParameters(
        advanceWarningMinutes: 45,
        advanceWarningGroupIds: ['grp-1'],
        delayedNotificationIntervalMinutes: 30,
        escalationGroupIds: ['grp-2'],
      ),
      expect: () => [
        isA<CompanyState>().having(
          (s) => s.sections[CompanySections.updateEscalationParameters],
          'sections[updateEscalationParameters]',
          SectionStatus.running,
        ),
        isA<CompanyState>()
            .having(
              (s) => s.sections[CompanySections.updateEscalationParameters],
              'sections[updateEscalationParameters]',
              SectionStatus.success,
            )
            .having(
              (s) => s.parameters?.advanceWarningMinutes,
              'advanceWarningMinutes',
              45,
            )
            .having(
              (s) => s.parameters?.delayedNotificationIntervalMinutes,
              'delayedInterval',
              30,
            ),
      ],
      verify: (_) {
        verify(() => mockSaveCompanyParametersUseCase.call(any())).called(1);
      },
    );

    blocTest<CompanyCubit, CompanyState>(
      'should emit running and error on save failure',
      build: () {
        when(
          () => mockSaveCompanyParametersUseCase.call(any()),
        ).thenAnswer((_) async => FailureState(message: 'Save failed'));
        return companyCubit
          ..emit(CompanyState(status: DataStatus.loaded, parameters: tParams));
      },
      act: (cubit) =>
          cubit.updateEscalationParameters(advanceWarningMinutes: 45),
      expect: () => [
        isA<CompanyState>().having(
          (s) => s.sections[CompanySections.updateEscalationParameters],
          'sections[updateEscalationParameters]',
          SectionStatus.running,
        ),
        isA<CompanyState>().having(
          (s) => s.sections[CompanySections.updateEscalationParameters],
          'sections[updateEscalationParameters]',
          SectionStatus.error,
        ),
      ],
    );
  });
}
