import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';

@LazySingleton()
class GenerateMaintenancePlanWorkOrderUseCase
    implements UseCase<String, String> {
  GenerateMaintenancePlanWorkOrderUseCase({
    required MaintenancePlansRepository maintenancePlansRepository,
  }) : _maintenancePlansRepository = maintenancePlansRepository;

  final MaintenancePlansRepository _maintenancePlansRepository;

  @override
  FutureData<String> call(String request) =>
      _maintenancePlansRepository.generateWorkOrder(request);
}
