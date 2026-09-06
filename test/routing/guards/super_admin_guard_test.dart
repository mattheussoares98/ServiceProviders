import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/routing/guards/super_admin_guard.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';

import '../../../testing/mocks/factories/user_factory.dart';
import '../../../testing/mocks/repository_mocks.dart';

class MockStackRouter extends Mock implements StackRouter {}

class MockNavigationResolver extends Mock implements NavigationResolver {}

void main() {
  late MockSessionRepository mockSessionRepository;
  late MockStackRouter mockStackRouter;
  late MockNavigationResolver mockNavigationResolver;
  late SuperAdminGuard superAdminGuard;

  setUpAll(() {
    registerFallbackValue(const CompanyRoute());
  });

  setUp(() {
    mockSessionRepository = MockSessionRepository();
    mockStackRouter = MockStackRouter();
    mockNavigationResolver = MockNavigationResolver();
    superAdminGuard = const SuperAdminGuard();

    GetIt.I.registerSingleton<SessionRepository>(mockSessionRepository);

    when(() => mockNavigationResolver.next(any())).thenReturn(null);
    when(() => mockStackRouter.replaceAll(any())).thenAnswer((_) async => []);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('SuperAdminGuard', () {
    test('should redirect to CompanyRoute when user is not logged in', () {
      when(() => mockSessionRepository.isLoggedIn).thenReturn(false);

      superAdminGuard.onNavigation(mockNavigationResolver, mockStackRouter);

      verify(
        () => mockStackRouter.replaceAll(const [CompanyRoute()]),
      ).called(1);
      verifyNever(() => mockNavigationResolver.next(any()));
    });

    test(
      'should redirect to CompanyRoute when logged-in user is not super admin',
      () {
        when(() => mockSessionRepository.isLoggedIn).thenReturn(true);
        when(() => mockSessionRepository.userData).thenReturn(
          UserFactory.makeUserDataEntity().copyWith(
            user: UserFactory.makeUserProfileEntity().copyWith(
              email: 'regular_user@example.com',
            ),
          ),
        );

        superAdminGuard.onNavigation(mockNavigationResolver, mockStackRouter);

        verify(
          () => mockStackRouter.replaceAll(const [CompanyRoute()]),
        ).called(1);
        verifyNever(() => mockNavigationResolver.next(any()));
      },
    );

    test('should call resolver.next() when logged-in user is super admin', () {
      when(() => mockSessionRepository.isLoggedIn).thenReturn(true);
      when(() => mockSessionRepository.userData).thenReturn(
        UserFactory.makeUserDataEntity().copyWith(
          user: UserFactory.makeUserProfileEntity().copyWith(
            email: 'mattheussbarosa98@gmail.com',
          ),
        ),
      );

      superAdminGuard.onNavigation(mockNavigationResolver, mockStackRouter);

      verify(() => mockNavigationResolver.next()).called(1);
      verifyNever(() => mockStackRouter.replaceAll(any()));
    });
  });
}
