import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/has_permission_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_reasons_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/request_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/request_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../../testing/mocks/factories/work_order_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

class MockWorkOrdersCubit extends MockCubit<WorkOrdersState>
    implements WorkOrdersCubit {}

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockGetSelectedModeUseCase extends Mock
    implements GetSelectedModeUseCase {}

class MockRequestPauseUseCase extends Mock implements RequestPauseUseCase {}

class MockReviewPauseUseCase extends Mock implements ReviewPauseUseCase {}

class MockGetPauseReasonsUseCase extends Mock
    implements GetPauseReasonsUseCase {}

class MockGetPauseRequestsUseCase extends Mock
    implements GetPauseRequestsUseCase {}

class MockRequestCompletionUseCase extends Mock
    implements RequestCompletionUseCase {}

class MockReviewCompletionUseCase extends Mock
    implements ReviewCompletionUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetSelectedModeUseCase mockGetSelectedMode;
  late MockHasPermissionUseCase mockHasPermission;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockRequestPauseUseCase mockRequestPause;
  late MockReviewPauseUseCase mockReviewPause;
  late MockGetPauseReasonsUseCase mockGetPauseReasons;
  late MockGetPauseRequestsUseCase mockGetPauseRequests;
  late MockRequestCompletionUseCase mockRequestCompletion;
  late MockReviewCompletionUseCase mockReviewCompletion;
  late MockNavigationClient mockNavigationClient;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockWorkOrdersCubit mockWorkOrdersCubit;

  late PauseWorkflowCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(WorkOrderStatus.open);
    registerFallbackValue(WorkOrderFactory.makePauseRequestEntity());
    registerFallbackValue(
      const HasPermissionParams(
        permission: ActionPermission.workOrderSubAction(
          WorkOrderSubAction.managePendingRequests,
        ),
      ),
    );
    registerFallbackValue(
      CancelPauseParams(
        id: '',
        workOrderId: '',
        resumedAt: DateTime.now(),
        resumedById: '',
      ),
    );
    registerFallbackValue(
      const ReviewPauseParams(
        id: '',
        workOrderId: '',
        status: PauseRequestStatus.approved,
        reviewedById: '',
      ),
    );
    registerFallbackValue(
      const GetPauseRequestsParams(workOrderId: 'fallback-wo-id'),
    );
    registerFallbackValue(
      const ReviewCompletionParams(
        id: '',
        workOrderId: '',
        status: PauseRequestStatus.approved,
        reviewedById: '',
      ),
    );
  });

  setUp(() {
    mockGetSelectedMode = MockGetSelectedModeUseCase();
    mockHasPermission = MockHasPermissionUseCase();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockRequestPause = MockRequestPauseUseCase();
    mockReviewPause = MockReviewPauseUseCase();
    mockGetPauseReasons = MockGetPauseReasonsUseCase();
    mockGetPauseRequests = MockGetPauseRequestsUseCase();
    mockRequestCompletion = MockRequestCompletionUseCase();
    mockReviewCompletion = MockReviewCompletionUseCase();
    mockNavigationClient = MockNavigationClient();
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockWorkOrdersCubit = MockWorkOrdersCubit();

    when(
      () => mockWorkOrdersCubit.updateLocalWorkOrderStatus(
        any(),
        any(),
        syncRemotely: any(named: 'syncRemotely'),
      ),
    ).thenAnswer((_) {});
    when(
      () => mockWorkOrdersCubit.loadWorkOrdersAndChangeRequests(
        showLoading: any(named: 'showLoading'),
      ),
    ).thenAnswer((_) async => true);

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = UserFactory.makeUserProfileEntity();
    when(() => mockGetSessionUser.call()).thenReturn(tUserProfile);
    when(() => mockGetSelectedMode.call()).thenReturn('internal');
    when(() => mockGetActiveCompanyId.call()).thenReturn('company-id');
    when(
      () => mockHasPermission.call(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));

    final useCases = PauseWorkflowCubitUseCases(
      requestPause: mockRequestPause,
      reviewPause: mockReviewPause,
      getPauseReasons: mockGetPauseReasons,
      getPauseRequests: mockGetPauseRequests,
      requestCompletion: mockRequestCompletion,
      reviewCompletion: mockReviewCompletion,
      getActiveCompanyId: mockGetActiveCompanyId,
      hasPermission: mockHasPermission,
      getSessionUser: mockGetSessionUser,
    );

    cubit = PauseWorkflowCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('PauseWorkflowCubit Tests', () {
    group('loadPauseReasons', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit loading and loaded when reasons fetch succeeds',
        build: () {
          final tReasons = WorkOrderFactory.makePauseReasonEntityList();
          when(
            () => mockGetPauseReasons.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tReasons));
          when(
            () => mockGetActiveCompanyId.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.loadPauseReasons(),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.pauseReasons, 'pauseReasons', isNotEmpty),
        ],
        verify: (_) {
          verify(
            () => mockGetPauseReasons.call(tUserProfile.companyId),
          ).called(1);
          verify(() => mockGetActiveCompanyId.call()).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit loading and loadingError when reasons fetch fails',
        build: () {
          when(
            () => mockGetPauseReasons.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error'));
          when(
            () => mockGetActiveCompanyId.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.loadPauseReasons(),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.error('Error'),
          ),
        ],
      );
    });

    group('loadPauseRequests', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit loading and loaded when requests fetch succeeds without status',
        build: () {
          final tRequests = WorkOrderFactory.makePauseRequestEntityList();
          when(
            () => mockGetPauseRequests.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tRequests));
          return cubit;
        },
        act: (cubit) => cubit.loadPauseRequests('wo-id'),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.pauseRequests, 'pauseRequests', isNotEmpty),
        ],
        verify: (_) {
          verify(
            () => mockGetPauseRequests.call(
              const GetPauseRequestsParams(workOrderId: 'wo-id'),
            ),
          ).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should pass status filter when provided',
        build: () {
          final tRequests = WorkOrderFactory.makePauseRequestEntityList();
          when(
            () => mockGetPauseRequests.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tRequests));
          return cubit;
        },
        act: (cubit) => cubit.loadPauseRequests(
          'wo-id',
          status: PauseRequestStatus.pending,
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.pauseRequests, 'pauseRequests', isNotEmpty),
        ],
        verify: (_) {
          verify(
            () => mockGetPauseRequests.call(
              const GetPauseRequestsParams(
                workOrderId: 'wo-id',
                status: PauseRequestStatus.pending,
              ),
            ),
          ).called(1);
        },
      );
    });

    group('requestPause', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit savingError when both reasonId and customReason are missing',
        build: () => cubit,
        act: (cubit) => cubit.requestPause(
          workOrderId: 'wo-id',
          workOrdersCubit: mockWorkOrdersCubit,
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.requestPause],
            'sections[requestPause]',
            const SectionState.error(),
          ),
        ],
        verify: (_) {
          verifyNever(() => mockRequestPause.call(any()));
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded when request succeeds',
        build: () {
          when(
            () => mockRequestPause.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.requestPause(
          workOrderId: 'wo-id',
          customReason: 'Falta de peças',
          workOrdersCubit: mockWorkOrdersCubit,
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.requestPause],
            'sections[requestPause]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.requestPause],
            'sections[requestPause]',
            const SectionState.success(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.pauseRequests, 'pauseRequests', isNotEmpty),
        ],
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should update workOrdersCubit when requestPause succeeds',
        build: () {
          when(
            () => mockRequestPause.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          when(() => mockGetSelectedMode.call()).thenReturn('internal');
          when(
            () => mockHasPermission.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          return cubit;
        },
        act: (cubit) {
          return cubit.requestPause(
            workOrderId: 'wo-id',
            customReason: 'Falta de peças',
            workOrdersCubit: mockWorkOrdersCubit,
          );
        },
        verify: (_) {
          verify(() => mockRequestPause.call(any())).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving and savingError when request fails',
        build: () {
          when(
            () => mockRequestPause.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Request failed'));
          return cubit;
        },
        act: (cubit) => cubit.requestPause(
          workOrderId: 'wo-id',
          customReason: 'Falta de peças',
          workOrdersCubit: mockWorkOrdersCubit,
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.requestPause],
            'sections[requestPause]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.requestPause],
            'sections[requestPause]',
            const SectionState.error(),
          ),
        ],
      );

      test(
        'creates approved pause request when user is internal and has permission',
        () async {
          when(() => mockGetSelectedMode.call()).thenReturn('internal');
          when(
            () => mockHasPermission.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockRequestPause.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetPauseRequests.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));

          final result = await cubit.requestPause(
            workOrderId: 'wo-id',
            customReason: 'Falta de peças',
            workOrdersCubit: mockWorkOrdersCubit,
          );

          expect(result, isTrue);
          final captured =
              verify(() => mockRequestPause.call(captureAny())).captured.first
                  as PauseRequestEntity;
          expect(captured.status, PauseRequestStatus.approved);
          expect(captured.requestedById, tUserProfile.id);
          expect(captured.reviewedById, tUserProfile.id);
        },
      );

      test(
        'creates pending pause request when user is in provider mode',
        () async {
          when(() => mockGetSelectedMode.call()).thenReturn('provider');
          // In provider mode HasPermissionUseCase denies managePendingRequests.
          when(
            () => mockHasPermission.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: false));
          when(
            () => mockRequestPause.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetPauseRequests.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));

          final result = await cubit.requestPause(
            workOrderId: 'wo-id',
            customReason: 'Falta de peças',
            workOrdersCubit: mockWorkOrdersCubit,
          );

          expect(result, isTrue);
          final captured =
              verify(() => mockRequestPause.call(captureAny())).captured.first
                  as PauseRequestEntity;
          expect(captured.status, PauseRequestStatus.pending);
          expect(captured.requestedById, tUserProfile.id);
          expect(captured.reviewedById, isNull);
        },
      );

      test(
        'creates pending pause request when user lacks permission',
        () async {
          when(() => mockGetSelectedMode.call()).thenReturn('internal');
          when(
            () => mockHasPermission.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: false));
          when(
            () => mockRequestPause.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetPauseRequests.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));

          final result = await cubit.requestPause(
            workOrderId: 'wo-id',
            customReason: 'Falta de peças',
            workOrdersCubit: mockWorkOrdersCubit,
          );

          expect(result, isTrue);
          final captured =
              verify(() => mockRequestPause.call(captureAny())).captured.first
                  as PauseRequestEntity;
          expect(captured.status, PauseRequestStatus.pending);
          expect(captured.requestedById, tUserProfile.id);
          expect(captured.reviewedById, isNull);
        },
      );
    });

    group('reviewPause', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded when review approval succeeds',
        build: () {
          when(
            () => mockReviewPause.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.reviewPause(
          id: 'pause-id',
          status: PauseRequestStatus.approved,
          reviewedById: 'manager-id',
          workOrderId: 'wo-id',
          responsibility: PauseResponsibility.provider,
          reviewObservation: 'Approved pause',
          reasonId: 'reason-id',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewPause],
            'sections[reviewPause]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewPause],
            'sections[reviewPause]',
            const SectionState.success(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.success(),
          ),
        ],
        verify: (_) {
          verify(
            () => mockReviewPause.call(
              any(
                that: isA<ReviewPauseParams>()
                    .having((p) => p.id, 'id', 'pause-id')
                    .having(
                      (p) => p.status,
                      'status',
                      PauseRequestStatus.approved,
                    )
                    .having(
                      (p) => p.responsibility,
                      'responsibility',
                      PauseResponsibility.provider,
                    ),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded when review rejection succeeds',
        build: () {
          when(
            () => mockReviewPause.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.reviewPause(
          id: 'pause-id',
          status: PauseRequestStatus.rejected,
          reviewedById: 'manager-id',
          workOrderId: 'wo-id',
          responsibility: PauseResponsibility.contractor,
          reviewObservation: 'Rejected pause',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewPause],
            'sections[reviewPause]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewPause],
            'sections[reviewPause]',
            const SectionState.success(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.success(),
          ),
        ],
        verify: (_) {
          verify(
            () => mockReviewPause.call(
              any(
                that: isA<ReviewPauseParams>()
                    .having((p) => p.id, 'id', 'pause-id')
                    .having(
                      (p) => p.status,
                      'status',
                      PauseRequestStatus.rejected,
                    )
                    .having(
                      (p) => p.responsibility,
                      'responsibility',
                      PauseResponsibility.contractor,
                    ),
              ),
            ),
          ).called(1);
        },
      );
    });

    group('requestCompletion', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded when completion request succeeds with null responsibility by default',
        build: () {
          when(
            () => mockRequestCompletion.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.requestCompletion(
          workOrderId: 'wo-id',
          customReason: 'Concluído com sucesso',
          workOrdersCubit: mockWorkOrdersCubit,
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.requestCompletion],
            'sections[requestCompletion]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.requestCompletion],
            'sections[requestCompletion]',
            const SectionState.success(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.pauseRequests, 'pauseRequests', isNotEmpty),
        ],
        verify: (_) {
          verify(
            () => mockRequestCompletion.call(
              any(
                that: isA<PauseRequestEntity>()
                    .having((r) => r.companyId, 'companyId', 'company-id')
                    .having((r) => r.responsibility, 'responsibility', isNull),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should update workOrdersCubit when requestCompletion succeeds',
        build: () {
          when(
            () => mockRequestCompletion.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          return cubit;
        },
        act: (cubit) {
          return cubit.requestCompletion(
            workOrderId: 'wo-id',
            customReason: 'Concluído com sucesso',
            workOrdersCubit: mockWorkOrdersCubit,
          );
        },
        verify: (_) {
          verify(() => mockRequestCompletion.call(any())).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving and savingError when completion request fails',
        build: () {
          when(
            () => mockRequestCompletion.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Completion failed'));
          return cubit;
        },
        act: (cubit) => cubit.requestCompletion(
          workOrderId: 'wo-id',
          customReason: 'Concluído com sucesso',
          workOrdersCubit: mockWorkOrdersCubit,
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.requestCompletion],
            'sections[requestCompletion]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.requestCompletion],
            'sections[requestCompletion]',
            const SectionState.error(),
          ),
        ],
      );
    });

    group('reviewCompletion', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded and call reviewCompletion use case when there are pending pause requests',
        seed: () => const PauseWorkflowState.initial().copyWith(
          pauseRequests: [
            WorkOrderFactory.makePauseRequestEntity().copyWith(
              status: PauseRequestStatus.pending,
              eventType: PauseEventType.pause,
            ),
          ],
        ),
        build: () {
          when(
            () => mockReviewCompletion.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.reviewCompletion(
          id: 'request-id',
          status: PauseRequestStatus.approved,
          reviewedById: 'manager-id',
          workOrderId: 'wo-id',
          reviewObservation: 'Approved completion',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewCompletion],
            'sections[reviewCompletion]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewCompletion],
            'sections[reviewCompletion]',
            const SectionState.success(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.success(),
          ),
        ],
        verify: (_) {
          verify(() => mockReviewCompletion.call(any())).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded when review completion is approved',
        build: () {
          when(
            () => mockReviewCompletion.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.reviewCompletion(
          id: 'request-id',
          status: PauseRequestStatus.approved,
          reviewedById: 'manager-id',
          workOrderId: 'wo-id',
          reviewObservation: 'Approved completion',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewCompletion],
            'sections[reviewCompletion]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewCompletion],
            'sections[reviewCompletion]',
            const SectionState.success(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.success(),
          ),
        ],
        verify: (_) {
          verify(
            () => mockReviewCompletion.call(
              any(
                that: isA<ReviewCompletionParams>()
                    .having((p) => p.id, 'id', 'request-id')
                    .having(
                      (p) => p.status,
                      'status',
                      PauseRequestStatus.approved,
                    )
                    .having((p) => p.responsibility, 'responsibility', isNull),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded when review completion is rejected',
        build: () {
          when(
            () => mockReviewCompletion.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.reviewCompletion(
          id: 'request-id',
          status: PauseRequestStatus.rejected,
          reviewedById: 'manager-id',
          workOrderId: 'wo-id',
          reviewObservation: 'Rejected completion',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewCompletion],
            'sections[reviewCompletion]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewCompletion],
            'sections[reviewCompletion]',
            const SectionState.success(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.success(),
          ),
        ],
        verify: (_) {
          verify(
            () => mockReviewCompletion.call(
              any(
                that: isA<ReviewCompletionParams>()
                    .having((p) => p.id, 'id', 'request-id')
                    .having(
                      (p) => p.status,
                      'status',
                      PauseRequestStatus.rejected,
                    )
                    .having((p) => p.responsibility, 'responsibility', isNull),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should allow cancelling completion even when there are pending pause requests',
        seed: () => const PauseWorkflowState.initial().copyWith(
          pauseRequests: [
            WorkOrderFactory.makePauseRequestEntity().copyWith(
              status: PauseRequestStatus.pending,
              eventType: PauseEventType.pause,
            ),
          ],
        ),
        build: () {
          when(
            () => mockReviewCompletion.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.reviewCompletion(
          id: 'request-id',
          status: PauseRequestStatus.cancelled,
          reviewedById: 'manager-id',
          workOrderId: 'wo-id',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewCompletion],
            'sections[reviewCompletion]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewCompletion],
            'sections[reviewCompletion]',
            const SectionState.success(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.success(),
          ),
        ],
        verify: (_) {
          verify(
            () => mockReviewCompletion.call(
              any(
                that: isA<ReviewCompletionParams>()
                    .having((p) => p.id, 'id', 'request-id')
                    .having(
                      (p) => p.status,
                      'status',
                      PauseRequestStatus.cancelled,
                    ),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should allow rejecting completion even when there are pending pause requests',
        seed: () => const PauseWorkflowState.initial().copyWith(
          pauseRequests: [
            WorkOrderFactory.makePauseRequestEntity().copyWith(
              status: PauseRequestStatus.pending,
              eventType: PauseEventType.pause,
            ),
          ],
        ),
        build: () {
          when(
            () => mockReviewCompletion.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: WorkOrderFactory.makePauseRequestEntityList(),
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.reviewCompletion(
          id: 'request-id',
          status: PauseRequestStatus.rejected,
          reviewedById: 'manager-id',
          workOrderId: 'wo-id',
          reviewObservation: 'Rejected note',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewCompletion],
            'sections[reviewCompletion]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[PauseWorkflowSections.reviewCompletion],
            'sections[reviewCompletion]',
            const SectionState.success(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.success(),
          ),
        ],
        verify: (_) {
          verify(
            () => mockReviewCompletion.call(
              any(
                that: isA<ReviewCompletionParams>()
                    .having((p) => p.id, 'id', 'request-id')
                    .having(
                      (p) => p.status,
                      'status',
                      PauseRequestStatus.rejected,
                    ),
              ),
            ),
          ).called(1);
        },
      );
    });
  });
}
