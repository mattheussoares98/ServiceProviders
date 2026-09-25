import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/onboarding/onboarding_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/onboarding/onboarding_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCreateCompanyUseCase mockCreateCompany;
  late MockGetPermissionGroupsUseCase mockGetPermissionGroups;
  late MockUpdateUserProfileUseCase mockUpdateUserProfile;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockSaveUserDataUseCase mockSaveUserData;
  late MockSetSessionUseCase mockSetSession;
  late MockSetSelectedCompanyIdUseCase mockSetSelectedCompanyId;
  late MockLocalStorageClient mockLocalStorageClient;
  late MockNavigationClient mockNavigationClient;
  late MockSessionRepository mockSessionRepository;

  late OnboardingCubit cubit;
  late UserProfileEntity testUser;

  setUpAll(() {
    registerFallbackValue(UserFactory.makeCompanyEntity());
    registerFallbackValue(UserFactory.makeUserProfileEntity());
    registerFallbackValue(UserFactory.makeUserDataEntity());
  });

  setUp(() {
    mockCreateCompany = MockCreateCompanyUseCase();
    mockGetPermissionGroups = MockGetPermissionGroupsUseCase();
    mockUpdateUserProfile = MockUpdateUserProfileUseCase();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockSaveUserData = MockSaveUserDataUseCase();
    mockSetSession = MockSetSessionUseCase();
    mockSetSelectedCompanyId = MockSetSelectedCompanyIdUseCase();
    mockLocalStorageClient = MockLocalStorageClient();
    mockNavigationClient = MockNavigationClient();
    mockSessionRepository = MockSessionRepository();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    testUser = UserFactory.makeUserProfileEntity().copyWith(
      id: 'user-1',
      companyId: '',
    );

    final useCases = OnboardingCubitUseCases(
      createCompany: mockCreateCompany,
      getPermissionGroups: mockGetPermissionGroups,
      updateUserProfile: mockUpdateUserProfile,
      getSessionUser: mockGetSessionUser,
      saveUserData: mockSaveUserData,
      setSession: mockSetSession,
      setSelectedCompanyId: mockSetSelectedCompanyId,
      localStorageClient: mockLocalStorageClient,
      sessionRepository: mockSessionRepository,
    );

    cubit = OnboardingCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('OnboardingCubit', () {
    test('initial state has currentStep 0 and default values', () {
      expect(cubit.state.currentStep, 0);
      expect(cubit.state.companyName, '');
      expect(cubit.state.cnpj, '');
      expect(cubit.state.workType, WorkType.internalOnly);
    });

    test('step navigation works within [0, 2] bounds', () {
      cubit.nextStep();
      expect(cubit.state.currentStep, 1);

      cubit.nextStep();
      expect(cubit.state.currentStep, 2);

      cubit.nextStep();
      expect(cubit.state.currentStep, 2);

      cubit.previousStep();
      expect(cubit.state.currentStep, 1);

      cubit.setStep(0);
      expect(cubit.state.currentStep, 0);

      cubit.setStep(5);
      expect(cubit.state.currentStep, 0);
    });

    test('updateCompanyInfo updates companyName and cnpj in state', () {
      cubit.updateCompanyInfo(
        name: 'Minha Empresa',
        cnpj: '12.345.678/0001-90',
      );
      expect(cubit.state.companyName, 'Minha Empresa');
      expect(cubit.state.cnpj, '12.345.678/0001-90');
    });

    test('selectWorkType updates workType in state', () {
      cubit.selectWorkType(WorkType.serviceProviderOnly);
      expect(cubit.state.workType, WorkType.serviceProviderOnly);
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'submit with empty companyName returns to step 0 without creating company',
      build: () => cubit,
      seed: () => const OnboardingState(currentStep: 2, companyName: '  '),
      act: (c) => c.submit(),
      expect: () => [const OnboardingState(companyName: '  ')],
      verify: (_) {
        verifyNever(() => mockCreateCompany.call(any()));
      },
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'submit succeeds: creates company, assigns admin group, updates profile & session, navigates home',
      build: () {
        final createdCompany = CompanyEntity(
          id: 'comp-100',
          name: 'Empresa Teste',
          cnpj: null,
          logoUrl: null,
          isActive: true,
          workType: WorkType.hybrid,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deletedAt: null,
        );

        final adminGroup = UserFactory.makePermissionGroupEntity().copyWith(
          id: 'group-admin',
          companyId: 'comp-100',
          name: 'Administrador',
          isDefault: true,
        );

        when(
          () => mockCreateCompany.call(any()),
        ).thenAnswer((_) async => SuccessState(data: createdCompany));
        when(() => mockGetSessionUser.call()).thenReturn(testUser);
        when(
          () => mockGetPermissionGroups.call('comp-100'),
        ).thenAnswer((_) async => SuccessState(data: [adminGroup]));
        when(
          () => mockUpdateUserProfile.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockSessionRepository.userData,
        ).thenReturn(UserFactory.makeUserDataEntity());
        when(() => mockSetSession.call(any())).thenReturn(null);
        when(
          () => mockSaveUserData.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockSetSelectedCompanyId.call('comp-100'),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalStorageClient.saveSelectedMode(AppMode.internal.name),
        ).thenAnswer((_) async {});
        when(
          () => mockNavigationClient.replaceAllRoute(const HomeRoute()),
        ).thenAnswer((_) async {});

        return cubit;
      },
      seed: () => const OnboardingState(
        currentStep: 2,
        companyName: 'Empresa Teste',
        workType: WorkType.hybrid,
      ),
      act: (c) => c.submit(),
      expect: () => [
        isA<OnboardingState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'status',
          SectionStatus.running,
        ),
        isA<OnboardingState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'status',
          SectionStatus.success,
        ),
      ],
      verify: (_) {
        verify(
          () => mockCreateCompany.call(
            any(
              that: isA<CompanyEntity>()
                  .having((c) => c.name, 'name', 'Empresa Teste')
                  .having((c) => c.workType, 'workType', WorkType.hybrid),
            ),
          ),
        ).called(1);
        verify(
          () => mockUpdateUserProfile.call(
            any(
              that: isA<UserProfileEntity>()
                  .having((u) => u.companyId, 'companyId', 'comp-100')
                  .having((u) => u.permissionGroupId, 'groupId', 'group-admin')
                  .having((u) => u.isAdmin, 'isAdmin', true),
            ),
          ),
        ).called(1);
        verify(() => mockSetSelectedCompanyId.call('comp-100')).called(1);
        verify(
          () => mockLocalStorageClient.saveSelectedMode(AppMode.internal.name),
        ).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const HomeRoute()),
        ).called(1);
      },
    );
  });
}
