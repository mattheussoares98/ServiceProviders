import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/get_sectors_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
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

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockRequestPauseUseCase extends Mock implements RequestPauseUseCase {}

class MockCancelPauseUseCase extends Mock implements CancelPauseUseCase {}

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
  late MockCancelPauseUseCase mockCancelPause;
  late MockReviewPauseUseCase mockReviewPause;
  late MockGetPauseReasonsUseCase mockGetPauseReasons;
  late MockGetPauseRequestsUseCase mockGetPauseRequests;
  late MockRequestCompletionUseCase mockRequestCompletion;
  late MockReviewCompletionUseCase mockReviewCompletion;
  late MockGetSectorsUseCase mockGetSectors;
  late MockNavigationClient mockNavigationClient;

  late PauseWorkflowCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makePauseRequestEntity());
    registerFallbackValue(CancelPauseParams(id: '', resumedAt: DateTime.now()));
    registerFallbackValue(
      const ReviewPauseParams(
        id: '',
        status: PauseRequestStatus.approved,
        reviewedById: '',
      ),
    );
    registerFallbackValue(
      const ReviewCompletionParams(
        id: '',
        status: PauseRequestStatus.approved,
        reviewedById: '',
      ),
    );
  });

  setUp(() {
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockRequestPause = MockRequestPauseUseCase();
    mockCancelPause = MockCancelPauseUseCase();
    mockReviewPause = MockReviewPauseUseCase();
    mockGetPauseReasons = MockGetPauseReasonsUseCase();
    mockGetPauseRequests = MockGetPauseRequestsUseCase();
    mockRequestCompletion = MockRequestCompletionUseCase();
    mockReviewCompletion = MockReviewCompletionUseCase();
    mockGetSectors = MockGetSectorsUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = EntityFactory.makeUserProfileEntity();
    when(() => mockGetSessionUser.call()).thenReturn(tUserProfile);

    final useCases = PauseWorkflowCubitUseCases(
      getSessionUser: mockGetSessionUser,
      requestPause: mockRequestPause,
      cancelPause: mockCancelPause,
      reviewPause: mockReviewPause,
      getPauseReasons: mockGetPauseReasons,
      getPauseRequests: mockGetPauseRequests,
      requestCompletion: mockRequestCompletion,
      reviewCompletion: mockReviewCompletion,
      getSectors: mockGetSectors,
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
          return cubit;
        },
        act: (cubit) => cubit.loadSectors('company-id'),
        expect: () => [
          isA<PauseWorkflowState>().having(
            (s) => s.sectors,
            'sectors',
            hasLength(3),
          ),
        ],
        verify: (_) {
          verify(() => mockGetSectors.call('company-id')).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should not emit state when getSectors fails',
        build: () {
          when(
            () => mockGetSectors.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error'));
          return cubit;
        },
        act: (cubit) => cubit.loadSectors('company-id'),
        expect: () => <dynamic>[],
        verify: (_) {
          verify(() => mockGetSectors.call('company-id')).called(1);
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
          return cubit;
        },
        act: (cubit) => cubit.loadPauseReasons('company-id'),
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
          verify(() => mockGetPauseReasons.call('company-id')).called(1);
        },
      );

      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit loading and loadingError when reasons fetch fails',
        build: () {
          when(
            () => mockGetPauseReasons.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error'));
          return cubit;
        },
        act: (cubit) => cubit.loadPauseReasons('company-id'),
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


    group('cancelPause', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded when cancel succeeds',
        build: () {
          when(
            () => mockCancelPause.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetPauseRequests.call(any())).thenAnswer(
            (_) async =>
                SuccessState(data: EntityFactory.makePauseRequestEntityList()),
          );
          return cubit;
        },
        act: (cubit) => cubit.cancelPause(
          id: 'pause-id',
          resumedAt: DateTime.now(),
          workOrderId: 'wo-id',
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
      );
    });

    group('reviewPause', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded when review succeeds',
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
      );
    });

    group('requestCompletion', () {
      blocTest<PauseWorkflowCubit, PauseWorkflowState>(
        'should emit saving, loaded, loading, loaded when completion request succeeds',
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
        'should emit saving, loaded, loading, loaded when review completion succeeds',
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
      );
    });
  });
}
