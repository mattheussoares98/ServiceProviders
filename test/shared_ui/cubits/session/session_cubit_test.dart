import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit_use_cases.dart';

import '../../../../testing/mocks/client_mocks.dart';
import '../../../../testing/mocks/entity_factory.dart';
import '../../../../testing/mocks/use_case_mocks.dart';

void main() {
  late MockGetSessionUserUseCase mockGetSessionUserUseCase;
  late MockWatchSessionUseCase mockWatchSessionUseCase;
  late MockNavigationClient mockNavigationClient;
  late SessionCubitUseCases useCases;
  late StreamController<UserDataEntity> streamController;

  final tUserProfile = EntityFactory.makeUserProfileEntity();
  final tUserData = EntityFactory.makeUserDataEntity().copyWith(
    user: tUserProfile,
    accessToken: 'token',
  );

  setUp(() {
    mockGetSessionUserUseCase = MockGetSessionUserUseCase();
    mockWatchSessionUseCase = MockWatchSessionUseCase();
    streamController = StreamController<UserDataEntity>.broadcast();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    when(() => mockGetSessionUserUseCase.call()).thenReturn(tUserProfile);
    when(
      () => mockWatchSessionUseCase.call(),
    ).thenAnswer((_) => streamController.stream);

    useCases = SessionCubitUseCases(
      getSessionUser: mockGetSessionUserUseCase,
      watchSession: mockWatchSessionUseCase,
    );
  });

  tearDown(() {
    streamController.close();
    GetIt.I.unregister<NavigationClient>();
  });

  group('SessionCubit', () {
    test('initial state should be initialized with current user', () {
      final cubit = SessionCubit(useCases: useCases);
      expect(cubit.state.user, equals(tUserProfile));
      expect(cubit.state.isLoggedIn, isTrue);
      expect(cubit.state.status, equals(DataStatus.initial));
      cubit.close();
    });

    blocTest<SessionCubit, SessionState>(
      'should emit loaded state with updated user details when session stream emits',
      build: () => SessionCubit(useCases: useCases),
      act: (cubit) {
        streamController.add(tUserData);
      },
      expect: () => [
        isA<SessionState>()
            .having((s) => s.user, 'user', tUserProfile)
            .having((s) => s.isLoggedIn, 'isLoggedIn', true)
            .having((s) => s.status, 'status', DataStatus.loaded),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'should emit logged out state when session stream emits empty user',
      build: () => SessionCubit(useCases: useCases),
      act: (cubit) {
        streamController.add(UserDataEntity.empty());
      },
      expect: () => [
        isA<SessionState>()
            .having((s) => s.isLoggedIn, 'isLoggedIn', false)
            .having((s) => s.status, 'status', DataStatus.loaded),
      ],
    );
  });
}
