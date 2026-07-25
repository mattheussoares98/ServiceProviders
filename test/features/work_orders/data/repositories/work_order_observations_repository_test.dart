import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/repositories/work_order_observations_repository_impl.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';

import '../../../../../testing/mocks/entity_factory.dart';

class MockWorkOrderObservationsRemoteDataSource extends Mock
    implements WorkOrderObservationsRemoteDataSource {}

void main() {
  late MockWorkOrderObservationsRemoteDataSource mockRemoteDataSource;
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
    mockRemoteDataSource = MockWorkOrderObservationsRemoteDataSource();
    repository = WorkOrderObservationsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final tObservationEntity = EntityFactory.makeWorkOrderObservationEntity();
  final tObservationModel = WorkOrderObservationModel.fromEntity(
    tObservationEntity,
  );

  group('getObservations', () {
    test(
      'should return list of observation entities when remote dataSource succeeds',
      () async {
        when(
          () => mockRemoteDataSource.getObservations(any()),
        ).thenAnswer((_) async => SuccessState(data: [tObservationModel]));

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
      },
    );

    test('should return failure state when remote dataSource fails', () async {
      when(
        () => mockRemoteDataSource.getObservations(any()),
      ).thenAnswer((_) async => FailureState(message: 'Erro'));

      final result = await repository.getObservations(
        tObservationEntity.workOrderId,
      );

      expect(result, isA<FailureState<List<WorkOrderObservationEntity>>>());
      verify(
        () => mockRemoteDataSource.getObservations(
          tObservationEntity.workOrderId,
        ),
      ).called(1);
    });
  });

  group('createObservation', () {
    test(
      'should return created observation entity when remote dataSource succeeds',
      () async {
        when(
          () => mockRemoteDataSource.createObservation(any()),
        ).thenAnswer((_) async => SuccessState(data: tObservationModel));

        final result = await repository.createObservation(tObservationEntity);

        expect(result, isA<SuccessState<WorkOrderObservationEntity>>());
        expect(
          (result as SuccessState<WorkOrderObservationEntity>).data!.id,
          tObservationEntity.id,
        );
        verify(() => mockRemoteDataSource.createObservation(any())).called(1);
      },
    );
  });

  group('deleteObservation', () {
    test('should return true when remote dataSource succeeds', () async {
      when(
        () => mockRemoteDataSource.deleteObservation(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.deleteObservation(tObservationEntity.id);

      expect(result, isA<SuccessState<bool>>());
      expect((result as SuccessState<bool>).data, true);
      verify(
        () => mockRemoteDataSource.deleteObservation(tObservationEntity.id),
      ).called(1);
    });
  });
}
