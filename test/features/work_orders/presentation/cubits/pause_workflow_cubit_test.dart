import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/get_sectors_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_reasons_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/request_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/request_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/use_case_mocks.dart';

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

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

class MockGetSectorsUseCase extends Mock implements GetSectorsUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockRequestPauseUseCase mockRequestPause;
  late MockReviewPauseUseCase mockReviewPause;
  late MockGetPauseReasonsUseCase mockGetPauseReasons;
  late MockGetPauseRequestsUseCase mockGetPauseRequests;
  late MockRequestCompletionUseCase mockRequestCompletion;
  late MockReviewCompletionUseCase mockReviewCompletion;
  late MockGetSectorsUseCase mockGetSectors;
  late MockNavigationClient mockNavigationClient;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;

  late PauseWorkflowCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makePauseRequestEntity());
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
      const ReviewCompletionParams(
        id: '',
        workOrderId: '',
        status: PauseRequestStatus.approved,
        reviewedById: '',
      ),
    );
  });

  setUp(() {
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockRequestPause = MockRequestPauseUseCase();
    mockReviewPause = MockReviewPauseUseCase();
    mockGetPauseReasons = MockGetPauseReasonsUseCase();
    mockGetPauseRequests = MockGetPauseRequestsUseCase();
    mockRequestCompletion = MockRequestCompletionUseCase();
    mockReviewCompletion = MockReviewCompletionUseCase();
    mockGetSectors = MockGetSectorsUseCase();
    mockNavigationClient = MockNavigationClient();
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = EntityFactory.makeUserProfileEntity();
    when(() => mockGetSessionUser.call()).thenReturn(tUserProfile);

    final useCases = PauseWorkflowCubitUseCases(
      requestPause: mockRequestPause,
      reviewPause: mockReviewPause,
      getPauseReasons: mockGetPauseReasons,
      getPauseRequests: mockGetPauseRequests,
      requestCompletion: mockRequestCompletion,
      reviewCompletion: mockReviewCompletion,
      getSectors: mockGetSectors,
      getActiveCompanyId: mockGetActiveCompanyId,
    );

    cubit = PauseWorkflowCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('PauseWorkflowCubit Tests', () {
    group('loadSectors', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit updated sectors when getSectors succeeds',
        build: () {
          final tSectors = EntityFactory.makeSectorEntityList();
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tSectors));
          when(
            () => mockGetActiveCompanyId.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.loadSectors(),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sectors,
            'sectors',
            hasLength(3),
          ),
        ],
        verify: (_) {
          verify(() => mockGetActiveCompanyId.call()).called(1);
          verify(() => mockGetSectors.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should not emit state when getSectors fails',
        build: () {
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error'));
          when(
            () => mockGetActiveCompanyId.call(),
          ).thenReturn(tUserProfile.companyId);
          return cubit;
        },
        act: (cubit) => cubit.loadSectors(),
        expect: () => <dynamic>[],
        verify: (_) {
          verify(() => mockGetSectors.call(tUserProfile.companyId)).called(1);
          verify(() => mockGetActiveCompanyId.call()).called(1);
        },
      );
    });

    group('loadPauseReasons', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit loading and loaded when reasons fetch succeeds',
        build: () {
          final tReasons = EntityFactory.makePauseReasonEntityList();
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
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<PauseWorkflowState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.pauseReasons, 'pauseReasons', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
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
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<PauseWorkflowState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Error'),
        ],
      );
    });

    group('loadPauseRequests', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit loading and loaded when requests fetch succeeds',
        build: () {
          final tRequests = EntityFactory.makePauseRequestEntityList();
          when(
            () => mockGetPauseRequests.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tRequests));
          return cubit;
        },
        act: (cubit) => cubit.loadPauseRequests('wo-id'),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<PauseWorkflowState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.pauseRequests, 'pauseRequests', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
        verify: (_) {
          verify(() => mockGetPauseRequests.call('wo-id')).called(1);
        },
      );
    });

    group('requestPause', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit savingError when both reasonId and customReason are missing',
        build: () => cubit,
        act: (cubit) => cubit.requestPause(
          companyId: 'company-id',
          workOrderId: 'wo-id',
          requestedById: 'user-id',
        ),
        expect: () => [
          isA<PauseWorkflowState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Informe o motivo da pausa',
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
            (_) async =>
                SuccessState(data: EntityFactory.makePauseRequestEntityList()),
          );
          return cubit;
        },
        act: (cubit) => cubit.requestPause(
          companyId: 'company-id',
          workOrderId: 'wo-id',
          requestedById: 'user-id',
          customReason: 'Falta de peças',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<PauseWorkflowState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.pauseRequests, 'pauseRequests', isNotEmpty),
        ],
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
          companyId: 'company-id',
          workOrderId: 'wo-id',
          requestedById: 'user-id',
          customReason: 'Falta de peças',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<PauseWorkflowState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Request failed'),
        ],
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
            (_) async =>
                SuccessState(data: EntityFactory.makePauseRequestEntityList()),
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
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
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
            (_) async =>
                SuccessState(data: EntityFactory.makePauseRequestEntityList()),
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
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
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
            (_) async =>
                SuccessState(data: EntityFactory.makePauseRequestEntityList()),
          );
          return cubit;
        },
        act: (cubit) => cubit.requestCompletion(
          companyId: 'company-id',
          workOrderId: 'wo-id',
          requestedById: 'user-id',
          customReason: 'Concluído com sucesso',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<PauseWorkflowState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
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
        'should emit saving and savingError when completion request fails',
        build: () {
          when(
            () => mockRequestCompletion.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Completion failed'));
          return cubit;
        },
        act: (cubit) => cubit.requestCompletion(
          companyId: 'company-id',
          workOrderId: 'wo-id',
          requestedById: 'user-id',
          customReason: 'Concluído com sucesso',
        ),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<PauseWorkflowState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Completion failed',
              ),
        ],
      );
    });

    group('reviewCompletion', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit savingError and not call reviewCompletion use case when there are pending pause requests',
        seed: () => const PauseWorkflowState.initial().copyWith(
          pauseRequests: [
            EntityFactory.makePauseRequestEntity().copyWith(
              status: PauseRequestStatus.pending,
              eventType: PauseEventType.pause,
            ),
          ],
        ),
        build: () => cubit,
        act: (cubit) => cubit.reviewCompletion(
          id: 'request-id',
          status: PauseRequestStatus.approved,
          reviewedById: 'manager-id',
          workOrderId: 'wo-id',
          reviewObservation: 'Approved completion',
        ),
        expect: () => [
          isA<PauseWorkflowState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Existem solicitações de pausa pendentes. Avalie as pausas primeiro.',
              ),
        ],
        verify: (_) {
          verifyNever(() => mockReviewCompletion.call(any()));
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded when review completion is approved',
        build: () {
          when(
            () => mockReviewCompletion.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async =>
                SuccessState(data: EntityFactory.makePauseRequestEntityList()),
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
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
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
                    .having(
                      (p) => p.responsibility,
                      'responsibility',
                      isNull,
                    ),
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
            (_) async =>
                SuccessState(data: EntityFactory.makePauseRequestEntityList()),
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
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<PauseWorkflowState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
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
                    .having(
                      (p) => p.responsibility,
                      'responsibility',
                      isNull,
                    ),
              ),
            ),
          ).called(1);
        },
      );
    });
  });
}
