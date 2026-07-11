import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/dashboard/dashboard_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetWorkOrdersUseCase extends Mock implements GetWorkOrdersUseCase {}

class MockGetAssetsUseCase extends Mock implements GetAssetsUseCase {}

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(CreateUpdateWorkOrderRoute());
    registerFallbackValue(CreateUpdateAssetRoute());
  });
  late MockGetWorkOrdersUseCase mockGetWorkOrdersUseCase;
  late MockGetAssetsUseCase mockGetAssetsUseCase;
  late MockGetSessionUserUseCase mockGetSessionUserUseCase;
  late MockNavigationClient mockNavigationClient;

  late DashboardCubitUseCases useCases;
  late DashboardCubit cubit;

  setUp(() {
    mockGetWorkOrdersUseCase = MockGetWorkOrdersUseCase();
    mockGetAssetsUseCase = MockGetAssetsUseCase();
    mockGetSessionUserUseCase = MockGetSessionUserUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    useCases = DashboardCubitUseCases(
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
        ).thenReturn(UserProfileEntity.empty());
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
            .having((s) => s.status, 'status', StateStatus.loadingError)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Usuário não autenticado',
            ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, error] when current session has no company id',
      build: () {
        final profile = EntityFactory.makeUserProfileEntity().copyWith(
          companyId: '',
        );
        when(() => mockGetSessionUserUseCase.call()).thenReturn(profile);
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
            .having((s) => s.status, 'status', StateStatus.loadingError)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Usuário não autenticado',
            ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, error] when work orders fetch fails',
      build: () {
        final userData = EntityFactory.makeUserDataEntity();
        when(
          () => mockGetWorkOrdersUseCase.call(userData.user.companyId),
        ).thenAnswer((_) async => FailureState(message: 'Error work orders'));
        when(
          () => mockGetAssetsUseCase.call(userData.user.companyId),
        ).thenAnswer((_) async => const SuccessState(data: []));
        when(() => mockGetSessionUserUseCase.call()).thenReturn(userData.user);
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
            .having((s) => s.status, 'status', StateStatus.loadingError)
            .having((s) => s.errorMessage, 'errorMessage', 'Error work orders'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, error] when assets fetch fails',
      build: () {
        final userData = EntityFactory.makeUserDataEntity();
        when(
          () => mockGetWorkOrdersUseCase.call(userData.user.companyId),
        ).thenAnswer((_) async => const SuccessState(data: []));
        when(
          () => mockGetAssetsUseCase.call(userData.user.companyId),
        ).thenAnswer((_) async => FailureState(message: 'Error assets'));
        when(() => mockGetSessionUserUseCase.call()).thenReturn(userData.user);
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
            .having((s) => s.status, 'status', StateStatus.loadingError)
            .having((s) => s.errorMessage, 'errorMessage', 'Error assets'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, loaded] with correct stats, sorted recent work orders, and active work order when an in-progress work order exists',
      build: () {
        final userData = EntityFactory.makeUserDataEntity();

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
          () => mockGetWorkOrdersUseCase.call(userData.user.companyId),
        ).thenAnswer(
          (_) async => SuccessState(data: [workOrder1, workOrder2, workOrder3]),
        );
        when(
          () => mockGetAssetsUseCase.call(userData.user.companyId),
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
            .having((s) => s.pendingRevisionsCount, 'pendingRevisionsCount', 2)
            .having(
              (s) => s.recentWorkOrders,
              'recentWorkOrders',
              isA<List<WorkOrderEntity>>(),
            )
            .having(
              (s) => s.activeWorkOrders,
              'activeWorkOrders',
              contains(isA<WorkOrderEntity>()),
            ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, loaded] with activeWorkOrders containing all in-progress work orders sorted by updatedAt desc',
      build: () {
        final userData = EntityFactory.makeUserDataEntity();

        final workOrder1 = EntityFactory.makeWorkOrderEntity().copyWith(
          id: 'wo-1',
          status: WorkOrderStatus.inProgress,
          updatedAt: DateTime(2026, 6, 7, 10),
        );
        final workOrder2 = EntityFactory.makeWorkOrderEntity().copyWith(
          id: 'wo-2',
          status: WorkOrderStatus.inProgress,
          updatedAt: DateTime(2026, 6, 7, 12),
        );
        final workOrder3 = EntityFactory.makeWorkOrderEntity().copyWith(
          id: 'wo-3',
          status: WorkOrderStatus.inProgress,
          updatedAt: DateTime(2026, 6, 7, 11),
        );

        when(() => mockGetSessionUserUseCase.call()).thenReturn(userData.user);
        when(
          () => mockGetWorkOrdersUseCase.call(userData.user.companyId),
        ).thenAnswer(
          (_) async => SuccessState(data: [workOrder1, workOrder2, workOrder3]),
        );
        when(
          () => mockGetAssetsUseCase.call(userData.user.companyId),
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
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having(
              (s) => s.activeWorkOrders,
              'activeWorkOrders',
              isA<List<WorkOrderEntity>>()
                  .having((list) => list.length, 'length', 3)
                  .having(
                    (list) => list[0].id,
                    'first id (most recent 12h)',
                    'wo-2',
                  )
                  .having((list) => list[1].id, 'second id (11h)', 'wo-3')
                  .having((list) => list[2].id, 'third id (10h)', 'wo-1'),
            ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, loaded] with empty activeWorkOrders when no in-progress work order exists, clearing the previous active work orders',
      seed: () {
        final previousActiveWorkOrder = EntityFactory.makeWorkOrderEntity()
            .copyWith(status: WorkOrderStatus.inProgress);
        return const DashboardState.initial().copyWith(
          activeWorkOrders: [previousActiveWorkOrder],
        );
      },
      build: () {
        final userData = EntityFactory.makeUserDataEntity();

        final workOrder1 = EntityFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.open,
          updatedAt: DateTime(2026, 6, 7, 10),
        );
        final workOrder3 = EntityFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.completed,
          updatedAt: DateTime(2026, 6, 7, 9),
        );

        when(() => mockGetSessionUserUseCase.call()).thenReturn(userData.user);
        when(
          () => mockGetWorkOrdersUseCase.call(userData.user.companyId),
        ).thenAnswer((_) async => SuccessState(data: [workOrder1, workOrder3]));
        when(
          () => mockGetAssetsUseCase.call(userData.user.companyId),
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
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.activeWorkOrders, 'activeWorkOrders', isEmpty),
      ],
    );

    group('Navigation', () {
      blocTest<DashboardCubit, DashboardState>(
        'navigateToCreateUpdateWorkOrder should push CreateUpdateWorkOrderRoute',
        build: () {
          when(
            () => mockNavigationClient
                .pushRoute<CreateUpdateWorkOrderRouteArgs>(any()),
          ).thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) => cubit.navigateToCreateUpdateWorkOrder('wo123'),
        expect: () => <DashboardState>[],
        verify: (_) {
          verify(
            () => mockNavigationClient
                .pushRoute<CreateUpdateWorkOrderRouteArgs>(any()),
          ).called(1);
        },
      );

      blocTest<DashboardCubit, DashboardState>(
        'navigateToCreateUpdateAsset should push CreateUpdateAssetRoute',
        build: () {
          when(
            () => mockNavigationClient
                .pushRoute<CreateUpdateAssetRouteArgs>(any()),
          ).thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) => cubit.navigateToCreateUpdateAsset(),
        expect: () => <DashboardState>[],
        verify: (_) {
          verify(
            () => mockNavigationClient
                .pushRoute<CreateUpdateAssetRouteArgs>(any()),
          ).called(1);
        },
      );
    });
  });
}
