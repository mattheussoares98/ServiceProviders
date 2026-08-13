import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_reason_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/repositories/pause_repository_impl.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockPauseRemoteDataSource mockRemoteDataSource;
  late MockPauseLocalDataSource mockLocalDataSource;
  late PauseRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      PauseReasonModel.fromEntity(EntityFactory.makePauseReasonEntity()),
    );
    registerFallbackValue(
      PauseRequestModel.fromEntity(EntityFactory.makePauseRequestEntity()),
    );
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockPauseRemoteDataSource();
    mockLocalDataSource = MockPauseLocalDataSource();
    repository = PauseRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tReasonEntity = EntityFactory.makePauseReasonEntity();
  final tReasonModel = PauseReasonModel.fromEntity(tReasonEntity);

  final tRequestEntity = EntityFactory.makePauseRequestEntity();
  final tRequestModel = PauseRequestModel.fromEntity(tRequestEntity);

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
      'should fetch remote requests and cache locally when online',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getPauseRequests(any()),
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
            status: any(named: 'status'),
            reviewObservation: any(named: 'reviewObservation'),
            reviewedById: any(named: 'reviewedById'),
            reasonId: any(named: 'reasonId'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.reviewPause(
            id: any(named: 'id'),
            status: any(named: 'status'),
            reviewObservation: any(named: 'reviewObservation'),
            reviewedById: any(named: 'reviewedById'),
            reasonId: any(named: 'reasonId'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.reviewPause(
          id: tRequestEntity.id,
          status: PauseRequestStatus.approved,
          reviewObservation: 'observation',
          reviewedById: 'manager-id',
          reasonId: 'reason-id',
        );

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
      },
    );
  });

  group('cancelPause', () {
    test(
      'should cancel remote pause and save locally when successful',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.cancelPause(
            id: any(named: 'id'),
            resumedAt: any(named: 'resumedAt'),
            resumedById: any(named: 'resumedById'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.cancelPause(
            id: any(named: 'id'),
            resumedAt: any(named: 'resumedAt'),
            resumedById: any(named: 'resumedById'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.cancelPause(
          id: tRequestEntity.id,
          resumedAt: DateTime.now(),
          resumedById: tRequestEntity.resumedById!,
        );

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
      },
    );
  });
}
