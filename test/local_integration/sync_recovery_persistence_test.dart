import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/sync/data/data_sources/sync_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sync/data/models/sync_queue_item_model.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_status.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/system_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  SyncLocalDataSourceImpl source() =>
      SyncLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'pending work retains identity, ownership, payload, and FIFO order on restart',
    () async {
      final first = SystemFactory.makeSyncQueueItemEntity().copyWith(
        createdAt: DateTime.utc(2026, 9, 18),
        payload: jsonEncode({
          'title': 'Inspeção – bomba',
          'notes': 'Linha 1\nLinha 2',
        }),
      );
      final second = SystemFactory.makeSyncQueueItemEntity().copyWith(
        companyId: first.companyId,
        userProfileId: first.userProfileId,
        createdAt: DateTime.utc(2026, 9, 19),
      );
      expect(
        (await source().enqueue(SyncQueueItemModel.fromEntity(second))).data,
        isTrue,
      );
      expect(
        (await source().enqueue(SyncQueueItemModel.fromEntity(first))).data,
        isTrue,
      );
      await fixture.reopen();
      final rows = (await source().getPendingItems()).data!;
      expect(rows.map((r) => r.id), [first.id, second.id]);
      expect(rows.first.entityId, first.entityId);
      expect(rows.first.companyId, first.companyId);
      expect(rows.first.userProfileId, first.userProfileId);
      expect(rows.first.payload, first.payload);
      expect(rows.first.operation, first.operation);
      expect(
        (await source().getPendingItems(limit: 1)).data!.single.id,
        first.id,
      );
    },
  );

  test('interrupted sync is available for recovery after reopening', () async {
    final item = SystemFactory.makeSyncQueueItemEntity();
    expect(
      (await source().enqueue(SyncQueueItemModel.fromEntity(item))).data,
      isTrue,
    );
    expect((await source().markItemSyncing(item.id)).data, isTrue);
    await fixture.reopen();
    final row = (await source().getPendingItems()).data!.single;
    expect(row.id, item.id);
    expect(row.status, SyncStatus.syncing);
    expect(row.attempts, 1);
    expect(row.payload, item.payload);
    expect((await source().getPendingCount()).data, 1);
  });

  test(
    'dead-letter work survives restart and explicit retry clears its error',
    () async {
      final item = SystemFactory.makeSyncQueueItemEntity();
      expect(
        (await source().enqueue(SyncQueueItemModel.fromEntity(item))).data,
        isTrue,
      );
      expect((await source().markItemSyncing(item.id)).data, isTrue);
      expect(
        (await source().markItemDeadLetter(item.id, 'permission denied')).data,
        isTrue,
      );
      await fixture.reopen();
      expect((await source().getPendingItems()).data, isEmpty);
      var dead = await source()
          .watchDeadLetterItemsForEntity(item.entityId)
          .first;
      expect(dead.single.lastError, 'permission denied');
      expect(dead.single.attempts, 1);
      expect(
        (await source().retryDeadLetterForEntity(item.entityId)).data,
        isTrue,
      );
      await fixture.reopen();
      final row = (await source().getPendingItems()).data!.single;
      expect(row.id, item.id);
      expect(row.status, SyncStatus.pending);
      expect(row.attempts, 0);
      expect(row.lastError, isNull);
      dead = await source().watchDeadLetterItemsForEntity(item.entityId).first;
      expect(dead, isEmpty);
    },
  );

  test(
    'acknowledged queue removal persists and preserves unrelated work',
    () async {
      final a = SystemFactory.makeSyncQueueItemEntity();
      final b = SystemFactory.makeSyncQueueItemEntity();
      expect(
        (await source().enqueue(SyncQueueItemModel.fromEntity(a))).data,
        isTrue,
      );
      expect(
        (await source().enqueue(SyncQueueItemModel.fromEntity(b))).data,
        isTrue,
      );
      await fixture.reopen();
      expect((await source().removeQueueItem(a.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getPendingItems()).data!.single.id, b.id);
      expect((await source().getPendingCount()).data, 1);
    },
  );

  test(
    'canceling an order does not cancel unrelated work mentioning its ID in text',
    () async {
      final order = SystemFactory.makeSyncQueueItemEntity();
      final child = SystemFactory.makeSyncQueueItemEntity().copyWith(
        companyId: order.companyId,
        entityType: SyncEntityType.task,
        payload: jsonEncode({
          'work_order_id': order.entityId,
          'title': 'Inspection',
        }),
      );
      final unrelated = SystemFactory.makeSyncQueueItemEntity().copyWith(
        companyId: order.companyId,
        payload: jsonEncode({
          'title': 'Other order',
          'description': 'Compare the repair with ${order.entityId}',
        }),
      );
      for (final item in [order, child, unrelated]) {
        expect(
          (await source().enqueue(SyncQueueItemModel.fromEntity(item))).data,
          isTrue,
        );
      }
      await fixture.reopen();
      expect(
        (await source().cancelPendingForEntity(
          order.entityId,
          'order removed',
        )).hasError,
        isFalse,
      );
      await fixture.reopen();
      expect((await source().getPendingItems()).data!.map((r) => r.id), [
        unrelated.id,
      ]);
      final canceled = await source()
          .watchDeadLetterItemsForEntity(order.entityId)
          .first;
      expect(canceled.map((r) => r.id), unorderedEquals([order.id, child.id]));
    },
  );
}
