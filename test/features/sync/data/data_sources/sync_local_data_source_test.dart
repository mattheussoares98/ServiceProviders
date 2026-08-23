import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sync/data/data_sources/sync_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sync/data/models/sync_queue_item_model.dart';
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
  });
}
