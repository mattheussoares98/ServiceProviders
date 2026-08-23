import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_error_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';

abstract interface class SyncRepository {
  FutureBool enqueue(SyncQueueItemEntity item);
  FutureList<SyncQueueItemEntity> getPendingItems({int limit = 50});
  FutureBool markItemSyncing(String id);
  FutureBool markItemFailed(String id, String error);
  FutureBool markItemDeadLetter(String id, String error);
  FutureVoid cancelPendingForEntity(String entityId, String reason);
  FutureBool removeQueueItem(String id);
  FutureData<int> getPendingCount();
  FutureBool reportSyncError(SyncErrorEntity error);
}
