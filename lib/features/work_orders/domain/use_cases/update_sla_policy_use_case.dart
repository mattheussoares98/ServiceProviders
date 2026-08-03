import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/sla_repository.dart';

@LazySingleton()
class UpdateSlaPolicyUseCase implements UseCase<bool, SlaPolicyEntity> {
  UpdateSlaPolicyUseCase({required SlaRepository slaRepository})
      : _slaRepository = slaRepository;

  final SlaRepository _slaRepository;

  @override
  FutureBool call(SlaPolicyEntity request) =>
      _slaRepository.updateSlaPolicy(request);
}
