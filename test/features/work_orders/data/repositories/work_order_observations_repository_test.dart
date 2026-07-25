import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/repositories/work_order_observations_repository_impl.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockWorkOrderObservationsRemoteDataSource mockRemoteDataSource;
  late MockWorkOrderObservationsLocalDataSource mockLocalDataSource;
  late WorkOrderObservationsRepositoryImpl repository;

  setUpAll(() {
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
    repository = WorkOrderObservationsRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
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

    test(
      'should fetch local observations when offline',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.getObservations(any()),
        ).thenAnswer((_) async => SuccessState(data: [tObservationModel]));

        final result = await repository.getObservations(
          tObservationEntity.workOrderId,
        );

        expect(result, isA<SuccessState<List<WorkOrderObservationEntity>>>());
        verify(
          () => mockLocalDataSource.getObservations(
            tObservationEntity.workOrderId,
          ),
        ).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
      },
    );
  });

  group('createObservation', () {
    test(
      'should save remotely and update local DB when online',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.createObservation(any()),
        ).thenAnswer((_) async => SuccessState(data: tObservationModel));
        when(
          () => mockLocalDataSource.saveObservation(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createObservation(tObservationEntity);

        expect(result, isA<SuccessState<WorkOrderObservationEntity>>());
        verify(
          () => mockRemoteDataSource.createObservation(any()),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveObservation(any()),
        ).called(1);
      },
    );

    test(
      'should fallback to local DB when offline',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveObservation(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createObservation(tObservationEntity);

        expect(result, isA<SuccessState<WorkOrderObservationEntity>>());
        verify(
          () => mockLocalDataSource.saveObservation(any()),
        ).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
      },
    );
  });

  group('deleteObservation', () {
    test(
      'should delete remotely and update local DB when online',
      () async {
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
      },
    );
  });
}
