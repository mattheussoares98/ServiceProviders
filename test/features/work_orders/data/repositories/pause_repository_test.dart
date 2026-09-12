import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pauses/pause_reason_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pauses/pause_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/repositories/pause_repository_impl.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/factories/system_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../testing/mocks/factories/work_order_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockPauseRemoteDataSource mockRemoteDataSource;
  late MockPauseLocalDataSource mockLocalDataSource;
  late MockSessionRepository mockSessionRepository;
  late MockSyncRepository mockSyncRepository;
  late PauseRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(SystemFactory.makeSyncQueueItemEntity());
    registerFallbackValue(
      PauseReasonModel.fromEntity(WorkOrderFactory.makePauseReasonEntity()),
    );
    registerFallbackValue(
      PauseRequestModel.fromEntity(WorkOrderFactory.makePauseRequestEntity()),
    );
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockPauseRemoteDataSource();
    mockLocalDataSource = MockPauseLocalDataSource();
    mockSessionRepository = MockSessionRepository();
    mockSyncRepository = MockSyncRepository();
    when(
      () => mockSessionRepository.getSelectedMode(),
    ).thenReturn(AppMode.internal.name);
    when(
      () => mockSessionRepository.getSelectedCompanyId(),
    ).thenReturn('company-1');
    when(
      () => mockSessionRepository.userData,
    ).thenReturn(UserFactory.makeUserDataEntity());
    when(
      () => mockSyncRepository.enqueue(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));

    repository = PauseRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      sessionRepository: mockSessionRepository,
      syncRepository: mockSyncRepository,
    );
  });

  final tReasonEntity = WorkOrderFactory.makePauseReasonEntity();
  final tReasonModel = PauseReasonModel.fromEntity(tReasonEntity);

  final tRequestEntity = WorkOrderFactory.makePauseRequestEntity();
  final tRequestModel = PauseRequestModel.fromEntity(tRequestEntity);

  group('watchPauseReasonsRealtime', () {
    test('mirrors insert/update events to local data source', () async {
      when(
        () => mockRemoteDataSource.watchPauseReasonsRealtime(
          companyId: any(named: 'companyId'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          RealtimeEvent<PauseReasonModel>(
            eventType: RealtimeEventType.insert,
            id: tReasonModel.id,
            companyId: tReasonModel.companyId,
            entity: tReasonModel,
          ),
        ),
      );
      when(
        () => mockLocalDataSource.savePauseReason(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final stream = repository.watchPauseReasonsRealtime(
        companyId: tReasonEntity.companyId,
      );
      await stream.first;

      verify(() => mockLocalDataSource.savePauseReason(tReasonModel)).called(1);
    });

    test('mirrors delete events to local data source', () async {
      when(
        () => mockRemoteDataSource.watchPauseReasonsRealtime(
          companyId: any(named: 'companyId'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          RealtimeEvent<PauseReasonModel>(
            eventType: RealtimeEventType.delete,
            id: tReasonModel.id,
            companyId: tReasonModel.companyId,
          ),
        ),
      );
      when(
        () => mockLocalDataSource.deletePauseReason(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final stream = repository.watchPauseReasonsRealtime(
        companyId: tReasonEntity.companyId,
      );
      await stream.first;

      verify(
        () => mockLocalDataSource.deletePauseReason(tReasonModel.id),
      ).called(1);
    });
  });

  group('getPauseReasons', () {
    test(
      'should fetch remote pause reasons and cache them locally when online',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getPauseReasons(any()),
        ).thenAnswer((_) async => SuccessState(data: [tReasonModel]));
        when(
          () => mockLocalDataSource.savePauseReason(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getPauseReasons(
          tReasonEntity.companyId,
        );

        expect(result, isA<SuccessState<List<PauseReasonEntity>>>());
        expect(
          (result as SuccessState<List<PauseReasonEntity>>).data!.first.id,
          tReasonEntity.id,
        );
        verify(
          () => mockRemoteDataSource.getPauseReasons(tReasonEntity.companyId),
        ).called(1);
        verify(
          () => mockLocalDataSource.savePauseReason(tReasonModel),
        ).called(1);
      },
    );
  });

  group('getPauseRequests', () {
    test(
      'should fetch remote requests and cache locally when online without status filter',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getPauseRequests(
            any(),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => SuccessState(data: [tRequestModel]));
        when(
          () => mockLocalDataSource.savePauseRequest(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getPauseRequests(
          tRequestEntity.workOrderId,
        );

        expect(result, isA<SuccessState<List<PauseRequestEntity>>>());
        expect(
          (result as SuccessState<List<PauseRequestEntity>>).data!.first.id,
          tRequestEntity.id,
        );
        verify(
          () =>
              mockRemoteDataSource.getPauseRequests(tRequestEntity.workOrderId),
        ).called(1);
        verify(
          () => mockLocalDataSource.savePauseRequest(tRequestModel),
        ).called(1);
      },
    );

    test(
      'should fetch remote requests with status filter when provided',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getPauseRequests(
            any(),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => SuccessState(data: [tRequestModel]));
        when(
          () => mockLocalDataSource.savePauseRequest(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getPauseRequests(
          tRequestEntity.workOrderId,
          status: PauseRequestStatus.pending,
        );

        expect(result, isA<SuccessState<List<PauseRequestEntity>>>());
        verify(
          () => mockRemoteDataSource.getPauseRequests(
            tRequestEntity.workOrderId,
            status: 'pending',
          ),
        ).called(1);
      },
    );
  });

  group('requestPause', () {
    test(
      'should request remote pause and save locally when successful',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.requestPause(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.savePauseRequest(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.requestPause(tRequestEntity);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verify(
          () => mockRemoteDataSource.requestPause(tRequestModel),
        ).called(1);
        verify(
          () => mockLocalDataSource.savePauseRequest(tRequestModel),
        ).called(1);
      },
    );
  });

  group('reviewPause', () {
    test(
      'should review remote pause and save locally when successful',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.reviewPause(
            id: any(named: 'id'),
            workOrderId: any(named: 'workOrderId'),
            status: any(named: 'status'),
            reviewObservation: any(named: 'reviewObservation'),
            reviewedById: any(named: 'reviewedById'),
            reasonId: any(named: 'reasonId'),
            responsibility: any(named: 'responsibility'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.reviewPause(
            id: any(named: 'id'),
            workOrderId: any(named: 'workOrderId'),
            status: any(named: 'status'),
            reviewObservation: any(named: 'reviewObservation'),
            reviewedById: any(named: 'reviewedById'),
            reasonId: any(named: 'reasonId'),
            responsibility: any(named: 'responsibility'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.reviewPause(
          id: tRequestEntity.id,
          workOrderId: tRequestEntity.workOrderId,
          status: PauseRequestStatus.approved,
          reviewObservation: 'observation',
          reviewedById: 'manager-id',
          reasonId: 'reason-id',
        );

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verify(
          () => mockRemoteDataSource.reviewPause(
            id: tRequestEntity.id,
            workOrderId: tRequestEntity.workOrderId,
            status: 'approved',
            reviewObservation: 'observation',
            reviewedById: 'manager-id',
            reasonId: 'reason-id',
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.reviewPause(
            id: tRequestEntity.id,
            workOrderId: tRequestEntity.workOrderId,
            status: 'approved',
            reviewObservation: 'observation',
            reviewedById: 'manager-id',
            reasonId: 'reason-id',
          ),
        ).called(1);
      },
    );

    test('should return FailureState.noInternet when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);

      final result = await repository.reviewPause(
        id: tRequestEntity.id,
        workOrderId: tRequestEntity.workOrderId,
        status: PauseRequestStatus.approved,
        reviewedById: 'manager-id',
      );

      expect(result, isA<FailureState<bool>>());
      verifyNever(
        () => mockRemoteDataSource.reviewPause(
          id: any(named: 'id'),
          workOrderId: any(named: 'workOrderId'),
          status: any(named: 'status'),
          reviewedById: any(named: 'reviewedById'),
        ),
      );
    });
  });

  group('reviewCompletion', () {
    test(
      'should review remote completion and save locally when successful',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.reviewCompletion(
            id: any(named: 'id'),
            workOrderId: any(named: 'workOrderId'),
            status: any(named: 'status'),
            reviewedById: any(named: 'reviewedById'),
            reviewObservation: any(named: 'reviewObservation'),
            responsibility: any(named: 'responsibility'),
            completionReason: any(named: 'completionReason'),
            completionSectorId: any(named: 'completionSectorId'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.reviewCompletion(
            id: any(named: 'id'),
            workOrderId: any(named: 'workOrderId'),
            status: any(named: 'status'),
            reviewedById: any(named: 'reviewedById'),
            reviewObservation: any(named: 'reviewObservation'),
            responsibility: any(named: 'responsibility'),
            completionReason: any(named: 'completionReason'),
            completionSectorId: any(named: 'completionSectorId'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.reviewCompletion(
          id: tRequestEntity.id,
          workOrderId: tRequestEntity.workOrderId,
          status: PauseRequestStatus.approved,
          reviewedById: 'manager-id',
          reviewObservation: 'observation',
          completionReason: 'done',
        );

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verify(
          () => mockRemoteDataSource.reviewCompletion(
            id: tRequestEntity.id,
            workOrderId: tRequestEntity.workOrderId,
            status: 'approved',
            reviewedById: 'manager-id',
            reviewObservation: 'observation',
            completionReason: 'done',
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.reviewCompletion(
            id: tRequestEntity.id,
            workOrderId: tRequestEntity.workOrderId,
            status: 'approved',
            reviewedById: 'manager-id',
            reviewObservation: 'observation',
            completionReason: 'done',
          ),
        ).called(1);
      },
    );

    test('should return FailureState.noInternet when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);

      final result = await repository.reviewCompletion(
        id: tRequestEntity.id,
        workOrderId: tRequestEntity.workOrderId,
        status: PauseRequestStatus.approved,
        reviewedById: 'manager-id',
      );

      expect(result, isA<FailureState<bool>>());
      verifyNever(
        () => mockRemoteDataSource.reviewCompletion(
          id: any(named: 'id'),
          workOrderId: any(named: 'workOrderId'),
          status: any(named: 'status'),
          reviewedById: any(named: 'reviewedById'),
        ),
      );
    });
  });

  group('resumeWork', () {
    test(
      'should cancel remote pause and save locally when successful',
      () async {
        final now = DateTime.now();
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.resumeWork(
            id: any(named: 'id'),
            workOrderId: any(named: 'workOrderId'),
            resumedAt: any(named: 'resumedAt'),
            resumedById: any(named: 'resumedById'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.resumeWork(
            id: any(named: 'id'),
            workOrderId: any(named: 'workOrderId'),
            resumedAt: any(named: 'resumedAt'),
            resumedById: any(named: 'resumedById'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.resumeWork(
          id: tRequestEntity.id,
          workOrderId: tRequestEntity.workOrderId,
          resumedAt: now,
          resumedById: tRequestEntity.resumedById!,
        );

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verify(
          () => mockRemoteDataSource.resumeWork(
            id: tRequestEntity.id,
            workOrderId: tRequestEntity.workOrderId,
            resumedAt: now,
            resumedById: tRequestEntity.resumedById!,
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.resumeWork(
            id: tRequestEntity.id,
            workOrderId: tRequestEntity.workOrderId,
            resumedAt: now,
            resumedById: tRequestEntity.resumedById!,
          ),
        ).called(1);
      },
    );

    test(
      'should cancel local pause and enqueue to sync queue when offline',
      () async {
        final now = DateTime.now();
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.resumeWork(
            id: any(named: 'id'),
            workOrderId: any(named: 'workOrderId'),
            resumedAt: any(named: 'resumedAt'),
            resumedById: any(named: 'resumedById'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.resumeWork(
          id: tRequestEntity.id,
          workOrderId: tRequestEntity.workOrderId,
          resumedAt: now,
          resumedById: tRequestEntity.resumedById!,
        );

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verifyNever(
          () => mockRemoteDataSource.resumeWork(
            id: any(named: 'id'),
            workOrderId: any(named: 'workOrderId'),
            resumedAt: any(named: 'resumedAt'),
            resumedById: any(named: 'resumedById'),
          ),
        );
        verify(
          () => mockLocalDataSource.resumeWork(
            id: tRequestEntity.id,
            workOrderId: tRequestEntity.workOrderId,
            resumedAt: now,
            resumedById: tRequestEntity.resumedById!,
          ),
        ).called(1);
        verify(() => mockSyncRepository.enqueue(any())).called(1);
      },
    );
  });

  group('PauseRepository in provider mode', () {
    setUp(() {
      when(
        () => mockSessionRepository.getSelectedMode(),
      ).thenReturn(AppMode.provider.name);
    });

    test('requestPause sends remotely without caching locally', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.requestPause(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.requestPause(tRequestEntity);

      expect(result, const SuccessState(data: true));
      verify(() => mockRemoteDataSource.requestPause(any())).called(1);
      verifyNever(() => mockLocalDataSource.savePauseRequest(any()));
    });

    test('requestPause fails without local fallback when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);

      final result = await repository.requestPause(tRequestEntity);

      expect(result, isA<FailureState<bool>>());
      verifyNever(() => mockLocalDataSource.savePauseRequest(any()));
    });

    test('getPauseRequests fetches remotely without caching locally', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.getPauseRequests(
          any(),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => SuccessState(data: [tRequestModel]));

      final result = await repository.getPauseRequests(
        tRequestEntity.workOrderId,
      );

      expect(result, isA<SuccessState<List<PauseRequestEntity>>>());
      verifyNever(() => mockLocalDataSource.savePauseRequest(any()));
    });

    test(
      'getPauseRequests fails without local fallback when offline',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);

        final result = await repository.getPauseRequests(
          tRequestEntity.workOrderId,
        );

        expect(result, isA<FailureState<List<PauseRequestEntity>>>());
        verifyNever(
          () => mockLocalDataSource.getPauseRequests(
            any(),
            status: any(named: 'status'),
          ),
        );
      },
    );
  });
}
