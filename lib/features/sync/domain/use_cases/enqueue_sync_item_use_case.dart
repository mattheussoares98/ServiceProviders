import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/repositories/sync_repository.dart';

@LazySingleton()
class EnqueueSyncItemUseCase implements UseCase<bool, SyncQueueItemEntity> {
  const EnqueueSyncItemUseCase({required SyncRepository repository})
    : _repository = repository;

  final SyncRepository _repository;

  @override
  FutureBool call(SyncQueueItemEntity request) => _repository.enqueue(request);
}
