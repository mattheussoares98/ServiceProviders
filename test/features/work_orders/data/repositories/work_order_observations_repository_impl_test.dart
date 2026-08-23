import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/repositories/work_order_observations_repository_impl.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockWorkOrderObservationsRemoteDataSource mockRemoteDataSource;
  late MockWorkOrderObservationsLocalDataSource mockLocalDataSource;
  late MockSessionRepository mockSessionRepository;
  late MockSyncRepository mockSyncRepository;
  late MockOfflineTracker mockOfflineTracker;
  late WorkOrderObservationsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeSyncQueueItemEntity());
    registerFallbackValue(EntityFactory.makeWorkOrderObservationEntity());
    registerFallbackValue(
      WorkOrderObservationModel.fromEntity(
        EntityFactory.makeWorkOrderObservationEntity(),
      ),
    );
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockWorkOrderObservationsRemoteDataSource();
    mockLocalDataSource = MockWorkOrderObservationsLocalDataSource();
    mockSessionRepository = MockSessionRepository();
    mockSyncRepository = MockSyncRepository();
    mockOfflineTracker = MockOfflineTracker();
    when(
      () => mockSessionRepository.getSelectedMode(),
    ).thenReturn(AppMode.internal.name);
    when(
      () => mockSessionRepository.userData,
    ).thenReturn(EntityFactory.makeUserDataEntity());
    when(
      () => mockSessionRepository.getSelectedCompanyId(),
    ).thenReturn('company-1');
    when(
      () => mockSyncRepository.enqueue(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(() => mockOfflineTracker.recordOfflineAction()).thenReturn(false);

    repository = WorkOrderObservationsRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      sessionRepository: mockSessionRepository,
      syncRepository: mockSyncRepository,
      offlineTracker: mockOfflineTracker,
    );
  });

  final tObservationEntity = EntityFactory.makeWorkOrderObservationEntity();
  final tObservationModel = WorkOrderObservationModel.fromEntity(
    tObservationEntity,
  );

  group('getObservations', () {
    test(
      'should fetch remote observations and cache them locally when online',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getObservations(any()),
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
          () => mockRemoteDataSource.getObservations(
            tObservationEntity.workOrderId,
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveObservations([tObservationModel]),
        ).called(1);
      },
    );

    test('should fetch local observations when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getObservations(any()),
      ).thenAnswer((_) async => SuccessState(data: [tObservationModel]));

      final result = await repository.getObservations(
        tObservationEntity.workOrderId,
      );

      expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
      verify(
        () =>
            mockLocalDataSource.getObservations(tObservationEntity.workOrderId),
      ).called(1);
      verifyZeroInteractions(mockRemoteDataSource);
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
        () => mockRemoteDataSource.getObservations(any()),
      ).thenAnswer((_) async => SuccessState(data: [tObservationModel]));

      final result = await repository.getObservations(tObservationEntity.workOrderId);

      expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
      verify(() => mockRemoteDataSource.getObservations(tObservationEntity.workOrderId)).called(1);
      verifyNever(() => mockLocalDataSource.saveObservations(any()));
    });

    test('getObservations returns failure without local fallback when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);

      final result = await repository.getObservations(tObservationEntity.workOrderId);

      expect(result, isA<FailureState<List<WorkOrderObservationEntity>>>());
      verifyNever(() => mockLocalDataSource.getObservations(any()));
    });

    test('createObservation posts remotely without saving locally', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.createObservation(any()),
      ).thenAnswer((_) async => SuccessState(data: tObservationModel));

      final result = await repository.createObservation(tObservationEntity);

      expect(result, isA<SuccessState<WorkOrderObservationEntity>>());
      verify(() => mockRemoteDataSource.createObservation(tObservationModel)).called(1);
      verifyNever(() => mockLocalDataSource.saveObservation(any()));
    });

    test('createObservation fails without saving locally when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);

      final result = await repository.createObservation(tObservationEntity);

      expect(result, isA<FailureState<WorkOrderObservationEntity>>());
      verifyNever(() => mockLocalDataSource.saveObservation(any()));
    });
  });
}
