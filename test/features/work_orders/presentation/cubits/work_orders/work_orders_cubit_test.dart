import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/create_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/upload_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_provider_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_change_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/restore_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/sync_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/factories/maintenance_plan_factory.dart';
import '../../../../../../testing/mocks/factories/service_provider_factory.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../../testing/mocks/factories/work_order_factory.dart';
import '../../../../../../testing/mocks/services.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

class MockGetWorkOrdersUseCase extends Mock implements GetWorkOrdersUseCase {}

class MockGetWorkOrderByIdUseCase extends Mock
    implements GetWorkOrderByIdUseCase {}

class MockCreateWorkOrderUseCase extends Mock
    implements CreateWorkOrderUseCase {}

class MockUpdateWorkOrderUseCase extends Mock
    implements UpdateWorkOrderUseCase {}

class MockDeleteWorkOrderUseCase extends Mock
    implements DeleteWorkOrderUseCase {}

class MockRestoreWorkOrderUseCase extends Mock
    implements RestoreWorkOrderUseCase {}

class MockGetWorkOrderChangeRequestsUseCase extends Mock
    implements GetWorkOrderChangeRequestsUseCase {}

class MockCreateWorkOrderChangeRequestUseCase extends Mock
    implements CreateWorkOrderChangeRequestUseCase {}

class MockReviewWorkOrderChangeRequestUseCase extends Mock
    implements ReviewWorkOrderChangeRequestUseCase {}

class MockGetWorkOrderHistoryUseCase extends Mock
    implements GetWorkOrderHistoryUseCase {}

class MockGetAttachmentsUseCase extends Mock implements GetAttachmentsUseCase {}

class MockUploadAttachmentUseCase extends Mock
    implements UploadAttachmentUseCase {}

class MockDeleteAttachmentUseCase extends Mock
    implements DeleteAttachmentUseCase {}

class MockCreateAttachmentUseCase extends Mock
    implements CreateAttachmentUseCase {}

class MockCancelPauseUseCase extends Mock implements CancelPauseUseCase {}

class MockSyncWorkOrdersUseCase extends Mock implements SyncWorkOrdersUseCase {}

class MockAttachmentsCubit extends MockCubit<AttachmentsState>
    implements AttachmentsCubit {}

class MockPauseWorkflowCubit extends MockCubit<PauseWorkflowState>
    implements PauseWorkflowCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetWorkOrdersUseCase mockGetWorkOrders;
  late MockGetWorkOrderByIdUseCase mockGetWorkOrderById;
  late MockCreateWorkOrderUseCase mockCreateWorkOrder;
  late MockUpdateWorkOrderUseCase mockUpdateWorkOrder;
  late MockDeleteWorkOrderUseCase mockDeleteWorkOrder;
  late MockGetWorkOrderChangeRequestsUseCase mockGetChangeRequests;
  late MockGetAttachmentsUseCase mockGetAttachments;
  late MockUploadAttachmentUseCase mockUploadAttachment;
  late MockDeleteAttachmentUseCase mockDeleteAttachment;
  late MockCreateAttachmentUseCase mockCreateAttachment;
  late MockSyncWorkOrdersUseCase mockSyncWorkOrders;
  late MockSyncEngine mockSyncEngine;
  late MockGetProviderWorkOrdersUseCase mockGetProviderWorkOrders;
  late MockGetSessionProviderProfileUseCase mockGetSessionProviderProfile;
  late MockGetServiceProviderProfilesByAuthUserUseCase
  mockGetServiceProviderProfilesByAuthUser;
  late MockGetServiceProviderCompaniesByIdsUseCase
  mockGetServiceProviderCompaniesByIds;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetSelectedModeUseCase mockGetSelectedMode;
  late MockWatchWorkOrdersRealtimeUseCase mockWatchWorkOrdersRealtime;
  late MockNavigationClient mockNavigationClient;

  late WorkOrdersCubit cubit;
  late WorkOrdersCubitUseCases useCases;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(WorkOrderFactory.makeWorkOrderEntity());
    registerFallbackValue(WorkOrderFactory.makeWorkOrderChangeRequestEntity());
    registerFallbackValue(WorkOrderFactory.makeWorkOrderHistoryEntity());
    registerFallbackValue(
      const ReviewChangeRequestParams(
        id: '',
        status: ChangeRequestStatus.pending,
        reviewedById: '',
      ),
    );
    registerFallbackValue(MaintenancePlanFactory.makeAttachmentEntity());
    registerFallbackValue(CreateUpdateWorkOrderRoute());
    registerFallbackValue(WorkOrderDetailsRoute(workOrderId: ''));
    registerFallbackValue(
      WorkOrderPendingRequestsRoute(
        workOrder: WorkOrderFactory.makeWorkOrderEntity(),
        currentUserId: faker.guid.guid(),
      ),
    );
    registerFallbackValue(const GetWorkOrdersParams(companyId: ''));
    registerFallbackValue(PauseRequestStatus.pending);
    registerFallbackValue(WorkOrderFactory.makePauseRequestEntity());
    registerFallbackValue(
      CancelPauseParams(
        id: faker.guid.guid(),
        workOrderId: faker.guid.guid(),
        resumedAt: DateTime.now(),
        resumedById: faker.guid.guid(),
      ),
    );
  });

  setUp(() {
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockGetWorkOrders = MockGetWorkOrdersUseCase();
    mockGetWorkOrderById = MockGetWorkOrderByIdUseCase();
    mockCreateWorkOrder = MockCreateWorkOrderUseCase();
    mockUpdateWorkOrder = MockUpdateWorkOrderUseCase();
    mockDeleteWorkOrder = MockDeleteWorkOrderUseCase();
    mockGetChangeRequests = MockGetWorkOrderChangeRequestsUseCase();
    mockGetAttachments = MockGetAttachmentsUseCase();
    mockUploadAttachment = MockUploadAttachmentUseCase();
    mockDeleteAttachment = MockDeleteAttachmentUseCase();
    mockNavigationClient = MockNavigationClient();
    mockCreateAttachment = MockCreateAttachmentUseCase();
    mockSyncWorkOrders = MockSyncWorkOrdersUseCase();
    mockSyncEngine = MockSyncEngine();
    mockGetProviderWorkOrders = MockGetProviderWorkOrdersUseCase();
    mockGetSessionProviderProfile = MockGetSessionProviderProfileUseCase();
    mockGetServiceProviderProfilesByAuthUser =
        MockGetServiceProviderProfilesByAuthUserUseCase();
    mockGetServiceProviderCompaniesByIds =
        MockGetServiceProviderCompaniesByIdsUseCase();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetSelectedMode = MockGetSelectedModeUseCase();
    mockWatchWorkOrdersRealtime = MockWatchWorkOrdersRealtimeUseCase();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = UserFactory.makeUserProfileEntity();

    when(
      () => mockSyncEngine.onSyncCompleted,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockWatchWorkOrdersRealtime(companyId: any(named: 'companyId')),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockGetActiveCompanyId.call(),
    ).thenReturn(tUserProfile.companyId);
    // Internal mode unless a provider test overrides it.
    when(() => mockGetSelectedMode.call()).thenReturn(AppMode.internal.name);
    when(() => mockGetSessionUser.call()).thenReturn(tUserProfile);
    when(
      () => mockGetAttachments(any()),
    ).thenAnswer((_) async => const SuccessState(data: []));
    when(
      () => mockUploadAttachment(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockDeleteAttachment(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));

    useCases = WorkOrdersCubitUseCases(
      getActiveCompanyId: mockGetActiveCompanyId,
      getWorkOrders: mockGetWorkOrders,
      getWorkOrderById: mockGetWorkOrderById,
      createWorkOrder: mockCreateWorkOrder,
      updateWorkOrder: mockUpdateWorkOrder,
      getChangeRequests: mockGetChangeRequests,
      getAttachments: mockGetAttachments,
      uploadAttachment: mockUploadAttachment,
      deleteAttachment: mockDeleteAttachment,
      createAttachment: mockCreateAttachment,
      syncWorkOrders: mockSyncWorkOrders,
      syncEngine: mockSyncEngine,
      watchWorkOrdersRealtime: mockWatchWorkOrdersRealtime,
      getProviderWorkOrders: mockGetProviderWorkOrders,
      getSessionProviderProfile: mockGetSessionProviderProfile,
      getServiceProviderProfilesByAuthUser:
          mockGetServiceProviderProfilesByAuthUser,
      getServiceProviderCompaniesByIds: mockGetServiceProviderCompaniesByIds,
      getSessionUser: mockGetSessionUser,
      getSelectedMode: mockGetSelectedMode,
    );

    cubit = WorkOrdersCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('WorkOrdersCubit Tests', () {
    group('loadWorkOrdersAndChangeRequests', () {
      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit loading and loaded when data loads successfully',
        build: () {
          final tWorkOrders = WorkOrderFactory.makeWorkOrderEntityList();
          final tChangeRequests =
              WorkOrderFactory.makeWorkOrderChangeRequestEntityList();
          when(
            () => mockGetWorkOrders.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tWorkOrders));
          when(
            () => mockGetChangeRequests.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tChangeRequests));
          return cubit;
        },
        act: (cubit) => cubit.loadWorkOrdersAndChangeRequests(),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<WorkOrdersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.workOrders, 'workOrders', isNotEmpty)
              .having((s) => s.changeRequests, 'changeRequests', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockGetWorkOrders.call(any())).called(1);
          verify(
            () => mockGetChangeRequests.call(tUserProfile.companyId),
          ).called(1);
        },
      );
      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should not emit loading when passing false value',
        build: () {
          final tWorkOrders = WorkOrderFactory.makeWorkOrderEntityList();
          final tChangeRequests =
              WorkOrderFactory.makeWorkOrderChangeRequestEntityList();
          when(
            () => mockGetWorkOrders.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tWorkOrders));
          when(
            () => mockGetChangeRequests.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tChangeRequests));
          return cubit;
        },
        act: (cubit) =>
            cubit.loadWorkOrdersAndChangeRequests(showLoading: false),
        expect: () => [
          isA<WorkOrdersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.workOrders, 'workOrders', isNotEmpty)
              .having((s) => s.changeRequests, 'changeRequests', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockGetWorkOrders.call(any())).called(1);
          verify(
            () => mockGetChangeRequests.call(tUserProfile.companyId),
          ).called(1);
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit loading and error when data load fails',
        build: () {
          final tMessage = faker.lorem.sentence();
          when(() => mockGetWorkOrders.call(any())).thenAnswer(
            (_) async => FailureState<List<WorkOrderEntity>>(message: tMessage),
          );
          when(
            () => mockGetChangeRequests.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.loadWorkOrdersAndChangeRequests(),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<WorkOrdersState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            isA<SectionState>().having(
              (sec) => sec.status,
              'status',
              SectionStatus.error,
            ),
          ),
        ],
        verify: (_) {
          verify(() => mockGetWorkOrders.call(any())).called(1);
          verify(
            () => mockGetChangeRequests.call(tUserProfile.companyId),
          ).called(1);
        },
      );
    });

    group('loadWorkOrderById', () {
      final tExistingOrder = WorkOrderFactory.makeWorkOrderEntity();
      final tUpdatedOrder = tExistingOrder.copyWith(title: 'Updated Title');
      final tNewOrder = WorkOrderFactory.makeWorkOrderEntity();

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should update the existing work order in workOrders list when found',
        seed: () => const WorkOrdersState.initial().copyWith(
          workOrders: [tExistingOrder],
        ),
        build: () {
          when(
            () => mockGetWorkOrderById.call(tExistingOrder.id),
          ).thenAnswer((_) async => SuccessState(data: tUpdatedOrder));
          return cubit;
        },
        act: (cubit) => cubit.loadWorkOrderById(tExistingOrder.id),
        expect: () => [
          isA<WorkOrdersState>()
              .having((s) => s.workOrders.first.title, 'title', 'Updated Title')
              .having((s) => s.workOrders.length, 'length', 1),
        ],
        verify: (_) {
          verify(() => mockGetWorkOrderById.call(tExistingOrder.id)).called(1);
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should append the work order to workOrders list when not present',
        seed: () => const WorkOrdersState.initial().copyWith(
          workOrders: [tExistingOrder],
        ),
        build: () {
          when(
            () => mockGetWorkOrderById.call(tNewOrder.id),
          ).thenAnswer((_) async => SuccessState(data: tNewOrder));
          return cubit;
        },
        act: (cubit) => cubit.loadWorkOrderById(tNewOrder.id),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.workOrders.length,
            'length',
            2,
          ),
        ],
        verify: (_) {
          verify(() => mockGetWorkOrderById.call(tNewOrder.id)).called(1);
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit loading and loaded when showLoading is true and request succeeds',
        build: () {
          when(
            () => mockGetWorkOrderById.call(tNewOrder.id),
          ).thenAnswer((_) async => SuccessState(data: tNewOrder));
          return cubit;
        },
        act: (cubit) =>
            cubit.loadWorkOrderById(tNewOrder.id, showLoading: true),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<WorkOrdersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.workOrders, 'workOrders', [tNewOrder]),
        ],
        verify: (_) {
          verify(() => mockGetWorkOrderById.call(tNewOrder.id)).called(1);
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit loading and loadingError when showLoading is true and request fails',
        build: () {
          when(() => mockGetWorkOrderById.call(tNewOrder.id)).thenAnswer(
            (_) async => FailureState(message: 'Work order not found'),
          );
          return cubit;
        },
        act: (cubit) =>
            cubit.loadWorkOrderById(tNewOrder.id, showLoading: true),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<WorkOrdersState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.error('Work order not found'),
          ),
        ],
        verify: (_) {
          verify(() => mockGetWorkOrderById.call(tNewOrder.id)).called(1);
        },
      );
    });

    group('Filters and Pagination Tests', () {
      const tFilter = WorkOrderFilter(searchText: 'filtro');

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'applyFilter should call loadWorkOrdersAndChangeRequests with filter',
        build: () {
          when(
            () => mockGetWorkOrders.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetChangeRequests.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.applyFilter(tFilter),
        expect: () => [
          isA<WorkOrdersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.running(),
              )
              .having((s) => s.activeFilter, 'activeFilter', tFilter),
          isA<WorkOrdersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.activeFilter, 'activeFilter', tFilter),
        ],
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'clearFilter should call loadWorkOrdersAndChangeRequests with empty filter',
        build: () {
          when(
            () => mockGetWorkOrders.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetChangeRequests.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        seed: () => const WorkOrdersState(
          workOrders: [],
          changeRequests: [],

          activeFilter: tFilter,
        ),
        act: (cubit) => cubit.clearFilter(),
        expect: () => [
          isA<WorkOrdersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.running(),
              )
              .having(
                (s) => s.activeFilter,
                'activeFilter',
                const WorkOrderFilter(),
              ),
          isA<WorkOrdersState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having(
                (s) => s.activeFilter,
                'activeFilter',
                const WorkOrderFilter(),
              ),
        ],
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'loadNextPage should load next page and append work orders on success',
        build: () {
          final tWorkOrders = WorkOrderFactory.makeWorkOrderEntityList();
          when(
            () => mockGetWorkOrders.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tWorkOrders));
          return cubit;
        },
        seed: () => const WorkOrdersState(workOrders: [], changeRequests: []),
        act: (cubit) => cubit.loadNextPage(),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.isLoadingMore,
            'isLoadingMore',
            true,
          ),
          isA<WorkOrdersState>()
              .having((s) => s.isLoadingMore, 'isLoadingMore', false)
              .having((s) => s.workOrders, 'workOrders', isNotEmpty),
        ],
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'loadNextPage should show error toast and set isLoadingMore to false on failure',
        build: () {
          when(
            () => mockGetWorkOrders.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'error pagination'));
          return cubit;
        },
        seed: () => const WorkOrdersState(workOrders: [], changeRequests: []),
        act: (cubit) => cubit.loadNextPage(),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.isLoadingMore,
            'isLoadingMore',
            true,
          ),
          isA<WorkOrdersState>().having(
            (s) => s.isLoadingMore,
            'isLoadingMore',
            false,
          ),
        ],
      );
    });

    group('saveWorkOrder', () {
      final tWorkOrder = WorkOrderFactory.makeWorkOrderEntity();

      group('create', () {
        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should emit saving and load data when creation succeeds',
          build: () {
            when(
              () => mockDeleteWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockCreateWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetWorkOrders.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetChangeRequests.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            return cubit;
          },
          act: (cubit) async {
            final tWorkOrderWithSla = tWorkOrder.copyWith(
              slaPolicyId: 'sla-policy-id-123',
            );
            final result = await cubit.saveWorkOrder(
              id: tWorkOrder.id,
              isEditing: false,
              assetId: tWorkOrderWithSla.assetId,
              locationId: tWorkOrderWithSla.locationId,
              assignedToId: tWorkOrderWithSla.assignedToId,
              createdById: tWorkOrderWithSla.createdById,
              maintenancePlanId: tWorkOrderWithSla.maintenancePlanId,
              title: tWorkOrderWithSla.title,
              description: tWorkOrderWithSla.description,
              priority: tWorkOrderWithSla.priority,
              status: tWorkOrderWithSla.status,
              type: tWorkOrderWithSla.type,
              scheduledDate: tWorkOrderWithSla.scheduledDate,
              startedAt: tWorkOrderWithSla.startedAt,
              completedAt: tWorkOrderWithSla.completedAt,
              estimatedDuration: tWorkOrderWithSla.estimatedDuration,
              actualDuration: tWorkOrderWithSla.actualDuration,
              laborCost: tWorkOrderWithSla.laborCost,
              partsCost: tWorkOrderWithSla.partsCost,
              totalCost: tWorkOrderWithSla.totalCost,
              notes: tWorkOrderWithSla.notes,
              createdAt: tWorkOrderWithSla.createdAt,
              serviceProviderCompanyId:
                  tWorkOrderWithSla.serviceProviderCompanyId,
              providerProfileId: tWorkOrderWithSla.providerProfileId,
              slaPolicyId: tWorkOrderWithSla.slaPolicyId,
              openedBy: tWorkOrderWithSla.openedBy,
            );

            expect(result, isTrue);
          },
          expect: () => [
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.running(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.success(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[BaseSections.load],
              'sections[load]',
              const SectionState.success(),
            ),
          ],
          verify: (_) {
            verify(
              () => mockCreateWorkOrder.call(
                any(
                  that: predicate<WorkOrderEntity>((actual) {
                    return actual.title == tWorkOrder.title &&
                        actual.priority == tWorkOrder.priority &&
                        actual.type == tWorkOrder.type &&
                        actual.locationId == tWorkOrder.locationId &&
                        actual.slaPolicyId == 'sla-policy-id-123';
                  }),
                ),
              ),
            ).called(1);
            verify(() => mockGetWorkOrders.call(any())).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should emit saving and call createWorkOrder with service provider details when provided',
          build: () {
            when(
              () => mockCreateWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetWorkOrders.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetChangeRequests.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            return cubit;
          },
          act: (cubit) async {
            final result = await cubit.saveWorkOrder(
              id: tWorkOrder.id,
              isEditing: false,
              assetId: tWorkOrder.assetId,
              locationId: tWorkOrder.locationId,
              createdById: tWorkOrder.createdById,
              maintenancePlanId: tWorkOrder.maintenancePlanId,
              title: tWorkOrder.title,
              description: tWorkOrder.description,
              priority: tWorkOrder.priority,
              status: tWorkOrder.status,
              type: tWorkOrder.type,
              scheduledDate: tWorkOrder.scheduledDate,
              startedAt: tWorkOrder.startedAt,
              completedAt: tWorkOrder.completedAt,
              estimatedDuration: tWorkOrder.estimatedDuration,
              actualDuration: tWorkOrder.actualDuration,
              laborCost: tWorkOrder.laborCost,
              partsCost: tWorkOrder.partsCost,
              totalCost: tWorkOrder.totalCost,
              notes: tWorkOrder.notes,
              createdAt: tWorkOrder.createdAt,
              serviceProviderCompanyId: 'company-uuid',
              providerProfileId: 'profile-uuid',
              openedBy: AppMode.provider,
            );

            expect(result, isTrue);
          },
          expect: () => [
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.running(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.success(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[BaseSections.load],
              'sections[load]',
              const SectionState.success(),
            ),
          ],
          verify: (_) {
            verify(
              () => mockCreateWorkOrder.call(
                any(
                  that: predicate<WorkOrderEntity>((actual) {
                    return actual.serviceProviderCompanyId == 'company-uuid' &&
                        actual.providerProfileId == 'profile-uuid' &&
                        actual.openedBy == AppMode.provider &&
                        actual.assignedToId == null;
                  }),
                ),
              ),
            ).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should upload pending/failed attachments when creation succeeds',
          build: () {
            final status = faker.randomGenerator.boolean()
                ? UploadStatus.pending
                : UploadStatus.failed;
            final tAttachment = MaintenancePlanFactory.makeAttachmentEntity()
                .copyWith(uploadStatus: status);
            when(
              () => mockCreateWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetWorkOrders.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetChangeRequests.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetAttachments(any()),
            ).thenAnswer((_) async => SuccessState(data: [tAttachment]));
            when(
              () => mockUploadAttachment(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            return cubit;
          },
          act: (cubit) async {
            final result = await cubit.saveWorkOrder(
              id: tWorkOrder.id,
              isEditing: false,
              assetId: tWorkOrder.assetId,
              locationId: tWorkOrder.locationId,
              assignedToId: tWorkOrder.assignedToId,
              createdById: tWorkOrder.createdById,
              maintenancePlanId: tWorkOrder.maintenancePlanId,
              title: tWorkOrder.title,
              description: tWorkOrder.description,
              priority: tWorkOrder.priority,
              status: tWorkOrder.status,
              type: tWorkOrder.type,
              scheduledDate: tWorkOrder.scheduledDate,
              startedAt: tWorkOrder.startedAt,
              completedAt: tWorkOrder.completedAt,
              estimatedDuration: tWorkOrder.estimatedDuration,
              actualDuration: tWorkOrder.actualDuration,
              laborCost: tWorkOrder.laborCost,
              partsCost: tWorkOrder.partsCost,
              totalCost: tWorkOrder.totalCost,
              notes: tWorkOrder.notes,
              createdAt: tWorkOrder.createdAt,
            );

            expect(result, isTrue);
          },
          expect: () => [
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.running(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.success(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[BaseSections.load],
              'sections[load]',
              const SectionState.success(),
            ),
          ],
          verify: (_) {
            verify(() => mockGetAttachments(any())).called(1);
            verify(() => mockUploadAttachment(any())).called(1);
            verify(() => mockGetWorkOrders.call(any())).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should emit error when attachment upload fails',
          build: () {
            final tAttachment = MaintenancePlanFactory.makeAttachmentEntity()
                .copyWith(uploadStatus: UploadStatus.pending);
            when(
              () => mockCreateWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetAttachments(any()),
            ).thenAnswer((_) async => SuccessState(data: [tAttachment]));
            when(
              () => mockUploadAttachment(any()),
            ).thenAnswer((_) async => FailureState(message: 'Upload Fail'));
            return cubit;
          },
          act: (cubit) async {
            final result = await cubit.saveWorkOrder(
              id: tWorkOrder.id,
              isEditing: false,
              assetId: tWorkOrder.assetId,
              locationId: tWorkOrder.locationId,
              assignedToId: tWorkOrder.assignedToId,
              createdById: tWorkOrder.createdById,
              maintenancePlanId: tWorkOrder.maintenancePlanId,
              title: tWorkOrder.title,
              description: tWorkOrder.description,
              priority: tWorkOrder.priority,
              status: tWorkOrder.status,
              type: tWorkOrder.type,
              scheduledDate: tWorkOrder.scheduledDate,
              startedAt: tWorkOrder.startedAt,
              completedAt: tWorkOrder.completedAt,
              estimatedDuration: tWorkOrder.estimatedDuration,
              actualDuration: tWorkOrder.actualDuration,
              laborCost: tWorkOrder.laborCost,
              partsCost: tWorkOrder.partsCost,
              totalCost: tWorkOrder.totalCost,
              notes: tWorkOrder.notes,
              createdAt: tWorkOrder.createdAt,
            );

            expect(result, isFalse);
          },
          expect: () => [
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.running(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.error(),
            ),
          ],
          verify: (_) {
            verify(() => mockGetAttachments(any())).called(1);
            verify(() => mockUploadAttachment(any())).called(1);
            verifyNever(() => mockGetWorkOrders(any()));
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should emit error when creation fails',
          build: () {
            when(
              () => mockCreateWorkOrder.call(any()),
            ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
            return cubit;
          },
          act: (cubit) async {
            final result = await cubit.saveWorkOrder(
              id: tWorkOrder.id,
              isEditing: false,
              assetId: tWorkOrder.assetId,
              locationId: tWorkOrder.locationId,
              assignedToId: tWorkOrder.assignedToId,
              createdById: tWorkOrder.createdById,
              maintenancePlanId: tWorkOrder.maintenancePlanId,
              title: tWorkOrder.title,
              description: tWorkOrder.description,
              priority: tWorkOrder.priority,
              status: tWorkOrder.status,
              type: tWorkOrder.type,
              scheduledDate: tWorkOrder.scheduledDate,
              startedAt: tWorkOrder.startedAt,
              completedAt: tWorkOrder.completedAt,
              estimatedDuration: tWorkOrder.estimatedDuration,
              actualDuration: tWorkOrder.actualDuration,
              laborCost: tWorkOrder.laborCost,
              partsCost: tWorkOrder.partsCost,
              totalCost: tWorkOrder.totalCost,
              notes: tWorkOrder.notes,
              createdAt: tWorkOrder.createdAt,
              serviceProviderCompanyId: tWorkOrder.serviceProviderCompanyId,
              providerProfileId: tWorkOrder.providerProfileId,
              openedBy: tWorkOrder.openedBy,
              slaPolicyId: tWorkOrder.slaPolicyId,
            );

            expect(result, isFalse);
          },
          expect: () => [
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.running(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.error(),
            ),
          ],
          verify: (_) {
            verify(() => mockCreateWorkOrder.call(any())).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should delete pending deletions attachments when saveWorkOrder succeeds',
          build: () {
            when(
              () => mockCreateWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetWorkOrders.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetChangeRequests.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockDeleteAttachment.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            return cubit;
          },
          act: (cubit) async {
            final mockAttachmentsCubit = MockAttachmentsCubit();
            when(
              mockAttachmentsCubit.refreshAttachments,
            ).thenAnswer((_) async {});
            when(() => mockAttachmentsCubit.state).thenReturn(
              const AttachmentsState(
                pendingDeletions: {'attachment_1', 'attachment_2'},
              ),
            );

            final result = await cubit.saveWorkOrder(
              id: tWorkOrder.id,
              isEditing: false,
              assetId: tWorkOrder.assetId,
              locationId: tWorkOrder.locationId,
              assignedToId: tWorkOrder.assignedToId,
              createdById: tWorkOrder.createdById,
              maintenancePlanId: tWorkOrder.maintenancePlanId,
              title: tWorkOrder.title,
              description: tWorkOrder.description,
              priority: tWorkOrder.priority,
              status: tWorkOrder.status,
              type: tWorkOrder.type,
              scheduledDate: tWorkOrder.scheduledDate,
              startedAt: tWorkOrder.startedAt,
              completedAt: tWorkOrder.completedAt,
              estimatedDuration: tWorkOrder.estimatedDuration,
              actualDuration: tWorkOrder.actualDuration,
              laborCost: tWorkOrder.laborCost,
              partsCost: tWorkOrder.partsCost,
              totalCost: tWorkOrder.totalCost,
              notes: tWorkOrder.notes,
              createdAt: tWorkOrder.createdAt,
              attachmentsCubit: mockAttachmentsCubit,
            );

            expect(result, isTrue);
          },
          verify: (_) {
            verify(() => mockDeleteAttachment.call('attachment_1')).called(1);
            verify(() => mockDeleteAttachment.call('attachment_2')).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should save pending attachments locally and then upload them when saveWorkOrder succeeds',
          build: () {
            final tAttachment = MaintenancePlanFactory.makeAttachmentEntity()
                .copyWith(uploadStatus: UploadStatus.pending);
            when(
              () => mockCreateWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetWorkOrders.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetChangeRequests.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockCreateAttachment.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetAttachments(any()),
            ).thenAnswer((_) async => SuccessState(data: [tAttachment]));
            when(
              () => mockUploadAttachment(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            return cubit;
          },
          act: (cubit) async {
            final mockAttachmentsCubit = MockAttachmentsCubit();
            final tAttachment = MaintenancePlanFactory.makeAttachmentEntity()
                .copyWith(uploadStatus: UploadStatus.pending);
            when(
              mockAttachmentsCubit.refreshAttachments,
            ).thenAnswer((_) async {});
            when(
              () => mockAttachmentsCubit.state,
            ).thenReturn(AttachmentsState(attachments: [tAttachment]));

            final result = await cubit.saveWorkOrder(
              id: tWorkOrder.id,
              isEditing: false,
              assetId: tWorkOrder.assetId,
              locationId: tWorkOrder.locationId,
              assignedToId: tWorkOrder.assignedToId,
              createdById: tWorkOrder.createdById,
              maintenancePlanId: tWorkOrder.maintenancePlanId,
              title: tWorkOrder.title,
              description: tWorkOrder.description,
              priority: tWorkOrder.priority,
              status: tWorkOrder.status,
              type: tWorkOrder.type,
              scheduledDate: tWorkOrder.scheduledDate,
              startedAt: tWorkOrder.startedAt,
              completedAt: tWorkOrder.completedAt,
              estimatedDuration: tWorkOrder.estimatedDuration,
              actualDuration: tWorkOrder.actualDuration,
              laborCost: tWorkOrder.laborCost,
              partsCost: tWorkOrder.partsCost,
              totalCost: tWorkOrder.totalCost,
              notes: tWorkOrder.notes,
              createdAt: tWorkOrder.createdAt,
              attachmentsCubit: mockAttachmentsCubit,
            );

            expect(result, isTrue);
          },
          verify: (_) {
            verify(() => mockCreateAttachment.call(any())).called(1);
            verify(() => mockUploadAttachment(any())).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should not delete pending attachments when creation fails',
          build: () {
            when(
              () => mockCreateWorkOrder.call(any()),
            ).thenAnswer((_) async => FailureState(message: 'Error'));
            return cubit;
          },
          act: (cubit) async {
            final mockAttachmentsCubit = MockAttachmentsCubit();
            when(() => mockAttachmentsCubit.state).thenReturn(
              const AttachmentsState(
                pendingDeletions: {'attachment_1', 'attachment_2'},
              ),
            );

            final result = await cubit.saveWorkOrder(
              id: tWorkOrder.id,
              isEditing: false,
              assetId: tWorkOrder.assetId,
              locationId: tWorkOrder.locationId,
              assignedToId: tWorkOrder.assignedToId,
              createdById: tWorkOrder.createdById,
              maintenancePlanId: tWorkOrder.maintenancePlanId,
              title: tWorkOrder.title,
              description: tWorkOrder.description,
              priority: tWorkOrder.priority,
              status: tWorkOrder.status,
              type: tWorkOrder.type,
              scheduledDate: tWorkOrder.scheduledDate,
              startedAt: tWorkOrder.startedAt,
              completedAt: tWorkOrder.completedAt,
              estimatedDuration: tWorkOrder.estimatedDuration,
              actualDuration: tWorkOrder.actualDuration,
              laborCost: tWorkOrder.laborCost,
              partsCost: tWorkOrder.partsCost,
              totalCost: tWorkOrder.totalCost,
              notes: tWorkOrder.notes,
              createdAt: tWorkOrder.createdAt,
              attachmentsCubit: mockAttachmentsCubit,
            );

            expect(result, isFalse);
          },
          expect: () => [
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.running(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.error(),
            ),
          ],
          verify: (_) {
            verifyNever(() => mockDeleteAttachment.call(any()));
          },
        );
      });

      group('update', () {
        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should emit loaded and call updateWorkOrder when editing',
          seed: () => const WorkOrdersState.initial().copyWith(
            workOrders: [tWorkOrder],
          ),
          build: () {
            when(
              () => mockUpdateWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetWorkOrders.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetChangeRequests.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            return cubit;
          },
          act: (cubit) => cubit.saveWorkOrder(
            id: tWorkOrder.id,
            isEditing: true,
            assetId: tWorkOrder.assetId,
            locationId: tWorkOrder.locationId,
            assignedToId: tWorkOrder.assignedToId,
            createdById: tWorkOrder.createdById,
            maintenancePlanId: tWorkOrder.maintenancePlanId,
            title: tWorkOrder.title,
            description: tWorkOrder.description,
            priority: tWorkOrder.priority,
            status: tWorkOrder.status,
            type: tWorkOrder.type,
            scheduledDate: tWorkOrder.scheduledDate,
            startedAt: tWorkOrder.startedAt,
            completedAt: tWorkOrder.completedAt,
            estimatedDuration: tWorkOrder.estimatedDuration,
            actualDuration: tWorkOrder.actualDuration,
            laborCost: tWorkOrder.laborCost,
            partsCost: tWorkOrder.partsCost,
            totalCost: tWorkOrder.totalCost,
            notes: tWorkOrder.notes,
            createdAt: tWorkOrder.createdAt,
            serviceProviderCompanyId: tWorkOrder.serviceProviderCompanyId,
            providerProfileId: tWorkOrder.providerProfileId,
            openedBy: tWorkOrder.openedBy,
            slaPolicyId: tWorkOrder.slaPolicyId,
          ),
          expect: () => [
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.running(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.success(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[BaseSections.load],
              'sections[load]',
              const SectionState.success(),
            ),
          ],
          verify: (_) {
            verify(
              () => mockUpdateWorkOrder.call(
                any(
                  that: predicate<WorkOrderEntity>((actual) {
                    return actual.id == tWorkOrder.id &&
                        actual.title == tWorkOrder.title &&
                        actual.priority == tWorkOrder.priority &&
                        actual.type == tWorkOrder.type;
                  }),
                ),
              ),
            ).called(1);
            verify(() => mockGetWorkOrders.call(any())).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should emit error when update fails',
          seed: () => const WorkOrdersState.initial().copyWith(
            workOrders: [tWorkOrder],
          ),
          build: () {
            when(
              () => mockUpdateWorkOrder.call(any()),
            ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
            return cubit;
          },
          act: (cubit) => cubit.saveWorkOrder(
            id: tWorkOrder.id,
            isEditing: true,
            assetId: tWorkOrder.assetId,
            locationId: tWorkOrder.locationId,
            assignedToId: tWorkOrder.assignedToId,
            createdById: tWorkOrder.createdById,
            maintenancePlanId: tWorkOrder.maintenancePlanId,
            title: tWorkOrder.title,
            description: tWorkOrder.description,
            priority: tWorkOrder.priority,
            status: tWorkOrder.status,
            type: tWorkOrder.type,
            scheduledDate: tWorkOrder.scheduledDate,
            startedAt: tWorkOrder.startedAt,
            completedAt: tWorkOrder.completedAt,
            estimatedDuration: tWorkOrder.estimatedDuration,
            actualDuration: tWorkOrder.actualDuration,
            laborCost: tWorkOrder.laborCost,
            partsCost: tWorkOrder.partsCost,
            totalCost: tWorkOrder.totalCost,
            notes: tWorkOrder.notes,
            createdAt: tWorkOrder.createdAt,
            serviceProviderCompanyId: tWorkOrder.serviceProviderCompanyId,
            providerProfileId: tWorkOrder.providerProfileId,
            openedBy: tWorkOrder.openedBy,
            slaPolicyId: tWorkOrder.slaPolicyId,
          ),
          expect: () => [
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.running(),
            ),
            isA<WorkOrdersState>().having(
              (s) => s.sections[WorkOrdersSections.saveWorkOrder],
              'sections[saveWorkOrder]',
              const SectionState.error(),
            ),
          ],
          verify: (_) {
            verify(
              () => mockUpdateWorkOrder.call(
                any(
                  that: predicate<WorkOrderEntity>((actual) {
                    return actual.id == tWorkOrder.id &&
                        actual.title == tWorkOrder.title &&
                        actual.priority == tWorkOrder.priority &&
                        actual.type == tWorkOrder.type;
                  }),
                ),
              ),
            ).called(1);
            verifyNever(() => mockGetWorkOrders.call(any()));
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should set startedAt to current time when state changes to inProgress and startedAt is null',
          seed: () => const WorkOrdersState.initial().copyWith(
            workOrders: [tWorkOrder],
          ),
          build: () {
            when(
              () => mockUpdateWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetWorkOrders.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetChangeRequests.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            return cubit;
          },
          act: (cubit) => cubit.saveWorkOrder(
            id: tWorkOrder.id,
            isEditing: true,
            locationId: tWorkOrder.locationId,
            createdById: tWorkOrder.createdById,
            title: tWorkOrder.title,
            priority: tWorkOrder.priority,
            status: WorkOrderStatus.inProgress,
            type: tWorkOrder.type,
          ),
          verify: (_) {
            verify(
              () => mockUpdateWorkOrder.call(
                any(
                  that: predicate<WorkOrderEntity>(
                    (actual) => actual.startedAt != null,
                  ),
                ),
              ),
            ).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should set completedAt to current time when state changes to completed and completedAt is null',
          seed: () => const WorkOrdersState.initial().copyWith(
            workOrders: [tWorkOrder],
          ),
          build: () {
            when(
              () => mockUpdateWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetWorkOrders.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetChangeRequests.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            return cubit;
          },
          act: (cubit) => cubit.saveWorkOrder(
            id: tWorkOrder.id,
            isEditing: true,
            locationId: tWorkOrder.locationId,
            createdById: tWorkOrder.createdById,
            title: tWorkOrder.title,
            priority: tWorkOrder.priority,
            status: WorkOrderStatus.completed,
            type: tWorkOrder.type,
          ),
          verify: (_) {
            verify(
              () => mockUpdateWorkOrder.call(
                any(
                  that: predicate<WorkOrderEntity>(
                    (actual) => actual.completedAt != null,
                  ),
                ),
              ),
            ).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should clear completedAt (set to null) when state changes to open, inProgress, or onHold',
          seed: () => WorkOrdersState(
            workOrders: [
              tWorkOrder.copyWith(status: WorkOrderStatus.completed),
            ],
            changeRequests: const [],
          ),
          build: () {
            when(
              () => mockUpdateWorkOrder.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetWorkOrders.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetChangeRequests.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            return cubit;
          },
          act: (cubit) => cubit.saveWorkOrder(
            id: tWorkOrder.id,
            isEditing: true,
            locationId: tWorkOrder.locationId,
            createdById: tWorkOrder.createdById,
            title: tWorkOrder.title,
            priority: tWorkOrder.priority,
            status: WorkOrderStatus.open,
            type: tWorkOrder.type,
            completedAt: DateTime.now(),
          ),
          verify: (_) {
            verify(
              () => mockUpdateWorkOrder.call(
                any(
                  that: predicate<WorkOrderEntity>(
                    (actual) => actual.completedAt == null,
                  ),
                ),
              ),
            ).called(1);
          },
        );
      });

      group('Navigation', () {
        late MockAttachmentsCubit tAttachmentsCubitFailure;

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'navigateToCreateUpdateWorkOrder should push CreateUpdateWorkOrderRoute and NOT init attachmentsCubit if result is not true',
          build: () {
            tAttachmentsCubitFailure = MockAttachmentsCubit();
            when(
              () => mockNavigationClient.pushRoute<dynamic>(any()),
            ).thenAnswer((_) async => null);
            return cubit;
          },
          act: (cubit) {
            return cubit.navigateToCreateUpdateWorkOrder(
              'work-order-id',
              attachmentsCubit: tAttachmentsCubitFailure,
            );
          },
          expect: () => <WorkOrdersState>[],
          verify: (cubit) {
            verify(
              () => mockNavigationClient.pushRoute<dynamic>(any()),
            ).called(1);
            // Verify init is never called on our mock attachments cubit
            verifyNever(() => tAttachmentsCubitFailure.refreshAttachments());
          },
        );

        late MockAttachmentsCubit tAttachmentsCubit;

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'navigateToCreateUpdateWorkOrder should push CreateUpdateWorkOrderRoute and init attachmentsCubit if result is true',
          build: () {
            tAttachmentsCubit = MockAttachmentsCubit();
            when(() => tAttachmentsCubit.refreshAttachments()).thenAnswer((
              _,
            ) async {
              return;
            });
            when(
              () => mockNavigationClient.pushRoute<dynamic>(any()),
            ).thenAnswer((_) async => true);
            return cubit;
          },
          act: (cubit) {
            return cubit.navigateToCreateUpdateWorkOrder(
              'work-order-id',
              attachmentsCubit: tAttachmentsCubit,
            );
          },
          expect: () => <WorkOrdersState>[],
          verify: (cubit) {
            verify(
              () => mockNavigationClient.pushRoute<dynamic>(any()),
            ).called(1);
            verify(() => tAttachmentsCubit.refreshAttachments()).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'navigateToWorkOrderDetails should push WorkOrderDetailsRoute',
          build: () {
            when(
              () => mockNavigationClient.pushRoute<WorkOrderDetailsRouteArgs>(
                any(),
              ),
            ).thenAnswer((_) async => null);
            return cubit;
          },
          act: (cubit) => cubit.navigateToWorkOrderDetails('123'),
          expect: () => <WorkOrdersState>[],
          verify: (cubit) {
            verify(
              () => mockNavigationClient.pushRoute<WorkOrderDetailsRouteArgs>(
                any(),
              ),
            ).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'navigateToWorkOrderPendingRequests should push WorkOrderPendingRequestsRoute',
          build: () {
            when(
              () => mockNavigationClient
                  .pushRoute<WorkOrderPendingRequestsRouteArgs>(any()),
            ).thenAnswer((_) async => null);
            return cubit;
          },
          act: (cubit) => cubit.navigateToWorkOrderPendingRequests(
            WorkOrderFactory.makeWorkOrderEntity(),
            faker.guid.guid(),
          ),
          expect: () => <WorkOrdersState>[],
          verify: (cubit) {
            verify(
              () => mockNavigationClient
                  .pushRoute<WorkOrderPendingRequestsRouteArgs>(any()),
            ).called(1);
          },
        );
      });

      group('syncWorkOrders', () {
        test('returns true on sync success', () async {
          when(
            () => mockSyncWorkOrders.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await cubit.syncWorkOrders();

          expect(result, true);
          verify(
            () => mockSyncWorkOrders.call(tUserProfile.companyId),
          ).called(1);
        });

        test('returns false on sync failure', () async {
          when(
            () => mockSyncWorkOrders.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Sync error'));

          final result = await cubit.syncWorkOrders();

          expect(result, false);
          verify(
            () => mockSyncWorkOrders.call(tUserProfile.companyId),
          ).called(1);
        });

        test(
          'refreshes work orders when syncEngine emits onSyncCompleted',
          () async {
            final syncController = StreamController<void>.broadcast();
            when(
              () => mockSyncEngine.onSyncCompleted,
            ).thenAnswer((_) => syncController.stream);
            when(
              () => mockGetWorkOrders(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            when(
              () => mockGetChangeRequests(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));

            final useCases = WorkOrdersCubitUseCases(
              getActiveCompanyId: mockGetActiveCompanyId,
              getWorkOrders: mockGetWorkOrders,
              getWorkOrderById: mockGetWorkOrderById,
              createWorkOrder: mockCreateWorkOrder,
              updateWorkOrder: mockUpdateWorkOrder,
              getChangeRequests: mockGetChangeRequests,
              getAttachments: mockGetAttachments,
              uploadAttachment: mockUploadAttachment,
              deleteAttachment: mockDeleteAttachment,
              createAttachment: mockCreateAttachment,
              syncWorkOrders: mockSyncWorkOrders,
              syncEngine: mockSyncEngine,
              watchWorkOrdersRealtime: mockWatchWorkOrdersRealtime,
              getProviderWorkOrders: mockGetProviderWorkOrders,
              getSessionProviderProfile: mockGetSessionProviderProfile,
              getServiceProviderProfilesByAuthUser:
                  mockGetServiceProviderProfilesByAuthUser,
              getServiceProviderCompaniesByIds:
                  mockGetServiceProviderCompaniesByIds,
              getSessionUser: mockGetSessionUser,
              getSelectedMode: mockGetSelectedMode,
            );

            final testCubit = WorkOrdersCubit(useCases: useCases);
            syncController.add(null);
            await pumpEventQueue();

            verify(() => mockGetWorkOrders(any())).called(1);
            await testCubit.close();
            await syncController.close();
          },
        );
      });

      group('Realtime Work Order Events', () {
        late StreamController<RealtimeEvent<WorkOrderEntity>>
        realtimeController;

        setUp(() {
          realtimeController =
              StreamController<RealtimeEvent<WorkOrderEntity>>.broadcast();
          when(
            () =>
                mockWatchWorkOrdersRealtime(companyId: any(named: 'companyId')),
          ).thenAnswer((_) => realtimeController.stream);
          cubit = WorkOrdersCubit(useCases: useCases);
        });

        tearDown(() {
          realtimeController.close();
        });

        test('updates work order in-place when UPDATE event arrives', () async {
          final existingOrder = WorkOrderFactory.makeWorkOrderEntity();
          final updatedOrder = existingOrder.copyWith(
            title: 'Updated in Realtime',
          );

          when(
            () => mockGetWorkOrders(any()),
          ).thenAnswer((_) async => SuccessState(data: [existingOrder]));
          when(
            () => mockGetChangeRequests(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));

          await cubit.loadWorkOrdersAndChangeRequests();

          expect(cubit.state.workOrders.first.title, existingOrder.title);

          realtimeController.add(
            RealtimeEvent<WorkOrderEntity>(
              eventType: RealtimeEventType.update,
              id: existingOrder.id,
              entity: updatedOrder,
            ),
          );

          await pumpEventQueue();

          expect(cubit.state.workOrders.first.title, 'Updated in Realtime');
        });

        test('prepends new work order when INSERT event arrives', () async {
          final newOrder = WorkOrderFactory.makeWorkOrderEntity();

          realtimeController.add(
            RealtimeEvent<WorkOrderEntity>(
              eventType: RealtimeEventType.insert,
              id: newOrder.id,
              entity: newOrder,
            ),
          );

          await pumpEventQueue();

          expect(cubit.state.workOrders, contains(newOrder));
        });

        test(
          'removes work order when UPDATE event arrives with deletedAt not null',
          () async {
            final existingOrder = WorkOrderFactory.makeWorkOrderEntity();
            final softDeletedOrder = existingOrder.copyWith(
              deletedAt: DateTime.now(),
            );

            when(
              () => mockGetWorkOrders(any()),
            ).thenAnswer((_) async => SuccessState(data: [existingOrder]));
            when(
              () => mockGetChangeRequests(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));

            await cubit.loadWorkOrdersAndChangeRequests();
            expect(cubit.state.workOrders.length, 1);

            realtimeController.add(
              RealtimeEvent<WorkOrderEntity>(
                eventType: RealtimeEventType.update,
                id: existingOrder.id,
                entity: softDeletedOrder,
              ),
            );

            await pumpEventQueue();

            expect(cubit.state.workOrders, isEmpty);
          },
        );

        test('removes work order when DELETE event arrives', () async {
          final existingOrder = WorkOrderFactory.makeWorkOrderEntity();

          when(
            () => mockGetWorkOrders(any()),
          ).thenAnswer((_) async => SuccessState(data: [existingOrder]));
          when(
            () => mockGetChangeRequests(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));

          await cubit.loadWorkOrdersAndChangeRequests();
          expect(cubit.state.workOrders.length, 1);

          realtimeController.add(
            RealtimeEvent<WorkOrderEntity>(
              eventType: RealtimeEventType.delete,
              id: existingOrder.id,
            ),
          );

          await pumpEventQueue();

          expect(cubit.state.workOrders, isEmpty);
        });
      });
    });

    providerModeTests();
  });
}

void providerModeTests() {
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetWorkOrdersUseCase mockGetWorkOrders;
  late MockGetProviderWorkOrdersUseCase mockGetProviderWorkOrders;
  late MockGetSessionProviderProfileUseCase mockGetSessionProviderProfile;
  late MockGetServiceProviderProfilesByAuthUserUseCase
  mockGetServiceProviderProfilesByAuthUser;
  late MockGetServiceProviderCompaniesByIdsUseCase
  mockGetServiceProviderCompaniesByIds;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetSelectedModeUseCase mockGetSelectedMode;
  late MockWatchWorkOrdersRealtimeUseCase mockWatchWorkOrdersRealtime;
  late MockUpdateWorkOrderUseCase mockUpdateWorkOrder;
  late MockCreateWorkOrderUseCase mockCreateWorkOrder;
  late WorkOrderEntity tWorkOrder;
  late MockGetAttachmentsUseCase mockGetAttachments;
  late MockSyncEngine mockSyncEngine;
  late UserProfileEntity tUserProfile;
  late List<ServiceProviderCompanyEntity> tCompanies;
  late List<ServiceProviderProfileEntity> tProfiles;

  WorkOrdersCubit buildCubit() => WorkOrdersCubit(
    useCases: WorkOrdersCubitUseCases(
      getActiveCompanyId: mockGetActiveCompanyId,
      getWorkOrders: mockGetWorkOrders,
      getWorkOrderById: MockGetWorkOrderByIdUseCase(),
      createWorkOrder: mockCreateWorkOrder,
      updateWorkOrder: mockUpdateWorkOrder,
      getChangeRequests: MockGetWorkOrderChangeRequestsUseCase(),
      getAttachments: mockGetAttachments,
      uploadAttachment: MockUploadAttachmentUseCase(),
      deleteAttachment: MockDeleteAttachmentUseCase(),
      createAttachment: MockCreateAttachmentUseCase(),
      syncWorkOrders: MockSyncWorkOrdersUseCase(),
      syncEngine: mockSyncEngine,
      watchWorkOrdersRealtime: mockWatchWorkOrdersRealtime,
      getProviderWorkOrders: mockGetProviderWorkOrders,
      getSessionProviderProfile: mockGetSessionProviderProfile,
      getServiceProviderProfilesByAuthUser:
          mockGetServiceProviderProfilesByAuthUser,
      getServiceProviderCompaniesByIds: mockGetServiceProviderCompaniesByIds,
      getSessionUser: mockGetSessionUser,
      getSelectedMode: mockGetSelectedMode,
    ),
  );

  group('provider mode', () {
    setUpAll(() {
      registerFallbackValue(
        const GetProviderWorkOrdersParams(serviceProviderCompanyIds: []),
      );
      registerFallbackValue(const WorkOrderFilter());
    });

    setUp(() {
      mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
      mockGetWorkOrders = MockGetWorkOrdersUseCase();
      mockGetProviderWorkOrders = MockGetProviderWorkOrdersUseCase();
      mockGetSessionProviderProfile = MockGetSessionProviderProfileUseCase();
      mockGetServiceProviderProfilesByAuthUser =
          MockGetServiceProviderProfilesByAuthUserUseCase();
      mockGetServiceProviderCompaniesByIds =
          MockGetServiceProviderCompaniesByIdsUseCase();
      mockGetSessionUser = MockGetSessionUserUseCase();
      mockGetSelectedMode = MockGetSelectedModeUseCase();
      mockWatchWorkOrdersRealtime = MockWatchWorkOrdersRealtimeUseCase();
      mockUpdateWorkOrder = MockUpdateWorkOrderUseCase();
      mockCreateWorkOrder = MockCreateWorkOrderUseCase();
      mockGetAttachments = MockGetAttachmentsUseCase();
      mockSyncEngine = MockSyncEngine();
      when(
        () => mockSyncEngine.onSyncCompleted,
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => mockWatchWorkOrdersRealtime(companyId: any(named: 'companyId')),
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => mockGetAttachments(any()),
      ).thenAnswer((_) async => const SuccessState(data: []));

      tUserProfile = UserFactory.makeUserProfileEntity();
      tCompanies =
          ServiceProviderFactory.makeServiceProviderCompanyEntityList();
      // A work order owned by a contracting company the provider serves —
      // deliberately not the provider user's own internal company.
      tWorkOrder = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        serviceProviderCompanyId: tCompanies.first.id,
      );
      tProfiles = [
        for (final company in tCompanies)
          ServiceProviderFactory.makeServiceProviderProfileEntity().copyWith(
            authUserId: tUserProfile.id,
            serviceProviderCompanyId: company.id,
          ),
      ];

      when(() => mockGetSelectedMode.call()).thenReturn(AppMode.provider.name);
      when(() => mockGetSessionUser.call()).thenReturn(tUserProfile);
      when(
        () => mockGetServiceProviderProfilesByAuthUser(any()),
      ).thenAnswer((_) async => SuccessState(data: tProfiles));
      when(
        () => mockGetServiceProviderCompaniesByIds(any()),
      ).thenAnswer((_) async => SuccessState(data: tCompanies));
    });

    blocTest<WorkOrdersCubit, WorkOrdersState>(
      'loadProviderWorkOrders spans every provider company the user belongs to',
      build: () {
        when(() => mockGetProviderWorkOrders(any())).thenAnswer(
          (_) async =>
              SuccessState(data: WorkOrderFactory.makeWorkOrderEntityList()),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadProviderWorkOrders(),
      verify: (cubit) {
        final params =
            verify(
                  () => mockGetProviderWorkOrders(captureAny()),
                ).captured.single
                as GetProviderWorkOrdersParams;
        expect(
          params.serviceProviderCompanyIds,
          containsAll(tCompanies.map((company) => company.id)),
        );
        expect(cubit.state.providerCompanies, hasLength(tCompanies.length));
        expect(
          cubit.state.sections[BaseSections.load],
          const SectionState.success(),
        );
      },
    );

    blocTest<WorkOrdersCubit, WorkOrdersState>(
      'never calls the internal company-scoped use case',
      build: () {
        when(() => mockGetProviderWorkOrders(any())).thenAnswer(
          (_) async => const SuccessState(data: <WorkOrderEntity>[]),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadProviderWorkOrders(),
      verify: (_) => verifyNever(() => mockGetWorkOrders(any())),
    );

    blocTest<WorkOrdersCubit, WorkOrdersState>(
      'selectProviderCompany narrows the scope to one company',
      build: () {
        when(() => mockGetProviderWorkOrders(any())).thenAnswer(
          (_) async => const SuccessState(data: <WorkOrderEntity>[]),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProviderWorkOrders();
        await cubit.selectProviderCompany(tCompanies.first.id);
      },
      verify: (cubit) {
        expect(cubit.state.selectedProviderCompanyId, tCompanies.first.id);
        expect(cubit.state.activeFilter.serviceProviderCompanyIds, [
          tCompanies.first.id,
        ]);
      },
    );

    blocTest<WorkOrdersCubit, WorkOrdersState>(
      'selectProviderCompany(null) restores every company',
      build: () {
        when(() => mockGetProviderWorkOrders(any())).thenAnswer(
          (_) async => const SuccessState(data: <WorkOrderEntity>[]),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProviderWorkOrders();
        await cubit.selectProviderCompany(tCompanies.first.id);
        await cubit.selectProviderCompany(null);
      },
      verify: (cubit) {
        expect(cubit.state.selectedProviderCompanyId, isNull);
        expect(cubit.state.activeFilter.serviceProviderCompanyIds, isEmpty);
      },
    );

    blocTest<WorkOrdersCubit, WorkOrdersState>(
      'applyFilter routes to the provider path and keeps the company scope',
      build: () {
        when(() => mockGetProviderWorkOrders(any())).thenAnswer(
          (_) async => const SuccessState(data: <WorkOrderEntity>[]),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProviderWorkOrders();
        await cubit.selectProviderCompany(tCompanies.first.id);
        await cubit.applyFilter(
          WorkOrderFilter(searchText: faker.lorem.word()),
        );
      },
      verify: (cubit) {
        verifyNever(() => mockGetWorkOrders(any()));
        expect(cubit.state.activeFilter.serviceProviderCompanyIds, [
          tCompanies.first.id,
        ]);
      },
    );

    blocTest<WorkOrdersCubit, WorkOrdersState>(
      'emits loaded with no work orders when the user has no provider profile',
      build: () {
        when(
          () => mockGetServiceProviderProfilesByAuthUser(any()),
        ).thenAnswer((_) async => const SuccessState(data: []));
        return buildCubit();
      },
      act: (cubit) => cubit.loadProviderWorkOrders(),
      verify: (cubit) {
        expect(
          cubit.state.sections[BaseSections.load],
          const SectionState.success(),
        );
        expect(cubit.state.workOrders, isEmpty);
        expect(cubit.state.providerCompanies, isEmpty);
        verifyNever(() => mockGetProviderWorkOrders(any()));
      },
    );

    blocTest<WorkOrdersCubit, WorkOrdersState>(
      'editing keeps the work order company instead of the active one',
      build: () {
        when(
          () => mockGetProviderWorkOrders(any()),
        ).thenAnswer((_) async => SuccessState(data: [tWorkOrder]));
        when(
          () => mockUpdateWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockGetActiveCompanyId.call(),
        ).thenReturn(tUserProfile.companyId);
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProviderWorkOrders();
        await cubit.saveWorkOrder(
          id: tWorkOrder.id,
          isEditing: true,
          locationId: tWorkOrder.locationId,
          createdById: tWorkOrder.createdById,
          title: tWorkOrder.title,
          priority: tWorkOrder.priority,
          status: tWorkOrder.status,
          type: tWorkOrder.type,
        );
      },
      verify: (_) {
        final saved =
            verify(() => mockUpdateWorkOrder(captureAny())).captured.last
                as WorkOrderEntity;
        // Reassigning the record to the active company would move it across
        // tenants.
        expect(saved.companyId, tWorkOrder.companyId);
        expect(saved.companyId, isNot(tUserProfile.companyId));
      },
    );

    group('createProviderWorkOrder', () {
      void stubCreation() {
        when(
          () => mockGetSessionProviderProfile(any()),
        ).thenAnswer((_) async => SuccessState(data: tProfiles.first));
        when(
          () => mockCreateWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(() => mockGetProviderWorkOrders(any())).thenAnswer(
          (_) async => const SuccessState(data: <WorkOrderEntity>[]),
        );
      }

      Future<void> create(
        WorkOrdersCubit cubit, {
        String? serviceProviderCompanyId,
      }) => cubit.createProviderWorkOrder(
        id: faker.guid.guid(),
        locationId: faker.guid.guid(),
        title: faker.lorem.sentence(),
        priority: Priority.medium,
        type: WorkOrderType.corrective,
        serviceProviderCompanyId: serviceProviderCompanyId,
      );

      WorkOrderEntity capturedWorkOrder() =>
          verify(() => mockCreateWorkOrder(captureAny())).captured.single
              as WorkOrderEntity;

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'opens for the company the list is filtered to',
        build: () {
          stubCreation();
          return buildCubit();
        },
        act: (cubit) async {
          await cubit.loadProviderWorkOrders();
          await cubit.selectProviderCompany(tCompanies.last.id);
          await create(cubit);
        },
        verify: (_) {
          final created = capturedWorkOrder();
          expect(created.companyId, tCompanies.last.companyId);
          expect(created.serviceProviderCompanyId, tCompanies.last.id);
          expect(created.providerProfileId, tProfiles.first.id);
          expect(created.createdByProviderProfileId, tProfiles.first.id);
          expect(created.createdById, isNull);
          expect(created.openedBy, AppMode.provider);
          expect(created.status, WorkOrderStatus.open);
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'an explicit choice wins over the list filter',
        build: () {
          stubCreation();
          return buildCubit();
        },
        act: (cubit) async {
          await cubit.loadProviderWorkOrders();
          await cubit.selectProviderCompany(tCompanies.last.id);
          await create(cubit, serviceProviderCompanyId: tCompanies.first.id);
        },
        verify: (_) {
          final created = capturedWorkOrder();
          expect(created.companyId, tCompanies.first.companyId);
          expect(created.serviceProviderCompanyId, tCompanies.first.id);
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'refuses to guess when several companies are unfiltered',
        build: () {
          stubCreation();
          return buildCubit();
        },
        act: (cubit) async {
          await cubit.loadProviderWorkOrders();
          await create(cubit);
        },
        verify: (_) {
          verifyNever(() => mockCreateWorkOrder(any()));
          verifyNever(() => mockGetSessionProviderProfile(any()));
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'does not create when the provider profile cannot be resolved',
        build: () {
          stubCreation();
          when(() => mockGetSessionProviderProfile(any())).thenAnswer(
            (_) async => FailureState<ServiceProviderProfileEntity>(
              message: 'Perfil de prestador não encontrado.',
            ),
          );
          return buildCubit();
        },
        act: (cubit) async {
          await cubit.loadProviderWorkOrders();
          await cubit.selectProviderCompany(tCompanies.first.id);
          await create(cubit);
        },
        verify: (cubit) {
          verifyNever(() => mockCreateWorkOrder(any()));
          expect(
            cubit.state.sections[WorkOrdersSections.saveWorkOrder],
            const SectionState.error('Perfil de prestador não encontrado.'),
          );
        },
      );
    });

    blocTest<WorkOrdersCubit, WorkOrdersState>(
      'surfaces the failure message when the provider fetch fails',
      build: () {
        when(() => mockGetProviderWorkOrders(any())).thenAnswer(
          (_) async =>
              FailureState<List<WorkOrderEntity>>(message: 'Sem internet'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadProviderWorkOrders(),
      verify: (cubit) {
        expect(
          cubit.state.sections[BaseSections.load],
          const SectionState.error('Sem internet'),
        );
      },
    );
  });
}
