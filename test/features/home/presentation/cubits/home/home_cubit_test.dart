import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/clear_local_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

class MockClearLocalAttachmentsUseCase extends Mock
    implements ClearLocalAttachmentsUseCase {}

void main() {
  late MockLogOutUseCase mockLogOutUseCase;
  late MockClearLocalAttachmentsUseCase mockClearLocalAttachmentsUseCase;
  late MockNavigationClient mockNavigationClient;
  late HomeCubit homeCubit;

  setUpAll(() {
    registerFallbackValue(const LoginRoute());
  });

  setUp(() {
    mockLogOutUseCase = MockLogOutUseCase();
    mockClearLocalAttachmentsUseCase = MockClearLocalAttachmentsUseCase();
    mockNavigationClient = MockNavigationClient();

    // Register NavigationClient in GetIt so base cubit routes resolve correctly
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    when(
      () => mockClearLocalAttachmentsUseCase(),
    ).thenAnswer((_) async => SuccessState.nil);

    final useCases = HomeCubitUseCases(
      logOut: mockLogOutUseCase,
      clearLocalAttachments: mockClearLocalAttachmentsUseCase,
    );
    homeCubit = HomeCubit(useCases: useCases);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('HomeCubit', () {
    blocTest<HomeCubit, HomeState>(
      'logout should call LogOutUseCase and replace route with LoginRoute',
      build: () {
        when(() => mockLogOutUseCase.call()).thenAnswer((_) async {});
        return homeCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => <HomeState>[],
      verify: (cubit) {
        verify(() => mockClearLocalAttachmentsUseCase.call()).called(1);
        verify(() => mockLogOutUseCase.call()).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const LoginRoute()),
        ).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'navigateToCompany should push CompanyRoute',
      build: () => homeCubit,
      act: (cubit) => cubit.navigateToCompany(),
      expect: () => <HomeState>[],
      verify: (cubit) {
        verify(
          () => mockNavigationClient.pushRoute(const CompanyRoute()),
        ).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'navigateToPermissions should push PermissionsRoute',
      build: () => homeCubit,
      act: (cubit) => cubit.navigateToPermissions(),
      expect: () => <HomeState>[],
      verify: (cubit) {
        verify(
          () =>
              mockNavigationClient.pushRoute(const UsersAndPermissionsRoute()),
        ).called(1);
      },
    );
  });
}
