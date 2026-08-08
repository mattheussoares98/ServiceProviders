import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/auth_user_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/watch_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/accept_invite/accept_invite_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/accept_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_profile_use_case.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

class MockUpdateUserProfileUseCase extends Mock
    implements UpdateUserProfileUseCase {}

class MockGetUserProfileByIdUseCase extends Mock
    implements GetUserProfileByIdUseCase {}

class MockGetServiceProviderProfilesByAuthUserUseCase extends Mock
    implements GetServiceProviderProfilesByAuthUserUseCase {}

class MockUpdateServiceProviderProfileUseCase extends Mock
    implements UpdateServiceProviderProfileUseCase {}

class MockSaveSelectedModeUseCase extends Mock
    implements SaveSelectedModeUseCase {}

class MockAcceptServiceProviderInvitationUseCase extends Mock
    implements AcceptServiceProviderInvitationUseCase {}

class MockGetAuthUserUseCase extends Mock implements GetAuthUserUseCase {}

class MockWatchAuthUserUseCase extends Mock implements WatchAuthUserUseCase {}

class MockLogOutUseCase extends Mock implements LogOutUseCase {}

void main() {
  late MockChangePasswordUseCase mockChangePassword;
  late MockUpdateUserProfileUseCase mockUpdateUserProfile;
  late MockGetUserProfileByIdUseCase mockGetUserProfileById;
  late MockGetServiceProviderProfilesByAuthUserUseCase
  mockGetServiceProviderProfilesByAuthUser;
  late MockUpdateServiceProviderProfileUseCase mockUpdateServiceProviderProfile;
  late MockSaveSelectedModeUseCase mockSaveSelectedMode;
  late MockNavigationClient mockNavigationClient;
  late MockAcceptServiceProviderInvitationUseCase
  acceptServiceProviderInvitation;
  late MockGetAuthUserUseCase mockGetAuthUser;
  late MockWatchAuthUserUseCase mockWatchAuthUser;
  late MockLogOutUseCase mockLogOut;
  late AcceptInviteCubit cubit;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeUserProfileEntity());
    registerFallbackValue(EntityFactory.makeUserDataEntity());
    registerFallbackValue(const HomeRoute());
    registerFallbackValue(const ProviderHomeRoute());
    registerFallbackValue(const LoginRoute());
  });

  setUp(() {
    mockChangePassword = MockChangePasswordUseCase();
    mockUpdateUserProfile = MockUpdateUserProfileUseCase();
    mockGetUserProfileById = MockGetUserProfileByIdUseCase();
    mockGetServiceProviderProfilesByAuthUser =
        MockGetServiceProviderProfilesByAuthUserUseCase();
    mockUpdateServiceProviderProfile =
        MockUpdateServiceProviderProfileUseCase();
    mockSaveSelectedMode = MockSaveSelectedModeUseCase();
    mockNavigationClient = MockNavigationClient();
    acceptServiceProviderInvitation =
        MockAcceptServiceProviderInvitationUseCase();
    mockGetAuthUser = MockGetAuthUserUseCase();
    mockWatchAuthUser = MockWatchAuthUserUseCase();
    mockLogOut = MockLogOutUseCase();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    when(() => mockSaveSelectedMode.call(any())).thenAnswer((_) async {});
    when(() => mockLogOut.call()).thenAnswer((_) async {});
    when(() => mockGetAuthUser.call()).thenReturn(null);
    when(
      () => mockWatchAuthUser.call(),
    ).thenAnswer((_) => const Stream.empty());

    final useCases = AcceptInviteCubitUseCases(
      changePassword: mockChangePassword,
      updateUserProfile: mockUpdateUserProfile,
      getUserProfileById: mockGetUserProfileById,
      getServiceProviderProfilesByAuthUser:
          mockGetServiceProviderProfilesByAuthUser,
      updateServiceProviderProfile: mockUpdateServiceProviderProfile,
      saveSelectedMode: mockSaveSelectedMode,
      acceptServiceProviderInvitation: acceptServiceProviderInvitation,
      getAuthUser: mockGetAuthUser,
      watchAuthUser: mockWatchAuthUser,
      logOut: mockLogOut,
    );

    cubit = AcceptInviteCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('AcceptInviteCubit', () {
    test('initial state should be empty', () {
      expect(cubit.state, const AcceptInviteState.empty());
    });

    group('initialize', () {
      test('loads profile immediately if session exists', () {
        final userId = faker.guid.guid();
        final profile = EntityFactory.makeUserProfileEntity();
        when(() => mockGetAuthUser.call()).thenReturn(
          AuthUserEntity(
            id: userId,
            email: faker.internet.email(),
            name: faker.person.name(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        when(
          () => mockGetUserProfileById.call(userId),
        ).thenAnswer((_) async => SuccessState(data: profile));

        cubit.initialize();

        verify(() => mockGetUserProfileById.call(userId)).called(1);
      });

      test('listens to auth state changes when session arrives', () async {
        final controller = StreamController<String?>();
        final userId = faker.guid.guid();
        final profile = EntityFactory.makeUserProfileEntity();

        when(() => mockGetAuthUser.call()).thenReturn(null);
        when(
          () => mockWatchAuthUser.call(),
        ).thenAnswer((_) => controller.stream);
        when(
          () => mockGetUserProfileById.call(userId),
        ).thenAnswer((_) async => SuccessState(data: profile));

        cubit.initialize();

        controller.add(userId);
        await pumpEventQueue();

        verify(() => mockGetUserProfileById.call(userId)).called(1);
        await controller.close();
      });
    });

    blocTest<AcceptInviteCubit, AcceptInviteState>(
      'togglePasswordVisibility should flip passwordVisibility state',
      build: () => cubit,
      act: (cubit) => cubit.togglePasswordVisibility(),
      expect: () => [
        const AcceptInviteState(
          status: StateStatus.initial,
          passwordVisibility: true,
        ),
      ],
    );

    blocTest<AcceptInviteCubit, AcceptInviteState>(
      'toggleConfirmPasswordVisibility should flip confirmPasswordVisibility state',
      build: () => cubit,
      act: (cubit) => cubit.toggleConfirmPasswordVisibility(),
      expect: () => [
        const AcceptInviteState(
          status: StateStatus.initial,
          confirmPasswordVisibility: true,
        ),
      ],
    );

    blocTest<AcceptInviteCubit, AcceptInviteState>(
      'loadProfile should load profile and emit SuccessState',
      build: () {
        final profile = EntityFactory.makeUserProfileEntity();
        when(
          () => mockGetUserProfileById.call(any()),
        ).thenAnswer((_) async => SuccessState(data: profile));
        return cubit;
      },
      act: (cubit) => cubit.loadProfile(faker.guid.guid()),
      expect: () => [
        isA<AcceptInviteState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<AcceptInviteState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.userProfile, 'userProfile', isNotNull),
      ],
    );

    blocTest<AcceptInviteCubit, AcceptInviteState>(
      'loadProfile should create fallback profile when user is not found in user_profiles',
      build: () {
        final userId = faker.guid.guid();
        when(() => mockGetAuthUser.call()).thenReturn(
          AuthUserEntity(
            id: userId,
            email: faker.internet.email(),
            name: faker.person.name(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        when(() => mockGetUserProfileById.call(any())).thenAnswer(
          (_) async => FailureState(message: 'Usuário não encontrado'),
        );
        when(
          () => mockGetServiceProviderProfilesByAuthUser.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: []));
        return cubit;
      },
      act: (cubit) => cubit.loadProfile(faker.guid.guid()),
      expect: () => [
        isA<AcceptInviteState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<AcceptInviteState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.userProfile, 'userProfile', isNotNull),
      ],
    );

    blocTest<AcceptInviteCubit, AcceptInviteState>(
      'acceptInvite should return false and emit loaded when profile is not loaded',
      build: () => cubit,
      act: (cubit) async {
        final result = await cubit.acceptInvite(
          name: faker.person.name(),
          password: faker.internet.password(),
        );
        expect(result, isFalse);
      },
      expect: () => <dynamic>[],
    );

    blocTest<AcceptInviteCubit, AcceptInviteState>(
      'acceptInvite should call password change, update profile, and log out on success',
      seed: () => AcceptInviteState(
        status: StateStatus.loaded,
        userProfile: EntityFactory.makeUserProfileEntity().copyWith(
          isActive: false,
        ),
      ),
      build: () {
        when(
          () => mockChangePassword.call(any()),
        ).thenAnswer((_) async => SuccessState.nil);
        when(
          () => mockUpdateUserProfile.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => acceptServiceProviderInvitation.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(() => mockLogOut.call()).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) async {
        final result = await cubit.acceptInvite(
          name: faker.person.name(),
          password: faker.internet.password(),
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<AcceptInviteState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<AcceptInviteState>().having(
          (s) => s.status,
          'status',
          StateStatus.loaded,
        ),
      ],
      verify: (_) {
        verify(() => mockChangePassword.call(any())).called(1);
        verify(() => mockUpdateUserProfile.call(any())).called(1);
        verify(() => acceptServiceProviderInvitation.call(any())).called(1);
        verify(() => mockLogOut.call()).called(1);
      },
    );

    blocTest<AcceptInviteCubit, AcceptInviteState>(
      'acceptInvite should skip password change and profile update if profile is already active',
      seed: () => AcceptInviteState(
        status: StateStatus.loaded,
        userProfile: EntityFactory.makeUserProfileEntity().copyWith(
          isActive: true,
        ),
      ),
      build: () => cubit,
      act: (cubit) async {
        final result = await cubit.acceptInvite(
          name: faker.person.name(),
          password: faker.internet.password(),
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<AcceptInviteState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<AcceptInviteState>().having(
          (s) => s.status,
          'status',
          StateStatus.loaded,
        ),
      ],
      verify: (_) {
        verifyNever(() => mockChangePassword.call(any()));
        verifyNever(() => mockUpdateUserProfile.call(any()));
      },
    );

    group('Navigation', () {
      blocTest<AcceptInviteCubit, AcceptInviteState>(
        'navigateToHome should replaceAll with ProviderHomeRoute and save provider mode when companyId is empty',
        seed: () => AcceptInviteState(
          status: StateStatus.loaded,
          userProfile: EntityFactory.makeUserProfileEntity().copyWith(
            companyId: '',
          ),
        ),
        build: () {
          when(
            () => mockNavigationClient.replaceAllRoute(any()),
          ).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.navigateToHome(),
        expect: () => <AcceptInviteState>[],
        verify: (_) {
          verify(
            () => mockSaveSelectedMode.call(AppMode.provider.name),
          ).called(1);
          verify(
            () =>
                mockNavigationClient.replaceAllRoute(const ProviderHomeRoute()),
          ).called(1);
        },
      );

      blocTest<AcceptInviteCubit, AcceptInviteState>(
        'navigateToHome should replaceAll with HomeRoute when companyId is not empty',
        seed: () => AcceptInviteState(
          status: StateStatus.loaded,
          userProfile: EntityFactory.makeUserProfileEntity().copyWith(
            companyId: faker.guid.guid(),
          ),
        ),
        build: () {
          when(
            () => mockNavigationClient.replaceAllRoute(any()),
          ).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.navigateToHome(),
        expect: () => <AcceptInviteState>[],
        verify: (_) {
          verify(
            () => mockNavigationClient.replaceAllRoute(const HomeRoute()),
          ).called(1);
        },
      );

      blocTest<AcceptInviteCubit, AcceptInviteState>(
        'navigateToLogin should replaceAll with LoginRoute',
        build: () {
          when(
            () => mockNavigationClient.replaceAllRoute(any()),
          ).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.navigateToLogin(),
        expect: () => <AcceptInviteState>[],
        verify: (_) {
          verify(
            () => mockNavigationClient.replaceAllRoute(const LoginRoute()),
          ).called(1);
        },
      );

      blocTest<AcceptInviteCubit, AcceptInviteState>(
        'navigateToSplash should replaceAll with SplashRoute',
        build: () {
          when(
            () => mockNavigationClient.replaceAllRoute(any()),
          ).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.navigateToSplash(),
        expect: () => <AcceptInviteState>[],
        verify: (_) {
          verify(
            () => mockNavigationClient.replaceAllRoute(const SplashRoute()),
          ).called(1);
        },
      );
    });
  });
}
