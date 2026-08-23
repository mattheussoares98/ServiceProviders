import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sync/domain/repositories/sync_repository.dart';

@LazySingleton()
class GetPendingSyncCountUseCase implements UseCaseNoParameter<int> {
  const GetPendingSyncCountUseCase({required SyncRepository repository})
    : _repository = repository;

  final SyncRepository _repository;

  @override
  FutureData<int> call() => _repository.getPendingCount();
}
