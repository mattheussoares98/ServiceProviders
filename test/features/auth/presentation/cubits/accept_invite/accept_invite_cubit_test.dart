// ignore_for_file: inference_failure_on_instance_creation

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/accept_invite/accept_invite_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_profile_use_case.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/external/external_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

class MockUpdateUserProfileUseCase extends Mock
    implements UpdateUserProfileUseCase {}

class MockGetUserProfileByIdUseCase extends Mock
    implements GetUserProfileByIdUseCase {}

class MockSaveSelectedModeUseCase extends Mock
    implements SaveSelectedModeUseCase {}

void main() {
  late MockChangePasswordUseCase mockChangePassword;
  late MockUpdateUserProfileUseCase mockUpdateUserProfile;
  late MockGetUserProfileByIdUseCase mockGetUserProfileById;
  late MockSetSessionUseCase mockSetSession;
  late MockSaveUserDataUseCase mockSaveUserData;
  late MockSaveSelectedModeUseCase mockSaveSelectedMode;
  late MockSupabaseAuthClient mockAuthClient;
  late MockNavigationClient mockNavigationClient;
  late AcceptInviteCubit cubit;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeUserProfileEntity());
    registerFallbackValue(EntityFactory.makeUserDataEntity());
    registerFallbackValue(const HomeRoute());
    registerFallbackValue(const ProviderHomeRoute());
  });

  setUp(() {
    mockChangePassword = MockChangePasswordUseCase();
    mockUpdateUserProfile = MockUpdateUserProfileUseCase();
    mockGetUserProfileById = MockGetUserProfileByIdUseCase();
    mockSetSession = MockSetSessionUseCase();
    mockSaveUserData = MockSaveUserDataUseCase();
    mockSaveSelectedMode = MockSaveSelectedModeUseCase();
    mockAuthClient = MockSupabaseAuthClient();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    when(() => mockSaveSelectedMode.call(any())).thenAnswer((_) async {});

    final useCases = AcceptInviteCubitUseCases(
      changePassword: mockChangePassword,
      updateUserProfile: mockUpdateUserProfile,
      getUserProfileById: mockGetUserProfileById,
      setSession: mockSetSession,
      saveUserData: mockSaveUserData,
      saveSelectedMode: mockSaveSelectedMode,
    );

    cubit = AcceptInviteCubit(useCases: useCases, authClient: mockAuthClient);
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
        when(() => mockAuthClient.currentSession).thenReturn(
          Session(
            accessToken: faker.jwt.valid(),
            tokenType: 'bearer',
            user: User(
              id: userId,
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
        );
        when(
          () => mockGetUserProfileById.call(userId),
        ).thenAnswer((_) async => SuccessState(data: profile));

        cubit.initialize();

        verify(() => mockGetUserProfileById.call(userId)).called(1);
      });

      test('listens to auth state changes when session arrives', () async {
        final controller = StreamController<AuthState>();
        final userId = faker.guid.guid();
        final profile = EntityFactory.makeUserProfileEntity();

        when(() => mockAuthClient.currentSession).thenReturn(null);
        when(
          () => mockAuthClient.onAuthStateChange,
        ).thenAnswer((_) => controller.stream);
        when(
          () => mockGetUserProfileById.call(userId),
        ).thenAnswer((_) async => SuccessState(data: profile));

        cubit.initialize();

        controller.add(
          AuthState(
            AuthChangeEvent.signedIn,
            Session(
              accessToken: faker.jwt.valid(),
              tokenType: 'bearer',
              user: User(
                id: userId,
                appMetadata: const {},
                userMetadata: const {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
          ),
        );

        await Future.delayed(Duration.zero);

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
        when(() => mockAuthClient.currentSession).thenReturn(
          Session(
            accessToken: faker.jwt.valid(),
            tokenType: 'bearer',
            user: User(
              id: userId,
              email: faker.internet.email(),
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
        );
        when(() => mockGetUserProfileById.call(any())).thenAnswer(
          (_) async => FailureState(message: 'Usuário não encontrado'),
        );
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
      'acceptInvite should call password change, update profile, and save session on success',
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
        when(() => mockSetSession.call(any())).thenAnswer((_) {});
        when(
          () => mockSaveUserData.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(() => mockAuthClient.currentSession).thenReturn(
          Session(
            accessToken: faker.jwt.valid(),
            tokenType: 'bearer',
            user: User(
              id: faker.guid.guid(),
              appMetadata: const {},
              userMetadata: const {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
          ),
        );
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
        verify(() => mockSetSession.call(any())).called(1);
        verify(() => mockSaveUserData.call(any())).called(1);
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
