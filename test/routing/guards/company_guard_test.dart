import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/routing/guards/company_guard.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';

import '../../../testing/mocks/client_mocks.dart';
import '../../../testing/mocks/factories/user_factory.dart';
import '../../../testing/mocks/repository_mocks.dart';

class MockStackRouter extends Mock implements StackRouter {}

class MockNavigationResolver extends Mock implements NavigationResolver {}

void main() {
  late MockSessionRepository mockSessionRepository;
  late MockLocalStorageClient mockLocalStorageClient;
  late MockStackRouter mockStackRouter;
  late MockNavigationResolver mockNavigationResolver;
  late CompanyGuard companyGuard;

  setUpAll(() {
    registerFallbackValue(const CompanyRoute());
  });

  setUp(() {
    mockSessionRepository = MockSessionRepository();
    mockLocalStorageClient = MockLocalStorageClient();
    mockStackRouter = MockStackRouter();
    mockNavigationResolver = MockNavigationResolver();
    companyGuard = const CompanyGuard();

    GetIt.I.registerSingleton<SessionRepository>(mockSessionRepository);
    GetIt.I.registerSingleton<LocalStorageClient>(mockLocalStorageClient);

    // Default stubbing
    when(() => mockNavigationResolver.next(any())).thenReturn(null);
    when(() => mockStackRouter.replaceAll(any())).thenAnswer((_) async => []);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('CompanyGuard', () {
    test(
      'should allow navigation (call resolver.next) when user is not logged in',
      () {
        // Arrange
        when(() => mockSessionRepository.isLoggedIn).thenReturn(false);

        // Act
        companyGuard.onNavigation(mockNavigationResolver, mockStackRouter);

        // Assert
        verify(() => mockNavigationResolver.next()).called(1);
        verifyNever(() => mockStackRouter.replaceAll(any()));
      },
    );

    test('should allow navigation when app is in provider mode', () {
      // Arrange
      when(() => mockSessionRepository.isLoggedIn).thenReturn(true);
      when(
        () => mockLocalStorageClient.getSelectedMode(),
      ).thenReturn(AppMode.provider.name);

      // Act
      companyGuard.onNavigation(mockNavigationResolver, mockStackRouter);

      // Assert
      verify(() => mockNavigationResolver.next()).called(1);
      verifyNever(() => mockStackRouter.replaceAll(any()));
    });

    test(
      'should allow navigation when app is in internal mode and user has a company ID',
      () {
        // Arrange
        final userProfile = UserFactory.makeUserProfileEntity().copyWith(
          companyId: 'company-123',
        );
        final userData = UserFactory.makeUserDataEntity().copyWith(
          user: userProfile,
        );

        when(() => mockSessionRepository.isLoggedIn).thenReturn(true);
        when(
          () => mockLocalStorageClient.getSelectedMode(),
        ).thenReturn(AppMode.internal.name);
        when(() => mockSessionRepository.userData).thenReturn(userData);

        // Act
        companyGuard.onNavigation(mockNavigationResolver, mockStackRouter);

        // Assert
        verify(() => mockNavigationResolver.next()).called(1);
        verifyNever(() => mockStackRouter.replaceAll(any()));
      },
    );

    test(
      'should redirect to LoginRoute when app is in internal mode and user has no company ID',
      () {
        // Arrange
        final userProfile = UserFactory.makeUserProfileEntity().copyWith(
          companyId: '',
        );
        final userData = UserFactory.makeUserDataEntity().copyWith(
          user: userProfile,
        );

        when(() => mockSessionRepository.isLoggedIn).thenReturn(true);
        when(
          () => mockLocalStorageClient.getSelectedMode(),
        ).thenReturn(AppMode.internal.name);
        when(() => mockSessionRepository.userData).thenReturn(userData);

        // Act
        companyGuard.onNavigation(mockNavigationResolver, mockStackRouter);

        // Assert
        verifyNever(() => mockNavigationResolver.next(any()));
        verify(
          () => mockStackRouter.replaceAll([const LoginRoute()]),
        ).called(1);
      },
    );
  });
}
