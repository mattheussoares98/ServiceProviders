import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/repositories/sla_repository.dart';

@LazySingleton()
class CreateSlaPolicyUseCase implements UseCase<bool, SlaPolicyEntity> {
  CreateSlaPolicyUseCase({required SlaRepository slaRepository})
      : _slaRepository = slaRepository;

  final SlaRepository _slaRepository;

  @override
  FutureBool call(SlaPolicyEntity request) =>
      _slaRepository.createSlaPolicy(request);
}
