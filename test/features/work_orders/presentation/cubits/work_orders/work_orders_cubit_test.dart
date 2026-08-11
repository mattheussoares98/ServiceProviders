import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/create_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/upload_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_change_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetWorkOrdersUseCase extends Mock implements GetWorkOrdersUseCase {}

class MockCreateWorkOrderUseCase extends Mock
    implements CreateWorkOrderUseCase {}

class MockUpdateWorkOrderUseCase extends Mock
    implements UpdateWorkOrderUseCase {}

class MockDeleteWorkOrderUseCase extends Mock
    implements DeleteWorkOrderUseCase {}

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

class MockGetActiveCompanyIdUseCase extends Mock
    implements GetActiveCompanyIdUseCase {}

class MockAttachmentsCubit extends MockCubit<AttachmentsState>
    implements AttachmentsCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetWorkOrdersUseCase mockGetWorkOrders;
  late MockCreateWorkOrderUseCase mockCreateWorkOrder;
  late MockUpdateWorkOrderUseCase mockUpdateWorkOrder;
  late MockDeleteWorkOrderUseCase mockDeleteWorkOrder;
  late MockGetWorkOrderChangeRequestsUseCase mockGetChangeRequests;
  late MockCreateWorkOrderChangeRequestUseCase mockCreateChangeRequest;
  late MockReviewWorkOrderChangeRequestUseCase mockReviewChangeRequest;
  late MockGetWorkOrderHistoryUseCase mockGetWorkOrderHistory;
  late MockGetAttachmentsUseCase mockGetAttachments;
  late MockUploadAttachmentUseCase mockUploadAttachment;
  late MockDeleteAttachmentUseCase mockDeleteAttachment;
  late MockCreateAttachmentUseCase mockCreateAttachment;
  late MockNavigationClient mockNavigationClient;

  late WorkOrdersCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeWorkOrderEntity());
    registerFallbackValue(EntityFactory.makeWorkOrderChangeRequestEntity());
    registerFallbackValue(EntityFactory.makeWorkOrderHistoryEntity());
    registerFallbackValue(
      const ReviewChangeRequestParams(
        id: '',
        status: ChangeRequestStatus.pending,
        reviewedById: '',
      ),
    );
    registerFallbackValue(EntityFactory.makeAttachmentEntity());
    registerFallbackValue(CreateUpdateWorkOrderRoute());
    registerFallbackValue(WorkOrderDetailsRoute(workOrderId: ''));
    registerFallbackValue(const GetWorkOrdersParams(companyId: ''));
  });

  setUp(() {
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockGetWorkOrders = MockGetWorkOrdersUseCase();
    mockCreateWorkOrder = MockCreateWorkOrderUseCase();
    mockUpdateWorkOrder = MockUpdateWorkOrderUseCase();
    mockDeleteWorkOrder = MockDeleteWorkOrderUseCase();
    mockGetChangeRequests = MockGetWorkOrderChangeRequestsUseCase();
    mockCreateChangeRequest = MockCreateWorkOrderChangeRequestUseCase();
    mockReviewChangeRequest = MockReviewWorkOrderChangeRequestUseCase();
    mockGetWorkOrderHistory = MockGetWorkOrderHistoryUseCase();
    mockGetAttachments = MockGetAttachmentsUseCase();
    mockUploadAttachment = MockUploadAttachmentUseCase();
    mockDeleteAttachment = MockDeleteAttachmentUseCase();
    mockNavigationClient = MockNavigationClient();
    mockCreateAttachment = MockCreateAttachmentUseCase();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = EntityFactory.makeUserProfileEntity();

    when(
      () => mockGetActiveCompanyId.call(),
    ).thenReturn(tUserProfile.companyId);
    when(
      () => mockGetAttachments(any()),
    ).thenAnswer((_) async => const SuccessState(data: []));
    when(
      () => mockUploadAttachment(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockDeleteAttachment(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));

    final useCases = WorkOrdersCubitUseCases(
      getActiveCompanyId: mockGetActiveCompanyId,
      getWorkOrders: mockGetWorkOrders,
      createWorkOrder: mockCreateWorkOrder,
      updateWorkOrder: mockUpdateWorkOrder,
      deleteWorkOrder: mockDeleteWorkOrder,
      getChangeRequests: mockGetChangeRequests,
      createChangeRequest: mockCreateChangeRequest,
      reviewChangeRequest: mockReviewChangeRequest,
      getWorkOrderHistory: mockGetWorkOrderHistory,
      getAttachments: mockGetAttachments,
      uploadAttachment: mockUploadAttachment,
      deleteAttachment: mockDeleteAttachment,
      createAttachment: mockCreateAttachment,
    );

    cubit = WorkOrdersCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('WorkOrdersCubit Tests', () {
    group('loadWorkOrdersAndChangeRequests', () {
      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit loading and loaded when data loads successfully',
        build: () {
          final tWorkOrders = EntityFactory.makeWorkOrderEntityList();
          final tChangeRequests =
              EntityFactory.makeWorkOrderChangeRequestEntityList();
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
          isA<WorkOrdersState>()
              .having((s) => s.status, 'status', StateStatus.initial)
              .having(
                (s) => s.activeFilter.statuses,
                'activeFilter.statuses',
                const WorkOrderFilter().statuses,
              ),
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<WorkOrdersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.workOrders, 'workOrders', isNotEmpty)
              .having((s) => s.changeRequests, 'changeRequests', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
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
          final tWorkOrders = EntityFactory.makeWorkOrderEntityList();
          final tChangeRequests =
              EntityFactory.makeWorkOrderChangeRequestEntityList();
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
              .having((s) => s.status, 'status', StateStatus.initial)
              .having(
                (s) => s.activeFilter.statuses,
                'activeFilter.statuses',
                const WorkOrderFilter().statuses,
              ),
          isA<WorkOrdersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.workOrders, 'workOrders', isNotEmpty)
              .having((s) => s.changeRequests, 'changeRequests', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
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
          isA<WorkOrdersState>()
              .having((s) => s.status, 'status', StateStatus.initial)
              .having(
                (s) => s.activeFilter.statuses,
                'activeFilter.statuses',
                const WorkOrderFilter().statuses,
              ),
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<WorkOrdersState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockGetWorkOrders.call(any())).called(1);
          verify(
            () => mockGetChangeRequests.call(tUserProfile.companyId),
          ).called(1);
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
              .having((s) => s.status, 'status', StateStatus.initial)
              .having((s) => s.activeFilter, 'activeFilter', tFilter),
          isA<WorkOrdersState>()
              .having((s) => s.status, 'status', StateStatus.loading)
              .having((s) => s.activeFilter, 'activeFilter', tFilter),
          isA<WorkOrdersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
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
          historyByWorkOrder: {},
          activeFilter: tFilter,
        ),
        act: (cubit) => cubit.clearFilter(),
        expect: () => [
          isA<WorkOrdersState>()
              .having((s) => s.status, 'status', StateStatus.initial)
              .having(
                (s) => s.activeFilter,
                'activeFilter',
                const WorkOrderFilter(),
              ),
          isA<WorkOrdersState>()
              .having((s) => s.status, 'status', StateStatus.loading)
              .having(
                (s) => s.activeFilter,
                'activeFilter',
                const WorkOrderFilter(),
              ),
          isA<WorkOrdersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
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
          final tWorkOrders = EntityFactory.makeWorkOrderEntityList();
          when(
            () => mockGetWorkOrders.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tWorkOrders));
          return cubit;
        },
        seed: () => const WorkOrdersState(
          workOrders: [],
          changeRequests: [],
          historyByWorkOrder: {},
        ),
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
        seed: () => const WorkOrdersState(
          workOrders: [],
          changeRequests: [],
          historyByWorkOrder: {},
        ),
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

    group('loadWorkOrderHistory', () {
      final tWorkOrderId = faker.guid.guid();

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should update historyByWorkOrder map when history loads successfully',
        build: () {
          final tHistory = EntityFactory.makeWorkOrderHistoryEntityList();
          when(
            () => mockGetWorkOrderHistory.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tHistory));
          return cubit;
        },
        act: (cubit) => cubit.loadWorkOrderHistory(tWorkOrderId),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.historyByWorkOrder,
            'historyByWorkOrder',
            isNotEmpty,
          ),
        ],
        verify: (_) {
          verify(() => mockGetWorkOrderHistory.call(tWorkOrderId)).called(1);
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should not emit state when history load fails',
        build: () {
          when(() => mockGetWorkOrderHistory.call(any())).thenAnswer(
            (_) async =>
                FailureState<List<WorkOrderHistoryEntity>>(message: 'Error'),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadWorkOrderHistory(tWorkOrderId),
        expect: () => <WorkOrdersState>[],
        verify: (_) {
          verify(() => mockGetWorkOrderHistory.call(tWorkOrderId)).called(1);
        },
      );
    });

    group('saveWorkOrder', () {
      final tWorkOrder = EntityFactory.makeWorkOrderEntity();

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
              (s) => s.status,
              'status',
              StateStatus.saving,
            ),
            isA<WorkOrdersState>().having(
              (s) => s.status,
              'status',
              StateStatus.loaded,
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
              (s) => s.status,
              'status',
              StateStatus.saving,
            ),
            isA<WorkOrdersState>().having(
              (s) => s.status,
              'status',
              StateStatus.loaded,
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
            final tAttachment = EntityFactory.makeAttachmentEntity().copyWith(
              uploadStatus: status,
            );
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
          verify: (_) {
            verify(() => mockGetAttachments(any())).called(1);
            verify(() => mockUploadAttachment(any())).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should delete pending attachments when creation succeeds',
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
                status: StateStatus.loaded,
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
            final tAttachment = EntityFactory.makeAttachmentEntity().copyWith(
              uploadStatus: UploadStatus.pending,
            );
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
            final tAttachment = EntityFactory.makeAttachmentEntity().copyWith(
              uploadStatus: UploadStatus.pending,
            );
            when(
              mockAttachmentsCubit.refreshAttachments,
            ).thenAnswer((_) async {});
            when(() => mockAttachmentsCubit.state).thenReturn(
              AttachmentsState(
                status: StateStatus.loaded,
                attachments: [tAttachment],
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
                status: StateStatus.loaded,
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
          verify: (_) {
            verifyNever(() => mockDeleteAttachment.call(any()));
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should emit savingError and return false when attachment upload fails',
          build: () {
            final tAttachment = EntityFactory.makeAttachmentEntity().copyWith(
              uploadStatus: UploadStatus.pending,
            );
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
              (s) => s.status,
              'status',
              StateStatus.saving,
            ),
            isA<WorkOrdersState>()
                .having((s) => s.status, 'status', StateStatus.savingError)
                .having((s) => s.errorMessage, 'errorMessage', 'Upload Fail'),
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
              (s) => s.status,
              'status',
              StateStatus.saving,
            ),
            isA<WorkOrdersState>().having(
              (s) => s.status,
              'status',
              StateStatus.savingError,
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
                        actual.locationId == tWorkOrder.locationId;
                  }),
                ),
              ),
            ).called(1);
            verifyNever(() => mockGetWorkOrders.call(any()));
          },
        );
      });

      group('update', () {
        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should emit saving and load data when update succeeds',
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
              (s) => s.status,
              'status',
              StateStatus.saving,
            ),
            isA<WorkOrdersState>().having(
              (s) => s.status,
              'status',
              StateStatus.loaded,
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
              (s) => s.status,
              'status',
              StateStatus.saving,
            ),
            isA<WorkOrdersState>().having(
              (s) => s.status,
              'status',
              StateStatus.savingError,
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
            status: StateStatus.loaded,
            historyByWorkOrder: const {},
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

      group('changeWorkOrderStatus', () {
        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should emit saving and loaded when changeWorkOrderStatus succeeds',
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
          act: (cubit) async {
            final result = await cubit.changeWorkOrderStatus(
              workOrder: tWorkOrder,
              status: WorkOrderStatus.inProgress,
            );
            expect(result, isTrue);
          },
          expect: () => [
            isA<WorkOrdersState>().having(
              (s) => s.status,
              'status',
              StateStatus.saving,
            ),
            isA<WorkOrdersState>().having(
              (s) => s.status,
              'status',
              StateStatus.loaded,
            ),
          ],
          verify: (_) {
            verify(
              () => mockUpdateWorkOrder.call(
                any(
                  that: predicate<WorkOrderEntity>(
                    (actual) => actual.status == WorkOrderStatus.inProgress,
                  ),
                ),
              ),
            ).called(1);
            verify(() => mockGetWorkOrders.call(any())).called(1);
          },
        );

        blocTest<WorkOrdersCubit, WorkOrdersState>(
          'should emit saving and savingError when changeWorkOrderStatus fails',
          build: () {
            when(() => mockUpdateWorkOrder.call(any())).thenAnswer(
              (_) async => FailureState(message: faker.lorem.sentence()),
            );
            return cubit;
          },
          act: (cubit) async {
            final result = await cubit.changeWorkOrderStatus(
              workOrder: tWorkOrder,
              status: WorkOrderStatus.completed,
            );
            expect(result, isFalse);
          },
          expect: () => [
            isA<WorkOrdersState>().having(
              (s) => s.status,
              'status',
              StateStatus.saving,
            ),
            isA<WorkOrdersState>().having(
              (s) => s.status,
              'status',
              StateStatus.savingError,
            ),
          ],
          verify: (_) {
            verify(() => mockUpdateWorkOrder.call(any())).called(1);
            verifyNever(() => mockGetWorkOrders.call(any()));
          },
        );
      });
    });

    group('deleteWorkOrder', () {
      final tId = faker.guid.guid();

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit loading and load data when delete succeeds',
        build: () {
          when(
            () => mockDeleteWorkOrder.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetWorkOrders.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetChangeRequests.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async => expect(await cubit.deleteWorkOrder(tId), isTrue),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.deleting,
          ),
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteWorkOrder.call(tId)).called(1);
          verify(() => mockGetWorkOrders.call(any())).called(1);
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit error when delete fails',
        build: () {
          when(
            () => mockDeleteWorkOrder.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) async => expect(await cubit.deleteWorkOrder(tId), isFalse),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.deleting,
          ),
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.deletingError,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteWorkOrder.call(tId)).called(1);
          verifyNever(() => mockGetWorkOrders.call(any()));
        },
      );
    });

    group('createChangeRequest', () {
      final tRequest = EntityFactory.makeWorkOrderChangeRequestEntity();

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit loading and load data when createChangeRequest succeeds',
        build: () {
          when(
            () => mockCreateChangeRequest.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetWorkOrders.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetChangeRequests.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.createChangeRequest(tRequest),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateChangeRequest.call(tRequest)).called(1);
          verify(() => mockGetWorkOrders.call(any())).called(1);
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit error when createChangeRequest fails',
        build: () {
          when(
            () => mockCreateChangeRequest.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) => cubit.createChangeRequest(tRequest),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.savingError,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateChangeRequest.call(tRequest)).called(1);
          verifyNever(() => mockGetWorkOrders.call(any()));
        },
      );
    });

    group('reviewChangeRequest', () {
      final tParams = ReviewChangeRequestParams(
        id: faker.guid.guid(),
        status: ChangeRequestStatus.approved,
        reviewedById: faker.guid.guid(),
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit loading and load data when reviewChangeRequest succeeds',
        build: () {
          when(
            () => mockReviewChangeRequest.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetWorkOrders.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetChangeRequests.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.reviewChangeRequest(tParams),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockReviewChangeRequest.call(tParams)).called(1);
          verify(() => mockGetWorkOrders.call(any())).called(1);
        },
      );

      blocTest<WorkOrdersCubit, WorkOrdersState>(
        'should emit error when reviewChangeRequest fails',
        build: () {
          when(
            () => mockReviewChangeRequest.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) => cubit.reviewChangeRequest(tParams),
        expect: () => [
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<WorkOrdersState>().having(
            (s) => s.status,
            'status',
            StateStatus.savingError,
          ),
        ],
        verify: (_) {
          verify(() => mockReviewChangeRequest.call(tParams)).called(1);
          verifyNever(() => mockGetWorkOrders.call(any()));
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
    });
  });
}
