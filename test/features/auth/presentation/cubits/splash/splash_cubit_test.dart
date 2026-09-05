import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/splash/splash_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/splash/splash_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/external/external_mocks.dart';
import '../../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

class MockGetSelectedModeUseCase extends Mock
    implements GetSelectedModeUseCase {}

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

void main() {
  late MockSessionRepository mockSessionRepository;
  late MockGetSelectedModeUseCase mockGetSelectedMode;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockCreateAccessLogUseCase mockCreateAccessLog;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockSupabaseAuthClient mockAuthClient;
  late SplashCubit cubit;
  late MockNavigationClient mockNavigationClient;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeCreateAccessLogRequestEntity());
  });

  setUp(() {
    mockSessionRepository = MockSessionRepository();
    mockGetSelectedMode = MockGetSelectedModeUseCase();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockCreateAccessLog = MockCreateAccessLogUseCase();
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockAuthClient = MockSupabaseAuthClient();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    final useCases = SplashCubitUseCases(
      sessionRepository: mockSessionRepository,
      getSelectedMode: mockGetSelectedMode,
      getSessionUser: mockGetSessionUser,
      createAccessLog: mockCreateAccessLog,
      getActiveCompanyId: mockGetActiveCompanyId,
    );

    cubit = SplashCubit(useCases: useCases, authClient: mockAuthClient);
  });

  tearDown(GetIt.I.reset);

  group('SplashCubit', () {
    test('initial state should be SplashRouteTarget.initial', () {
      expect(cubit.state.target, SplashRouteTarget.initial);
    });

    blocTest<SplashCubit, SplashState>(
      'checkInitialRoute emits acceptInvite when authClient session exists but user is not loaded',
      build: () {
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
        when(() => mockSessionRepository.userData).thenReturn(
          EntityFactory.makeUserDataEntity().copyWith(
            user: EntityFactory.makeUserProfileEntity().copyWith(id: ''),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.checkInitialRoute(),
      expect: () => [const SplashState(target: SplashRouteTarget.acceptInvite)],
    );

    blocTest<SplashCubit, SplashState>(
      'checkInitialRoute emits providerHome when user is logged in and is in provider mode',
      build: () {
        when(() => mockAuthClient.currentSession).thenReturn(null);
        when(() => mockSessionRepository.isLoggedIn).thenReturn(true);
        when(
          () => mockGetSelectedMode.call(),
        ).thenReturn(AppMode.provider.name);
        when(() => mockGetSessionUser.call()).thenReturn(
          EntityFactory.makeUserProfileEntity().copyWith(companyId: ''),
        );
        when(() => mockGetActiveCompanyId.call()).thenReturn('');
        return cubit;
      },
      act: (cubit) => cubit.checkInitialRoute(),
      expect: () => [const SplashState(target: SplashRouteTarget.providerHome)],
    );

    blocTest<SplashCubit, SplashState>(
      'checkInitialRoute emits home and logs appAccess when user is logged in and has companyId',
      build: () {
        final tCompanyId = faker.guid.guid();
        when(() => mockAuthClient.currentSession).thenReturn(null);
        when(() => mockSessionRepository.isLoggedIn).thenReturn(true);
        when(
          () => mockGetSelectedMode.call(),
        ).thenReturn(AppMode.internal.name);
        when(() => mockGetSessionUser.call()).thenReturn(
          EntityFactory.makeUserProfileEntity().copyWith(companyId: tCompanyId),
        );
        when(() => mockGetActiveCompanyId.call()).thenReturn(tCompanyId);
        when(
          () => mockCreateAccessLog.call(any()),
        ).thenAnswer((_) async => SuccessState.nil);
        return cubit;
      },
      act: (cubit) => cubit.checkInitialRoute(),
      expect: () => [const SplashState(target: SplashRouteTarget.home)],
      verify: (_) {
        verify(() => mockCreateAccessLog.call(any())).called(1);
      },
    );

    blocTest<SplashCubit, SplashState>(
      'checkInitialRoute emits login when user is not logged in',
      build: () {
        when(() => mockAuthClient.currentSession).thenReturn(null);
        when(() => mockSessionRepository.isLoggedIn).thenReturn(false);
        return cubit;
      },
      act: (cubit) => cubit.checkInitialRoute(),
      expect: () => [const SplashState(target: SplashRouteTarget.login)],
    );
  });
}
