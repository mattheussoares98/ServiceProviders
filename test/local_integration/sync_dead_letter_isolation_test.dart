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
  final target = SystemFactory.makeSyncQueueItemEntity().copyWith(
    status: SyncStatus.deadLetter,
    attempts: 3,
    lastError: 'not authorized',
  );
  final unrelated = SystemFactory.makeSyncQueueItemEntity().copyWith(
    companyId: target.companyId,
    status: SyncStatus.deadLetter,
    attempts: 3,
    lastError: 'unrelated conflict',
    payload: jsonEncode({
      'description': 'Related discussion: ${target.entityId}',
    }),
  );
  setUp(() async {
    fixture = LocalDatabaseFixture();
    for (final item in [target, unrelated]) {
      expect(
        (await source().enqueue(SyncQueueItemModel.fromEntity(item))).data,
        isTrue,
      );
    }
    await fixture.reopen();
  });
  tearDown(() => fixture.dispose());

  test(
    'dead-letter lookup excludes unrelated free-text mentions of the entity ID',
    () async {
      final rows = await source()
          .watchDeadLetterItemsForEntity(target.entityId)
          .first;
      expect(rows.map((r) => r.id), [target.id]);
    },
  );

  test(
    'retrying one entity preserves unrelated failed work and its error after restart',
    () async {
      expect(
        (await source().retryDeadLetterForEntity(target.entityId)).data,
        isTrue,
      );
      await fixture.reopen();
      final all = await fixture.database
          .select(fixture.database.syncAuditLogs)
          .get();
      final retried = all.singleWhere((r) => r.id == target.id);
      final preserved = all.singleWhere((r) => r.id == unrelated.id);
      expect(retried.status, SyncStatus.pending.code);
      expect(retried.attempts, 0);
      expect(retried.lastError, isNull);
      expect(preserved.status, SyncStatus.deadLetter.code);
      expect(preserved.attempts, 3);
      expect(preserved.lastError, 'unrelated conflict');
    },
  );

  test(
    'structured child work-order references are included in recovery lookup',
    () async {
      final child = SystemFactory.makeSyncQueueItemEntity().copyWith(
        companyId: target.companyId,
        status: SyncStatus.deadLetter,
        entityType: SyncEntityType.task,
        payload: jsonEncode({'work_order_id': target.entityId}),
      );
      expect(
        (await source().enqueue(SyncQueueItemModel.fromEntity(child))).data,
        isTrue,
      );
      await fixture.reopen();
      final rows = await source()
          .watchDeadLetterItemsForEntity(target.entityId)
          .first;
      expect(rows.map((r) => r.id), containsAll([target.id, child.id]));
    },
  );
}
