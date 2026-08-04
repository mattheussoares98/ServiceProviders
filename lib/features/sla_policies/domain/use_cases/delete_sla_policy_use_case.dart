import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/repositories/sla_repository.dart';

@LazySingleton()
class DeleteSlaPolicyUseCase implements UseCase<bool, String> {
  DeleteSlaPolicyUseCase({required SlaRepository slaRepository})
      : _slaRepository = slaRepository;

  final SlaRepository _slaRepository;

  @override
  FutureBool call(String request) =>
      _slaRepository.deleteSlaPolicy(request);
}
