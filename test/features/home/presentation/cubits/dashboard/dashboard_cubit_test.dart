import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_entity.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:clean_architecture/features/home/presentation/cubits/dashboard/dashboard_cubit_use_cases.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetUserProfileByIdUseCase extends Mock
    implements GetUserProfileByIdUseCase {}

class MockGetWorkOrdersUseCase extends Mock implements GetWorkOrdersUseCase {}

class MockGetAssetsUseCase extends Mock implements GetAssetsUseCase {}

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

void main() {
  late MockGetUserProfileByIdUseCase mockGetUserProfileByIdUseCase;
  late MockGetWorkOrdersUseCase mockGetWorkOrdersUseCase;
  late MockGetAssetsUseCase mockGetAssetsUseCase;
  late MockGetSessionUserUseCase mockGetSessionUserUseCase;
  late MockNavigationClient mockNavigationClient;

  late DashboardCubitUseCases useCases;
  late DashboardCubit cubit;

  setUp(() {
    mockGetUserProfileByIdUseCase = MockGetUserProfileByIdUseCase();
    mockGetWorkOrdersUseCase = MockGetWorkOrdersUseCase();
    mockGetAssetsUseCase = MockGetAssetsUseCase();
    mockGetSessionUserUseCase = MockGetSessionUserUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    useCases = DashboardCubitUseCases(
      getUserProfileById: mockGetUserProfileByIdUseCase,
      getWorkOrders: mockGetWorkOrdersUseCase,
      getAssets: mockGetAssetsUseCase,
      getSessionUser: mockGetSessionUserUseCase,
    );

    cubit = DashboardCubit(useCases: useCases);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('DashboardCubit', () {
    test('initial state has empty metrics and initial status', () {
      expect(cubit.state, const DashboardState.initial());
    });

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, error] when user is not logged in',
      build: () {
        when(
          () => mockGetSessionUserUseCase.call(),
        ).thenReturn(const UserEntity.empty());
        return cubit;
      },
      act: (cubit) => cubit.loadDashboardData(),
      expect: () => [
        isA<DashboardState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<DashboardState>()
            .having((s) => s.status, 'status', StateStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Usuário não autenticado',
            ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, error] when user profile fetch fails',
      build: () {
        final userData = EntityFactory.makeUserDataEntity();
        when(() => mockGetSessionUserUseCase.call()).thenReturn(userData.user);
        when(
          () => mockGetUserProfileByIdUseCase.call(userData.user.id),
        ).thenAnswer(
          (_) async => FailureState(message: 'Error fetching profile'),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadDashboardData(),
      expect: () => [
        isA<DashboardState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<DashboardState>()
            .having((s) => s.status, 'status', StateStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Error fetching profile',
            ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, error] when work orders fetch fails',
      build: () {
        final userData = EntityFactory.makeUserDataEntity();
        final profile = EntityFactory.makeUserProfileEntity();
        when(() => mockGetSessionUserUseCase.call()).thenReturn(userData.user);
        when(
          () => mockGetUserProfileByIdUseCase.call(userData.user.id),
        ).thenAnswer((_) async => SuccessState(data: profile));
        when(
          () => mockGetWorkOrdersUseCase.call(profile.companyId),
        ).thenAnswer((_) async => FailureState(message: 'Error work orders'));
        when(
          () => mockGetAssetsUseCase.call(profile.companyId),
        ).thenAnswer((_) async => const SuccessState(data: []));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboardData(),
      expect: () => [
        isA<DashboardState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<DashboardState>()
            .having((s) => s.status, 'status', StateStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', 'Error work orders'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, error] when assets fetch fails',
      build: () {
        final userData = EntityFactory.makeUserDataEntity();
        final profile = EntityFactory.makeUserProfileEntity();
        when(() => mockGetSessionUserUseCase.call()).thenReturn(userData.user);
        when(
          () => mockGetUserProfileByIdUseCase.call(userData.user.id),
        ).thenAnswer((_) async => SuccessState(data: profile));
        when(
          () => mockGetWorkOrdersUseCase.call(profile.companyId),
        ).thenAnswer((_) async => const SuccessState(data: []));
        when(
          () => mockGetAssetsUseCase.call(profile.companyId),
        ).thenAnswer((_) async => FailureState(message: 'Error assets'));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboardData(),
      expect: () => [
        isA<DashboardState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<DashboardState>()
            .having((s) => s.status, 'status', StateStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', 'Error assets'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, loaded] with correct stats and sorted recent work orders',
      build: () {
        final userData = EntityFactory.makeUserDataEntity();
        final profile = EntityFactory.makeUserProfileEntity();

        final workOrder1 = EntityFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.open,
          updatedAt: DateTime(2026, 6, 7, 10),
        );
        final workOrder2 = EntityFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.inProgress,
          updatedAt: DateTime(2026, 6, 7, 12),
        );
        final workOrder3 = EntityFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.completed,
          updatedAt: DateTime(2026, 6, 7, 9),
        );

        final asset1 = EntityFactory.makeAssetEntity().copyWith(
          revisionForecast: DateTime(2026, 6, 6),
        );
        final asset2 = EntityFactory.makeAssetEntity().copyWith(
          revisionForecast: DateTime(2026, 6, 8),
        );
        final asset3 = EntityFactory.makeAssetEntity().copyWith(
          annulRevisionForecast: true,
        );

        when(() => mockGetSessionUserUseCase.call()).thenReturn(userData.user);
        when(
          () => mockGetUserProfileByIdUseCase.call(userData.user.id),
        ).thenAnswer((_) async => SuccessState(data: profile));
        when(() => mockGetWorkOrdersUseCase.call(profile.companyId)).thenAnswer(
          (_) async => SuccessState(data: [workOrder1, workOrder2, workOrder3]),
        );
        when(
          () => mockGetAssetsUseCase.call(profile.companyId),
        ).thenAnswer((_) async => SuccessState(data: [asset1, asset2, asset3]));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboardData(),
      expect: () => [
        isA<DashboardState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<DashboardState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.openWorkOrdersCount, 'openWorkOrdersCount', 1)
            .having(
              (s) => s.inProgressWorkOrdersCount,
              'inProgressWorkOrdersCount',
              1,
            )
            .having((s) => s.pendingRevisionsCount, 'pendingRevisionsCount', 1)
            .having(
              (s) => s.recentWorkOrders,
              'recentWorkOrders',
              isA<List<WorkOrderEntity>>(),
            ),
      ],
    );
  });
}
