import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/clear_local_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/provider_home/provider_home_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/provider_home/provider_home_cubit_use_cases.dart';
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
  late ProviderHomeCubit providerHomeCubit;

  setUpAll(() {
    registerFallbackValue(const LoginRoute());
  });

  setUp(() {
    mockLogOutUseCase = MockLogOutUseCase();
    mockClearLocalAttachmentsUseCase = MockClearLocalAttachmentsUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    when(
      () => mockClearLocalAttachmentsUseCase(),
    ).thenAnswer((_) async => SuccessState.nil);

    final useCases = ProviderHomeCubitUseCases(
      logOut: mockLogOutUseCase,
      clearLocalAttachments: mockClearLocalAttachmentsUseCase,
    );
    providerHomeCubit = ProviderHomeCubit(useCases: useCases);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('ProviderHomeCubit', () {
    blocTest<ProviderHomeCubit, ProviderHomeState>(
      'logout should call LogOutUseCase and replace route with LoginRoute',
      build: () {
        when(() => mockLogOutUseCase.call()).thenAnswer((_) async {});
        return providerHomeCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => <ProviderHomeState>[],
      verify: (cubit) {
        verify(() => mockClearLocalAttachmentsUseCase.call()).called(1);
        verify(() => mockLogOutUseCase.call()).called(1);
        verify(
          () => mockNavigationClient.replaceAllRoute(const LoginRoute()),
        ).called(1);
      },
    );
  });
}
