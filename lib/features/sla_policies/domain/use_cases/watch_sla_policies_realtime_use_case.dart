import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/repositories/sla_repository.dart';

@LazySingleton()
class WatchSlaPoliciesRealtimeUseCase {
  const WatchSlaPoliciesRealtimeUseCase({
    required SlaRepository slaRepository,
  }) : _slaRepository = slaRepository;

  final SlaRepository _slaRepository;

  Stream<RealtimeEvent<SlaPolicyEntity>> call({String? companyId}) =>
      _slaRepository.watchSlaPoliciesRealtime(companyId: companyId);
}
