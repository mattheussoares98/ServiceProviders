import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sync/data/models/sync_error_model.dart';
import 'package:o_jogo_da_obra/features/sync/data/models/sync_queue_item_model.dart';
import 'package:o_jogo_da_obra/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/factories/system_factory.dart';

void main() {
  late MockInternetClient mockInternet;
  late MockSyncLocalDataSource mockLocalDataSource;
  late MockSyncRemoteDataSource mockRemoteDataSource;
  late SyncRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      SyncQueueItemModel.fromEntity(SystemFactory.makeSyncQueueItemEntity()),
    );
    registerFallbackValue(
      SyncErrorModel.fromEntity(SystemFactory.makeSyncErrorEntity()),
    );
  });

  setUp(() {
    mockInternet = MockInternetClient();
    mockLocalDataSource = MockSyncLocalDataSource();
    mockRemoteDataSource = MockSyncRemoteDataSource();
    repository = SyncRepositoryImpl(
      internet: mockInternet,
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final tQueueItemEntity = SystemFactory.makeSyncQueueItemEntity();
  final tQueueItemModel = SyncQueueItemModel.fromEntity(tQueueItemEntity);
  final tErrorEntity = SystemFactory.makeSyncErrorEntity();
  final tErrorModel = SyncErrorModel.fromEntity(tErrorEntity);

  group('SyncRepositoryImpl', () {
    group('enqueue', () {
      test(
        'should call localDataSource.enqueue and return SuccessState',
        () async {
          when(
            () => mockLocalDataSource.enqueue(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.enqueue(tQueueItemEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.enqueue(any())).called(1);
        },
      );
    });

    group('getPendingItems', () {
      test(
        'should return mapped pending items from local data source',
        () async {
          when(
            () =>
                mockLocalDataSource.getPendingItems(limit: any(named: 'limit')),
          ).thenAnswer((_) async => SuccessState(data: [tQueueItemModel]));

          final result = await repository.getPendingItems();

          expect(result, isA<SuccessState<List<SyncQueueItemEntity>>>());
          expect(result.data!.length, equals(1));
          expect(result.data!.first.id, equals(tQueueItemEntity.id));
          verify(() => mockLocalDataSource.getPendingItems()).called(1);
        },
      );
    });

    group('markItemSyncing', () {
      test('should call localDataSource.markItemSyncing', () async {
        when(
          () => mockLocalDataSource.markItemSyncing(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.markItemSyncing(tQueueItemEntity.id);

        expect(result, isA<SuccessState<bool>>());
        verify(
          () => mockLocalDataSource.markItemSyncing(tQueueItemEntity.id),
        ).called(1);
      });
    });

    group('markItemFailed', () {
      test('should call localDataSource.markItemFailed', () async {
        when(
          () => mockLocalDataSource.markItemFailed(any(), any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.markItemFailed(
          tQueueItemEntity.id,
          'Network failure',
        );

        expect(result, isA<SuccessState<bool>>());
        verify(
          () => mockLocalDataSource.markItemFailed(
            tQueueItemEntity.id,
            'Network failure',
          ),
        ).called(1);
      });
    });

    group('markItemDeadLetter', () {
      test('should call localDataSource.markItemDeadLetter', () async {
        when(
          () => mockLocalDataSource.markItemDeadLetter(any(), any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.markItemDeadLetter(
          tQueueItemEntity.id,
          'Permanent error',
        );

        expect(result, isA<SuccessState<bool>>());
        verify(
          () => mockLocalDataSource.markItemDeadLetter(
            tQueueItemEntity.id,
            'Permanent error',
          ),
        ).called(1);
      });
    });

    group('cancelPendingForEntity', () {
      test('should call localDataSource.cancelPendingForEntity', () async {
        when(
          () => mockLocalDataSource.cancelPendingForEntity(any(), any()),
        ).thenAnswer((_) async => SuccessState.nil);

        final result = await repository.cancelPendingForEntity(
          'wo-1',
          'Parent creation failed',
        );

        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockLocalDataSource.cancelPendingForEntity(
            'wo-1',
            'Parent creation failed',
          ),
        ).called(1);
      });
    });

    group('watchDeadLetterItemsForEntity', () {
      test('should return mapped stream from localDataSource', () async {
        when(
          () => mockLocalDataSource.watchDeadLetterItemsForEntity(any()),
        ).thenAnswer((_) => Stream.value([tQueueItemModel]));

        final stream = repository.watchDeadLetterItemsForEntity('wo-1');
        final items = await stream.first;

        expect(items.length, equals(1));
        expect(items.first.id, equals(tQueueItemEntity.id));
        verify(
          () => mockLocalDataSource.watchDeadLetterItemsForEntity('wo-1'),
        ).called(1);
      });
    });

    group('retryDeadLetterForEntity', () {
      test(
        'should delegate to localDataSource.retryDeadLetterForEntity',
        () async {
          when(
            () => mockLocalDataSource.retryDeadLetterForEntity(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.retryDeadLetterForEntity('wo-1');

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockLocalDataSource.retryDeadLetterForEntity('wo-1'),
          ).called(1);
        },
      );
    });

    group('removeQueueItem', () {
      test('should call localDataSource.removeQueueItem', () async {
        when(
          () => mockLocalDataSource.removeQueueItem(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.removeQueueItem(tQueueItemEntity.id);

        expect(result, isA<SuccessState<bool>>());
        verify(
          () => mockLocalDataSource.removeQueueItem(tQueueItemEntity.id),
        ).called(1);
      });
    });

    group('getPendingCount', () {
      test('should return pending count from local data source', () async {
        when(
          () => mockLocalDataSource.getPendingCount(),
        ).thenAnswer((_) async => const SuccessState(data: 3));

        final result = await repository.getPendingCount();

        expect(result, isA<SuccessState<int>>());
        expect(result.data, equals(3));
      });
    });

    group('reportSyncError', () {
      test('should call remoteDataSource when online', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.reportSyncError(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.reportSyncError(tErrorEntity);

        expect(result, isA<SuccessState<bool>>());
        verify(
          () => mockRemoteDataSource.reportSyncError(tErrorModel),
        ).called(1);
      });

      test('should return FailureState.noInternet when offline', () async {
        when(() => mockInternet.isConnected).thenReturn(false);

        final result = await repository.reportSyncError(tErrorEntity);

        expect(result, isA<FailureState<bool>>());
        verifyNever(() => mockRemoteDataSource.reportSyncError(any()));
      });
    });
  });
}
