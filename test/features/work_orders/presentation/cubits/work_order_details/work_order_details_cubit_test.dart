import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_log_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_details/work_order_details_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_details/work_order_details_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../../testing/mocks/factories/work_order_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

class MockPauseWorkflowCubit extends MockCubit<PauseWorkflowState>
    implements PauseWorkflowCubit {}

void main() {
  late MockGetWorkOrderByIdUseCase mockGetWorkOrderById;
  late MockUpdateWorkOrderUseCase mockUpdateWorkOrder;
  late MockDeleteWorkOrderUseCase mockDeleteWorkOrder;
  late MockRestoreWorkOrderUseCase mockRestoreWorkOrder;
  late MockCancelPauseUseCase mockCancelPause;
  late MockWatchWorkOrdersRealtimeUseCase mockWatchRealtime;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetSelectedModeUseCase mockGetSelectedMode;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetWorkOrderHistoryUseCase mockGetWorkOrderHistory;
  late MockCreateWorkOrderChangeRequestUseCase mockCreateChangeRequest;
  late MockReviewWorkOrderChangeRequestUseCase mockReviewChangeRequest;
  late MockNavigationClient mockNavigationClient;
  late WorkOrderDetailsCubitUseCases cubitUseCases;

  setUpAll(() {
    registerFallbackValue(WorkOrderFactory.makeWorkOrderEntity());
    registerFallbackValue(WorkOrderFactory.makeWorkOrderChangeRequestEntity());
    registerFallbackValue(
      ReviewChangeRequestParams(
        id: faker.guid.guid(),
        status: ChangeRequestStatus.approved,
        reviewedById: faker.guid.guid(),
      ),
    );
    registerFallbackValue(
      CancelPauseParams(
        id: faker.guid.guid(),
        workOrderId: faker.guid.guid(),
        resumedAt: DateTime.now(),
        resumedById: faker.guid.guid(),
      ),
    );
    registerFallbackValue(WorkOrderHistoryRoute(workOrderId: ''));
  });

  setUp(() {
    mockGetWorkOrderById = MockGetWorkOrderByIdUseCase();
    mockUpdateWorkOrder = MockUpdateWorkOrderUseCase();
    mockDeleteWorkOrder = MockDeleteWorkOrderUseCase();
    mockRestoreWorkOrder = MockRestoreWorkOrderUseCase();
    mockCancelPause = MockCancelPauseUseCase();
    mockWatchRealtime = MockWatchWorkOrdersRealtimeUseCase();
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockGetSelectedMode = MockGetSelectedModeUseCase();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetWorkOrderHistory = MockGetWorkOrderHistoryUseCase();
    mockCreateChangeRequest = MockCreateWorkOrderChangeRequestUseCase();
    mockReviewChangeRequest = MockReviewWorkOrderChangeRequestUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    when(() => mockGetActiveCompanyId.call()).thenReturn(faker.guid.guid());
    when(() => mockGetSelectedMode.call()).thenReturn(AppMode.internal.name);
    when(
      () => mockGetSessionUser.call(),
    ).thenReturn(UserFactory.makeUserProfileEntity());
    when(
      () => mockWatchRealtime.call(companyId: any(named: 'companyId')),
    ).thenAnswer((_) => const Stream.empty());

    cubitUseCases = WorkOrderDetailsCubitUseCases(
      getWorkOrderById: mockGetWorkOrderById,
      updateWorkOrder: mockUpdateWorkOrder,
      deleteWorkOrder: mockDeleteWorkOrder,
      restoreWorkOrder: mockRestoreWorkOrder,
      cancelPause: mockCancelPause,
      watchWorkOrdersRealtime: mockWatchRealtime,
      getActiveCompanyId: mockGetActiveCompanyId,
      getSelectedMode: mockGetSelectedMode,
      getSessionUser: mockGetSessionUser,
      getWorkOrderHistory: mockGetWorkOrderHistory,
      createChangeRequest: mockCreateChangeRequest,
      reviewChangeRequest: mockReviewChangeRequest,
    );
  });

  tearDown(GetIt.I.reset);

  group('loadWorkOrder', () {
    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'emits [running, success] with workOrder when load succeeds with showLoading: true',
      build: () {
        final tOrder = WorkOrderFactory.makeWorkOrderEntity();
        when(
          () => mockGetWorkOrderById.call(any()),
        ).thenAnswer((_) async => SuccessState(data: tOrder));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.loadWorkOrder('wo-123', showLoading: true),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[BaseSections.load],
          'sections[load]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>()
            .having(
              (s) => s.sections[BaseSections.load],
              'sections[load]',
              const SectionState.success(),
            )
            .having((s) => s.workOrder?.id, 'workOrder.id', isNotNull),
      ],
    );

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'emits [running, error] when load fails with showLoading: true',
      build: () {
        when(
          () => mockGetWorkOrderById.call(any()),
        ).thenAnswer((_) async => FailureState(message: 'Not found'));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.loadWorkOrder('wo-123', showLoading: true),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[BaseSections.load],
          'sections[load]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[BaseSections.load],
          'sections[load]',
          const SectionState.error('Not found'),
        ),
      ],
    );
  });

  group('restoreWorkOrder', () {
    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'emits [running, success] and reloads work order on success',
      build: () {
        final tOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
          annulDeletedAt: true,
        );
        when(
          () => mockRestoreWorkOrder.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockGetWorkOrderById.call(any()),
        ).thenAnswer((_) async => SuccessState(data: tOrder));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.restoreWorkOrder('wo-123'),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.restoreWorkOrder],
          'sections[restoreWorkOrder]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.restoreWorkOrder],
          'sections[restoreWorkOrder]',
          const SectionState.success(),
        ),
        isA<WorkOrderDetailsState>()
            .having(
              (s) => s.sections[BaseSections.load],
              'sections[load]',
              const SectionState.success(),
            )
            .having(
              (s) => s.workOrder?.deletedAt,
              'workOrder.deletedAt',
              isNull,
            ),
      ],
    );

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'emits [running, error] on restore failure',
      build: () {
        when(
          () => mockRestoreWorkOrder.call(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.restoreWorkOrder('wo-123'),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.restoreWorkOrder],
          'sections[restoreWorkOrder]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.restoreWorkOrder],
          'sections[restoreWorkOrder]',
          const SectionState.error(),
        ),
      ],
    );
  });

  group('deleteWorkOrder', () {
    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'emits [running, success] and clears workOrder on delete success',
      build: () {
        when(
          () => mockDeleteWorkOrder.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.deleteWorkOrder('wo-123'),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.deleteWorkOrder],
          'sections[deleteWorkOrder]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>()
            .having(
              (s) => s.sections[WorkOrderDetailsSections.deleteWorkOrder],
              'sections[deleteWorkOrder]',
              const SectionState.success(),
            )
            .having((s) => s.workOrder, 'workOrder', isNull),
      ],
      verify: (_) {
        verify(() => mockNavigationClient.maybePopTop()).called(1);
      },
    );

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'emits [running, error] on delete failure',
      build: () {
        when(
          () => mockDeleteWorkOrder.call(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.deleteWorkOrder('wo-123'),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.deleteWorkOrder],
          'sections[deleteWorkOrder]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.deleteWorkOrder],
          'sections[deleteWorkOrder]',
          const SectionState.error(),
        ),
      ],
    );
  });

  group('changeWorkOrderStatus', () {
    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'emits [running, success] and updates status on success',
      build: () {
        when(
          () => mockUpdateWorkOrder.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.changeWorkOrderStatus(
        workOrder: WorkOrderFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.open,
        ),
        status: WorkOrderStatus.inProgress,
      ),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.changeStatus],
          'sections[changeStatus]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>()
            .having(
              (s) => s.sections[WorkOrderDetailsSections.changeStatus],
              'sections[changeStatus]',
              const SectionState.success(),
            )
            .having(
              (s) => s.workOrder?.status,
              'workOrder.status',
              WorkOrderStatus.inProgress,
            ),
      ],
    );
  });

  group('resumeWork', () {
    late MockPauseWorkflowCubit mockPauseCubit;

    setUp(() {
      mockPauseCubit = MockPauseWorkflowCubit();
      when(() => mockPauseCubit.pendingCompletionRequest).thenReturn(null);
      when(() => mockPauseCubit.activePauseRequest).thenReturn(null);
      when(
        () => mockPauseCubit.loadPauseRequests(any()),
      ).thenAnswer((_) async {});
    });

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'resumes directly by calling changeWorkOrderStatus when no active pause or pending completion',
      build: () {
        when(
          () => mockUpdateWorkOrder.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.resumeWork(
        workOrder: WorkOrderFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.onHold,
        ),
        currentUserId: faker.guid.guid(),
        pauseCubit: mockPauseCubit,
      ),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.resumeWork],
          'sections[resumeWork]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.changeStatus],
          'sections[changeStatus]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>()
            .having(
              (s) => s.sections[WorkOrderDetailsSections.changeStatus],
              'sections[changeStatus]',
              const SectionState.success(),
            )
            .having(
              (s) => s.workOrder?.status,
              'workOrder.status',
              WorkOrderStatus.inProgress,
            ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.resumeWork],
          'sections[resumeWork]',
          const SectionState.success(),
        ),
      ],
    );

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'cancels pause when activePauseRequest is present',
      build: () {
        final pauseReq = WorkOrderFactory.makePauseRequestEntity();
        when(() => mockPauseCubit.activePauseRequest).thenReturn(pauseReq);
        when(
          () => mockCancelPause.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.resumeWork(
        workOrder: WorkOrderFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.onHold,
        ),
        currentUserId: faker.guid.guid(),
        pauseCubit: mockPauseCubit,
      ),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.resumeWork],
          'sections[resumeWork]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>()
            .having(
              (s) => s.sections[WorkOrderDetailsSections.resumeWork],
              'sections[resumeWork]',
              const SectionState.running(),
            )
            .having(
              (s) => s.workOrder?.status,
              'workOrder.status',
              WorkOrderStatus.inProgress,
            ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.resumeWork],
          'sections[resumeWork]',
          const SectionState.success(),
        ),
      ],
    );
  });

  group('loadWorkOrderHistory', () {
    final tWorkOrderId = faker.guid.guid();

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'should update history list when history loads successfully',
      build: () {
        final tHistory = WorkOrderFactory.makeAuditLogEntityList();
        when(
          () => mockGetWorkOrderHistory.call(any()),
        ).thenAnswer((_) async => SuccessState(data: tHistory));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.loadWorkOrderHistory(tWorkOrderId),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.history,
          'history',
          isNotEmpty,
        ),
      ],
      verify: (_) {
        verify(() => mockGetWorkOrderHistory.call(tWorkOrderId)).called(1);
      },
    );

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'should not emit state when history load fails',
      build: () {
        when(() => mockGetWorkOrderHistory.call(any())).thenAnswer(
          (_) async => FailureState<List<AuditLogEntity>>(message: 'Error'),
        );
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.loadWorkOrderHistory(tWorkOrderId),
      expect: () => <WorkOrderDetailsState>[],
      verify: (_) {
        verify(() => mockGetWorkOrderHistory.call(tWorkOrderId)).called(1);
      },
    );
  });

  group('createChangeRequest', () {
    final tRequest = WorkOrderFactory.makeWorkOrderChangeRequestEntity();

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'should emit loading, success and reload work order when createChangeRequest succeeds',
      build: () {
        when(
          () => mockCreateChangeRequest.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(() => mockGetWorkOrderById.call(any())).thenAnswer(
          (_) async =>
              SuccessState(data: WorkOrderFactory.makeWorkOrderEntity()),
        );
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.createChangeRequest(tRequest),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.createChangeRequest],
          'sections[createChangeRequest]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.createChangeRequest],
          'sections[createChangeRequest]',
          const SectionState.success(),
        ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.workOrder,
          'workOrder',
          isNotNull,
        ),
      ],
      verify: (_) {
        verify(() => mockCreateChangeRequest.call(tRequest)).called(1);
        verify(() => mockGetWorkOrderById.call(tRequest.workOrderId)).called(1);
      },
    );

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'should emit error when createChangeRequest fails',
      build: () {
        when(
          () => mockCreateChangeRequest.call(any()),
        ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.createChangeRequest(tRequest),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.createChangeRequest],
          'sections[createChangeRequest]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.createChangeRequest],
          'sections[createChangeRequest]',
          const SectionState.error(),
        ),
      ],
      verify: (_) {
        verify(() => mockCreateChangeRequest.call(tRequest)).called(1);
        verifyNever(() => mockGetWorkOrderById.call(any()));
      },
    );
  });

  group('reviewChangeRequest', () {
    final tParams = ReviewChangeRequestParams(
      id: faker.guid.guid(),
      status: ChangeRequestStatus.approved,
      reviewedById: faker.guid.guid(),
    );

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'should emit loading and success when reviewChangeRequest succeeds',
      build: () {
        when(
          () => mockReviewChangeRequest.call(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.reviewChangeRequest(tParams),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.reviewChangeRequest],
          'sections[reviewChangeRequest]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.reviewChangeRequest],
          'sections[reviewChangeRequest]',
          const SectionState.success(),
        ),
      ],
      verify: (_) {
        verify(() => mockReviewChangeRequest.call(tParams)).called(1);
      },
    );

    blocTest<WorkOrderDetailsCubit, WorkOrderDetailsState>(
      'should emit error when reviewChangeRequest fails',
      build: () {
        when(
          () => mockReviewChangeRequest.call(any()),
        ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
        return WorkOrderDetailsCubit(useCases: cubitUseCases);
      },
      act: (cubit) => cubit.reviewChangeRequest(tParams),
      expect: () => [
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.reviewChangeRequest],
          'sections[reviewChangeRequest]',
          const SectionState.running(),
        ),
        isA<WorkOrderDetailsState>().having(
          (s) => s.sections[WorkOrderDetailsSections.reviewChangeRequest],
          'sections[reviewChangeRequest]',
          const SectionState.error(),
        ),
      ],
      verify: (_) {
        verify(() => mockReviewChangeRequest.call(tParams)).called(1);
      },
    );
  });

  group('navigateToWorkOrderHistory', () {
    test('calls pushRoute with WorkOrderHistoryRoute', () async {
      when(
        () => mockNavigationClient.pushRoute<WorkOrderHistoryRouteArgs>(any()),
      ).thenAnswer((_) async => null);

      final cubit = WorkOrderDetailsCubit(useCases: cubitUseCases);
      final id = faker.guid.guid();

      await cubit.navigateToWorkOrderHistory(id);

      verify(
        () => mockNavigationClient.pushRoute<WorkOrderHistoryRouteArgs>(any()),
      ).called(1);
      await cubit.close();
    });
  });
}
