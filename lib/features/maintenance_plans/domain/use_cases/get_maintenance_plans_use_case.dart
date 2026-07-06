import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';

@LazySingleton()
class GetMaintenancePlansUseCase
    implements UseCase<List<MaintenancePlanEntity>, String> {
  GetMaintenancePlansUseCase({
    required MaintenancePlansRepository maintenancePlansRepository,
  }) : _maintenancePlansRepository = maintenancePlansRepository;

  final MaintenancePlansRepository _maintenancePlansRepository;

  @override
  FutureList<MaintenancePlanEntity> call(String request) =>
      _maintenancePlansRepository.getMaintenancePlans(request);
}
