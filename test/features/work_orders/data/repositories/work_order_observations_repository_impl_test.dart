import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/repositories/work_order_observations_repository_impl.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/factories/system_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../testing/mocks/factories/work_order_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockWorkOrderObservationsRemoteDataSource mockRemoteDataSource;
  late MockWorkOrderObservationsLocalDataSource mockLocalDataSource;
  late MockSessionRepository mockSessionRepository;
  late MockSyncRepository mockSyncRepository;
  late WorkOrderObservationsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(SystemFactory.makeSyncQueueItemEntity());
    registerFallbackValue(WorkOrderFactory.makeWorkOrderObservationEntity());
    registerFallbackValue(
      WorkOrderObservationModel.fromEntity(
        WorkOrderFactory.makeWorkOrderObservationEntity(),
      ),
    );
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockWorkOrderObservationsRemoteDataSource();
    mockLocalDataSource = MockWorkOrderObservationsLocalDataSource();
    mockSessionRepository = MockSessionRepository();
    mockSyncRepository = MockSyncRepository();
    when(
      () => mockSessionRepository.getSelectedMode(),
    ).thenReturn(AppMode.internal.name);
    when(
      () => mockSessionRepository.userData,
    ).thenReturn(UserFactory.makeUserDataEntity());
    when(
      () => mockSessionRepository.getSelectedCompanyId(),
    ).thenReturn('company-1');
    when(
      () => mockSyncRepository.enqueue(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));

    repository = WorkOrderObservationsRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      sessionRepository: mockSessionRepository,
      syncRepository: mockSyncRepository,
    );
  });

  final tObservationEntity = WorkOrderFactory.makeWorkOrderObservationEntity();
  final tObservationModel = WorkOrderObservationModel.fromEntity(
    tObservationEntity,
  );

  group('getObservations', () {
    test(
      'should fetch remote observations and cache them locally when online',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getObservationsByWorkOrderIds(any()),
        ).thenAnswer((_) async => SuccessState(data: [tObservationModel]));
        when(
          () => mockLocalDataSource.saveObservations(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getObservations(
          tObservationEntity.workOrderId,
        );

        expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
        expect(
          (result as SuccessState<List<WorkOrderObservationEntity>>)
              .data!
              .first
              .id,
          tObservationEntity.id,
        );
        verify(
          () => mockRemoteDataSource.getObservationsByWorkOrderIds([
            tObservationEntity.workOrderId,
          ]),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveObservations([tObservationModel]),
        ).called(1);
      },
    );

    test('should fetch local observations when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getObservationsByWorkOrderIds(any()),
      ).thenAnswer((_) async => SuccessState(data: [tObservationModel]));

      final result = await repository.getObservations(
        tObservationEntity.workOrderId,
      );

      expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
      verify(
        () => mockLocalDataSource.getObservationsByWorkOrderIds([
          tObservationEntity.workOrderId,
        ]),
      ).called(1);
      verifyZeroInteractions(mockRemoteDataSource);
    });
  });

  group('getObservationsByWorkOrderIds', () {
    test('fetches from remote and caches locally when online', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.getObservationsByWorkOrderIds(any()),
      ).thenAnswer((_) async => SuccessState(data: [tObservationModel]));
      when(
        () => mockLocalDataSource.saveObservations(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.getObservationsByWorkOrderIds([
        tObservationEntity.workOrderId,
      ]);

      expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
      expect(result.data, hasLength(1));
      verify(
        () => mockRemoteDataSource.getObservationsByWorkOrderIds([
          tObservationEntity.workOrderId,
        ]),
      ).called(1);
      verify(
        () => mockLocalDataSource.saveObservations([tObservationModel]),
      ).called(1);
    });

    test('falls back to local data source when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getObservationsByWorkOrderIds(any()),
      ).thenAnswer((_) async => SuccessState(data: [tObservationModel]));

      final result = await repository.getObservationsByWorkOrderIds([
        tObservationEntity.workOrderId,
      ]);

      expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
      expect(result.data, hasLength(1));
      verify(
        () => mockLocalDataSource.getObservationsByWorkOrderIds([
          tObservationEntity.workOrderId,
        ]),
      ).called(1);
      verifyZeroInteractions(mockRemoteDataSource);
    });
  });

  group('watchObservationsRealtime', () {
    test(
      'syncs insert/update event to local DB when not in provider mode',
      () async {
        when(
          () => mockRemoteDataSource.watchObservationsRealtime(
            workOrderId: any(named: 'workOrderId'),
          ),
        ).thenAnswer(
          (_) => Stream.value(
            RealtimeEvent<WorkOrderObservationModel>(
              eventType: RealtimeEventType.insert,
              id: tObservationModel.id,
              companyId: tObservationModel.companyId,
              entity: tObservationModel,
            ),
          ),
        );
        when(
          () => mockLocalDataSource.saveObservation(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final stream = repository.watchObservationsRealtime(
          workOrderId: tObservationEntity.workOrderId,
        );
        await stream.first;

        verify(
          () => mockLocalDataSource.saveObservation(tObservationModel),
        ).called(1);
      },
    );

    test('syncs delete event to local DB when not in provider mode', () async {
      when(
        () => mockRemoteDataSource.watchObservationsRealtime(
          workOrderId: any(named: 'workOrderId'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          RealtimeEvent<WorkOrderObservationModel>(
            eventType: RealtimeEventType.delete,
            id: tObservationModel.id,
            companyId: tObservationModel.companyId,
          ),
        ),
      );
      when(
        () => mockLocalDataSource.deleteObservation(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final stream = repository.watchObservationsRealtime(
        workOrderId: tObservationEntity.workOrderId,
      );
      await stream.first;

      verify(
        () => mockLocalDataSource.deleteObservation(tObservationModel.id),
      ).called(1);
    });
  });

  group('createObservation', () {
    test('should save remotely and update local DB when online', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.createObservation(any()),
      ).thenAnswer((_) async => SuccessState(data: tObservationModel));
      when(
        () => mockLocalDataSource.saveObservation(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.createObservation(tObservationEntity);

      expect(result, isA<SuccessState<WorkOrderObservationEntity>>());
      verify(() => mockRemoteDataSource.createObservation(any())).called(1);
      verify(() => mockLocalDataSource.saveObservation(any())).called(1);
    });

    test('should fallback to local DB when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.saveObservation(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.createObservation(tObservationEntity);

      expect(result, isA<SuccessState<WorkOrderObservationEntity>>());
      verify(() => mockLocalDataSource.saveObservation(any())).called(1);
      verifyZeroInteractions(mockRemoteDataSource);
    });
  });

  test(
    'should return FailureState when online and remote create fails',
    () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.createObservation(any()),
      ).thenAnswer((_) async => FailureState(message: 'Remote error'));

      final result = await repository.createObservation(tObservationEntity);

      expect(result, isA<FailureState<WorkOrderObservationEntity>>());
      expect(
        (result as FailureState<WorkOrderObservationEntity>).message,
        'Remote error',
      );
      verify(() => mockRemoteDataSource.createObservation(any())).called(1);
      verifyZeroInteractions(mockLocalDataSource);
    },
  );

  group('deleteObservation', () {
    test('should delete remotely and update local DB when online', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.deleteObservation(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));
      when(
        () => mockLocalDataSource.deleteObservation(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.deleteObservation(tObservationEntity.id);

      expect(result, isA<SuccessState<bool>>());
      verify(
        () => mockRemoteDataSource.deleteObservation(tObservationEntity.id),
      ).called(1);
      verify(
        () => mockLocalDataSource.deleteObservation(tObservationEntity.id),
      ).called(1);
    });

    test(
      'should return FailureState when online and remote delete fails',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.deleteObservation(any()),
        ).thenAnswer((_) async => FailureState(message: 'Delete error'));

        final result = await repository.deleteObservation(
          tObservationEntity.id,
        );

        expect(result, isA<FailureState<bool>>());
        expect((result as FailureState<bool>).message, 'Delete error');
        verify(
          () => mockRemoteDataSource.deleteObservation(tObservationEntity.id),
        ).called(1);
        verifyZeroInteractions(mockLocalDataSource);
      },
    );
  });

  group('WorkOrderObservationsRepository in provider mode', () {
    setUp(() {
      when(
        () => mockSessionRepository.getSelectedMode(),
      ).thenReturn(AppMode.provider.name);
    });

    test('getObservations fetches remotely without saving locally', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.getObservationsByWorkOrderIds(any()),
      ).thenAnswer((_) async => SuccessState(data: [tObservationModel]));

      final result = await repository.getObservations(
        tObservationEntity.workOrderId,
      );

      expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
      verify(
        () => mockRemoteDataSource.getObservationsByWorkOrderIds([
          tObservationEntity.workOrderId,
        ]),
      ).called(1);
      verifyNever(() => mockLocalDataSource.saveObservations(any()));
    });

    test(
      'getObservations returns failure without local fallback when offline',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);

        final result = await repository.getObservations(
          tObservationEntity.workOrderId,
        );

        expect(result, isA<FailureState<List<WorkOrderObservationEntity>>>());
        verifyNever(() => mockLocalDataSource.getObservations(any()));
      },
    );

    test('createObservation posts remotely without saving locally', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.createObservation(any()),
      ).thenAnswer((_) async => SuccessState(data: tObservationModel));

      final result = await repository.createObservation(tObservationEntity);

      expect(result, isA<SuccessState<WorkOrderObservationEntity>>());
      verify(
        () => mockRemoteDataSource.createObservation(tObservationModel),
      ).called(1);
      verifyNever(() => mockLocalDataSource.saveObservation(any()));
    });

    test(
      'createObservation fails without saving locally when offline',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);

        final result = await repository.createObservation(tObservationEntity);

        expect(result, isA<FailureState<WorkOrderObservationEntity>>());
        verifyNever(() => mockLocalDataSource.saveObservation(any()));
      },
    );
  });
}
