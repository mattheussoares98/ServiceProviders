import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sync/data/data_sources/sync_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sync/data/models/sync_queue_item_model.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_status.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late SyncLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = SyncLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertTestPrerequisites({
    required String companyId,
    required String userProfileId,
  }) async {
    await database
        .into(database.companies)
        .insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );

    await database
        .into(database.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            id: userProfileId,
            companyId: companyId,
            name: faker.person.name(),
            email: faker.internet.email(),
            isActive: const Value(true),
          ),
        );
  }

  group('SyncLocalDataSourceImpl', () {
    test(
      'should enqueue items and retrieve them in strict FIFO order',
      () async {
        final tEntity1 = EntityFactory.makeSyncQueueItemEntity().copyWith(
          createdAt: DateTime.utc(2026, 8, 23, 10),
        );
        final tEntity2 = EntityFactory.makeSyncQueueItemEntity().copyWith(
          companyId: tEntity1.companyId,
          userProfileId: tEntity1.userProfileId,
          createdAt: DateTime.utc(2026, 8, 23, 10, 5),
        );

        await insertTestPrerequisites(
          companyId: tEntity1.companyId,
          userProfileId: tEntity1.userProfileId,
        );

        // Act: Enqueue in reverse order to ensure query sorts by createdAt ASC
        await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity2));
        await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity1));

        final result = await dataSource.getPendingItems();

        expect(result, isA<SuccessState<List<SyncQueueItemModel>>>());
        final items = result.data!;
        expect(items.length, equals(2));
        expect(items.first.id, equals(tEntity1.id));
        expect(items.last.id, equals(tEntity2.id));
      },
    );

    test('should mark an item as syncing and increment attempts', () async {
      final tEntity = EntityFactory.makeSyncQueueItemEntity();
      await insertTestPrerequisites(
        companyId: tEntity.companyId,
        userProfileId: tEntity.userProfileId,
      );

      await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity));

      final markResult = await dataSource.markItemSyncing(tEntity.id);
      expect(markResult, isA<SuccessState<bool>>());
      expect(markResult.data, isTrue);

      final pendingResult = await dataSource.getPendingItems();
      expect(pendingResult.data!.first.status, equals(SyncStatus.syncing));
      expect(pendingResult.data!.first.attempts, equals(1));
    });

    test('should mark an item as failed with error details', () async {
      final tEntity = EntityFactory.makeSyncQueueItemEntity();
      await insertTestPrerequisites(
        companyId: tEntity.companyId,
        userProfileId: tEntity.userProfileId,
      );

      await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity));

      const errorMsg = '400 Bad Request: Constraint failed';
      final markResult = await dataSource.markItemFailed(tEntity.id, errorMsg);
      expect(markResult, isA<SuccessState<bool>>());
      expect(markResult.data, isTrue);

      final query =
          database.select(database.syncAuditLogs)
            ..where((t) => t.id.equals(tEntity.id));
      final row = await query.getSingle();
      expect(row.status, equals(SyncStatus.failed.code));
      expect(row.lastError, equals(errorMsg));
    });

    test('should remove a queue item', () async {
      final tEntity = EntityFactory.makeSyncQueueItemEntity();
      await insertTestPrerequisites(
        companyId: tEntity.companyId,
        userProfileId: tEntity.userProfileId,
      );

      await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity));
      final removeResult = await dataSource.removeQueueItem(tEntity.id);
      expect(removeResult, isA<SuccessState<bool>>());
      expect(removeResult.data, isTrue);

      final countResult = await dataSource.getPendingCount();
      expect(countResult.data, equals(0));
    });

    test('should return correct pending count', () async {
      final tEntity = EntityFactory.makeSyncQueueItemEntity();
      await insertTestPrerequisites(
        companyId: tEntity.companyId,
        userProfileId: tEntity.userProfileId,
      );

      await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity));
      final countResult = await dataSource.getPendingCount();
      expect(countResult.data, equals(1));
    });

    test('should mark an item as deadLetter', () async {
      final tEntity = EntityFactory.makeSyncQueueItemEntity();
      await insertTestPrerequisites(
        companyId: tEntity.companyId,
        userProfileId: tEntity.userProfileId,
      );

      await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity));
      final markResult = await dataSource.markItemDeadLetter(
        tEntity.id,
        'Permanent error',
      );
      expect(markResult, isA<SuccessState<bool>>());
      expect(markResult.data, isTrue);

      final query =
          database.select(database.syncAuditLogs)
            ..where((t) => t.id.equals(tEntity.id));
      final row = await query.getSingle();
      expect(row.status, equals(SyncStatus.deadLetter.code));
      expect(row.lastError, equals('Permanent error'));

      // Pending count should be 0 because deadLetter is excluded
      final countResult = await dataSource.getPendingCount();
      expect(countResult.data, equals(0));
    });

    test('should cancel all pending items for an entity with cancelPendingForEntity', () async {
      final tEntity1 = EntityFactory.makeSyncQueueItemEntity().copyWith(
        entityId: 'wo-100',
        operation: SyncOperationType.create,
      );
      final tEntity2 = EntityFactory.makeSyncQueueItemEntity().copyWith(
        companyId: tEntity1.companyId,
        userProfileId: tEntity1.userProfileId,
        entityId: 'wo-100',
        operation: SyncOperationType.update,
      );
      final tEntityChild = EntityFactory.makeSyncQueueItemEntity().copyWith(
        companyId: tEntity1.companyId,
        userProfileId: tEntity1.userProfileId,
        entityId: 'obs-1',
        payload: '{"workOrderId": "wo-100", "content": "note"}',
      );

      await insertTestPrerequisites(
        companyId: tEntity1.companyId,
        userProfileId: tEntity1.userProfileId,
      );

      await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity1));
      await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity2));
      await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntityChild));

      final cancelResult = await dataSource.cancelPendingForEntity(
        'wo-100',
        'Parent creation failed',
      );
      expect(cancelResult, isA<SuccessState<void>>());

      final allRows = await database.select(database.syncAuditLogs).get();
      expect(allRows.length, equals(3));
      for (final row in allRows) {
        expect(row.status, equals(SyncStatus.deadLetter.code));
        expect(row.lastError, equals('Parent creation failed'));
      }
    });

    test('should emit updated pending counts from watchPendingCount stream', () async {
      final tEntity = EntityFactory.makeSyncQueueItemEntity();
      await insertTestPrerequisites(
        companyId: tEntity.companyId,
        userProfileId: tEntity.userProfileId,
      );

      final stream = dataSource.watchPendingCount();
      final counts = <int>[];
      final sub = stream.listen(counts.add);

      await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity));
      await pumpEventQueue();

      expect(counts, contains(1));
      await sub.cancel();
    });

    test(
      'should emit dead-letter items matching entityId or payload from watchDeadLetterItemsForEntity',
      () async {
        final tEntity1 = EntityFactory.makeSyncQueueItemEntity().copyWith(
          entityId: 'wo-100',
        );
        final tEntityChild = EntityFactory.makeSyncQueueItemEntity().copyWith(
          companyId: tEntity1.companyId,
          userProfileId: tEntity1.userProfileId,
          entityId: 'obs-1',
          payload: '{"workOrderId": "wo-100", "content": "note"}',
        );
        final tEntityOther = EntityFactory.makeSyncQueueItemEntity().copyWith(
          companyId: tEntity1.companyId,
          userProfileId: tEntity1.userProfileId,
          entityId: 'wo-200',
        );

        await insertTestPrerequisites(
          companyId: tEntity1.companyId,
          userProfileId: tEntity1.userProfileId,
        );

        await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity1));
        await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntityChild));
        await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntityOther));

        // Mark items as dead-letter
        await dataSource.markItemDeadLetter(tEntity1.id, 'Error 1');
        await dataSource.markItemDeadLetter(tEntityChild.id, 'Error 2');
        await dataSource.markItemDeadLetter(tEntityOther.id, 'Error 3');

        final stream = dataSource.watchDeadLetterItemsForEntity('wo-100');
        final emissions = <List<SyncQueueItemModel>>[];
        final sub = stream.listen(emissions.add);

        await pumpEventQueue();

        expect(emissions.isNotEmpty, isTrue);
        final latest = emissions.last;
        expect(latest.length, equals(2));
        expect(latest.map((e) => e.id), containsAll([tEntity1.id, tEntityChild.id]));

        await sub.cancel();
      },
    );

    test(
      'should reset dead-letter items back to pending with 0 attempts via retryDeadLetterForEntity',
      () async {
        final tEntity1 = EntityFactory.makeSyncQueueItemEntity().copyWith(
          entityId: 'wo-100',
        );
        final tEntityChild = EntityFactory.makeSyncQueueItemEntity().copyWith(
          companyId: tEntity1.companyId,
          userProfileId: tEntity1.userProfileId,
          entityId: 'obs-1',
          payload: '{"workOrderId": "wo-100", "content": "note"}',
        );

        await insertTestPrerequisites(
          companyId: tEntity1.companyId,
          userProfileId: tEntity1.userProfileId,
        );

        await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntity1));
        await dataSource.enqueue(SyncQueueItemModel.fromEntity(tEntityChild));

        await dataSource.markItemDeadLetter(tEntity1.id, 'Error 1');
        await dataSource.markItemDeadLetter(tEntityChild.id, 'Error 2');

        final retryResult = await dataSource.retryDeadLetterForEntity('wo-100');
        expect(retryResult, isA<SuccessState<bool>>());
        expect(retryResult.data, isTrue);

        final allRows = await database.select(database.syncAuditLogs).get();
        for (final row in allRows) {
          expect(row.status, equals(SyncStatus.pending.code));
          expect(row.attempts, equals(0));
          expect(row.lastError, isNull);
        }

        final nonExistentResult = await dataSource.retryDeadLetterForEntity('wo-999');
        expect(nonExistentResult.data, isFalse);
      },
    );
  });
}
