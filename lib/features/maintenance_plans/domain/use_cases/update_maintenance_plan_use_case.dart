import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';

@LazySingleton()
class UpdateMaintenancePlanUseCase
    implements UseCase<bool, MaintenancePlanEntity> {
  const UpdateMaintenancePlanUseCase({
    required MaintenancePlansRepository repository,
  }) : _repository = repository;

  final MaintenancePlansRepository _repository;

  @override
  FutureBool call(MaintenancePlanEntity plan) =>
      _repository.updateMaintenancePlan(plan);
}
