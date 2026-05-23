import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit_use_cases.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  late MockLogOutUseCase mockLogOutUseCase;
  late MockNavigationClient mockNavigationClient;
  late HomeCubit homeCubit;

  setUpAll(() {
    registerFallbackValue(const LoginRoute());
  });

  setUp(() {
    mockLogOutUseCase = MockLogOutUseCase();
    mockNavigationClient = MockNavigationClient();

    // Register NavigationClient in GetIt so base cubit routes resolve correctly
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    final useCases = HomeCubitUseCases(logOut: mockLogOutUseCase);
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
        when(
          () => mockNavigationClient.replaceAllRoute(any()),
        ).thenAnswer((_) async {});
        return homeCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => <HomeState>[],
      verify: (cubit) {
        verify(() => mockLogOutUseCase.call()).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const LoginRoute()),
        ).called(1);
      },
    );
  });
}
