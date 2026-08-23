import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sync/data/models/sync_queue_item_model.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_status.dart';

abstract interface class SyncLocalDataSource {
  FutureBool enqueue(SyncQueueItemModel item);
  FutureList<SyncQueueItemModel> getPendingItems({int limit = 50});
  FutureBool markItemSyncing(String id);
  FutureBool markItemFailed(String id, String error);
  FutureBool markItemDeadLetter(String id, String error);
  FutureVoid cancelPendingForEntity(String entityId, String reason);
  Stream<List<SyncQueueItemModel>> watchDeadLetterItemsForEntity(
    String entityId,
  );
  FutureBool retryDeadLetterForEntity(String entityId);
  FutureBool removeQueueItem(String id);
  FutureData<int> getPendingCount();
  Stream<int> watchPendingCount();
}

@LazySingleton(as: SyncLocalDataSource)
final class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  SyncLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureBool enqueue(SyncQueueItemModel item) => ErrorHandler.execute(() async {
    await _database
        .into(_database.syncAuditLogs)
        .insertOnConflictUpdate(
          SyncAuditLogsCompanion.insert(
            id: item.id,
            companyId: item.companyId,
            userProfileId: item.userProfileId,
            entityType: item.entityType.code,
            entityId: item.entityId,
            operation: item.operation.code,
            payload: Value(item.payload),
            status: Value(item.status.code),
            attempts: Value(item.attempts),
            lastError: Value(item.lastError),
            createdAt: Value(item.createdAt),
            syncedAt: Value(item.syncedAt),
          ),
        );
    return const SuccessState(data: true);
  });

  @override
  FutureList<SyncQueueItemModel> getPendingItems({int limit = 50}) =>
      ErrorHandler.execute(() async {
        final query =
            _database.select(_database.syncAuditLogs)
              ..where(
                (t) =>
                    (t.status.equals(SyncStatus.pending.code) |
                        t.status.equals(SyncStatus.syncing.code) |
                        t.status.equals(SyncStatus.failed.code)) &
                    t.attempts.isSmallerThanValue(3),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
              ..limit(limit);

        final rows = await query.get();
        final models =
            rows
                .map(
                  (row) => SyncQueueItemModel(
                    id: row.id,
                    companyId: row.companyId,
                    userProfileId: row.userProfileId,
                    entityType: SyncEntityType.fromCode(row.entityType),
                    entityId: row.entityId,
                    operation: SyncOperationType.fromCode(row.operation),
                    payload: row.payload,
                    status: SyncStatus.fromCode(row.status),
                    attempts: row.attempts,
                    lastError: row.lastError,
                    createdAt: row.createdAt,
                    syncedAt: row.syncedAt,
                  ),
                )
                .toList();
        return SuccessState(data: models);
      });

  @override
  FutureBool markItemSyncing(String id) => ErrorHandler.execute(() async {
    final count =
        await (_database.update(_database.syncAuditLogs)
              ..where((t) => t.id.equals(id)))
            .write(
              SyncAuditLogsCompanion(
                status: Value(SyncStatus.syncing.code),
                attempts: Value(
                  await _getAttempts(id) + 1,
                ),
              ),
            );
    return SuccessState(data: count > 0);
  });

  @override
  FutureBool markItemFailed(String id, String error) =>
      ErrorHandler.execute(() async {
        final count =
            await (_database.update(_database.syncAuditLogs)
                  ..where((t) => t.id.equals(id)))
                .write(
                  SyncAuditLogsCompanion(
                    status: Value(SyncStatus.failed.code),
                    lastError: Value(error),
                  ),
                );
        return SuccessState(data: count > 0);
      });

  @override
  FutureBool markItemDeadLetter(String id, String error) =>
      ErrorHandler.execute(() async {
        final count =
            await (_database.update(_database.syncAuditLogs)
                  ..where((t) => t.id.equals(id)))
                .write(
                  SyncAuditLogsCompanion(
                    status: Value(SyncStatus.deadLetter.code),
                    lastError: Value(error),
                  ),
                );
        return SuccessState(data: count > 0);
      });

  @override
  FutureVoid cancelPendingForEntity(String entityId, String reason) =>
      ErrorHandler.execute(() async {
        await (_database.update(_database.syncAuditLogs)
              ..where(
                (t) =>
                    (t.status.equals(SyncStatus.pending.code) |
                        t.status.equals(SyncStatus.syncing.code) |
                        t.status.equals(SyncStatus.failed.code)) &
                    (t.entityId.equals(entityId) |
                        t.payload.like('%$entityId%')),
              ))
            .write(
              SyncAuditLogsCompanion(
                status: Value(SyncStatus.deadLetter.code),
                lastError: Value(reason),
              ),
            );
        return SuccessState.nil;
      });

  @override
  Stream<List<SyncQueueItemModel>> watchDeadLetterItemsForEntity(
    String entityId,
  ) {
    final query =
        _database.select(_database.syncAuditLogs)
          ..where(
            (t) =>
                t.status.equals(SyncStatus.deadLetter.code) &
                (t.entityId.equals(entityId) | t.payload.like('%$entityId%')),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);

    return query.watch().map(
      (rows) =>
          rows
              .map(
                (row) => SyncQueueItemModel(
                  id: row.id,
                  companyId: row.companyId,
                  userProfileId: row.userProfileId,
                  entityType: SyncEntityType.fromCode(row.entityType),
                  entityId: row.entityId,
                  operation: SyncOperationType.fromCode(row.operation),
                  payload: row.payload,
                  status: SyncStatus.fromCode(row.status),
                  attempts: row.attempts,
                  lastError: row.lastError,
                  createdAt: row.createdAt,
                  syncedAt: row.syncedAt,
                ),
              )
              .toList(),
    );
  }

  @override
  FutureBool retryDeadLetterForEntity(String entityId) =>
      ErrorHandler.execute(() async {
        final count =
            await (_database.update(_database.syncAuditLogs)
                  ..where(
                    (t) =>
                        t.status.equals(SyncStatus.deadLetter.code) &
                        (t.entityId.equals(entityId) |
                            t.payload.like('%$entityId%')),
                  ))
                .write(
                  SyncAuditLogsCompanion(
                    status: Value(SyncStatus.pending.code),
                    attempts: const Value(0),
                    lastError: const Value(null),
                  ),
                );
        return SuccessState(data: count > 0);
      });

  @override
  FutureBool removeQueueItem(String id) => ErrorHandler.execute(() async {
    final count =
        await (_database.delete(
          _database.syncAuditLogs,
        )..where((t) => t.id.equals(id))).go();
    return SuccessState(data: count > 0);
  });

  @override
  FutureData<int> getPendingCount() => ErrorHandler.execute(() async {
    final countExp = _database.syncAuditLogs.id.count();
    final query =
        _database.selectOnly(_database.syncAuditLogs)
          ..addColumns([countExp])
          ..where(
            (_database.syncAuditLogs.status.equals(SyncStatus.pending.code) |
                    _database.syncAuditLogs.status.equals(
                      SyncStatus.syncing.code,
                    ) |
                    _database.syncAuditLogs.status.equals(
                      SyncStatus.failed.code,
                    )) &
                _database.syncAuditLogs.attempts.isSmallerThanValue(3),
          );

    final result = await query.map((row) => row.read(countExp)).getSingle();
    return SuccessState(data: result ?? 0);
  });

  @override
  Stream<int> watchPendingCount() {
    final countExp = _database.syncAuditLogs.id.count();
    final query =
        _database.selectOnly(_database.syncAuditLogs)
          ..addColumns([countExp])
          ..where(
            (_database.syncAuditLogs.status.equals(SyncStatus.pending.code) |
                    _database.syncAuditLogs.status.equals(
                      SyncStatus.syncing.code,
                    ) |
                    _database.syncAuditLogs.status.equals(
                      SyncStatus.failed.code,
                    )) &
                _database.syncAuditLogs.attempts.isSmallerThanValue(3),
          );

    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  Future<int> _getAttempts(String id) async {
    final query =
        _database.select(_database.syncAuditLogs)..where((t) => t.id.equals(id));
    final item = await query.getSingleOrNull();
    return item?.attempts ?? 0;
  }
}
