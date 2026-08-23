import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sync/data/data_sources/sync_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sync/data/data_sources/sync_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sync/data/models/sync_error_model.dart';
import 'package:o_jogo_da_obra/features/sync/data/models/sync_queue_item_model.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_error_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/repositories/sync_repository.dart';

@LazySingleton(as: SyncRepository)
final class SyncRepositoryImpl implements SyncRepository {
  const SyncRepositoryImpl({
    required InternetClient internet,
    required SyncLocalDataSource localDataSource,
    required SyncRemoteDataSource remoteDataSource,
  }) : _internet = internet,
       _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  final InternetClient _internet;
  final SyncLocalDataSource _localDataSource;
  final SyncRemoteDataSource _remoteDataSource;

  @override
  FutureBool enqueue(SyncQueueItemEntity item) =>
      _localDataSource.enqueue(SyncQueueItemModel.fromEntity(item));

  @override
  FutureList<SyncQueueItemEntity> getPendingItems({int limit = 50}) =>
      RepositoryHandler.fetchFromLocalAndMapList<
        SyncQueueItemModel,
        SyncQueueItemEntity
      >(localCallback: () => _localDataSource.getPendingItems(limit: limit));

  @override
  FutureBool markItemSyncing(String id) =>
      _localDataSource.markItemSyncing(id);

  @override
  FutureBool markItemFailed(String id, String error) =>
      _localDataSource.markItemFailed(id, error);

  @override
  FutureBool removeQueueItem(String id) =>
      _localDataSource.removeQueueItem(id);

  @override
  FutureData<int> getPendingCount() => _localDataSource.getPendingCount();

  @override
  FutureBool reportSyncError(SyncErrorEntity error) {
    if (!_internet.isConnected) {
      return Future.value(FailureState.noInternet());
    }
    return _remoteDataSource.reportSyncError(
      SyncErrorModel.fromEntity(error),
    );
  }
}
