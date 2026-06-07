import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetMaintenancePlanByIdUseCase
    implements UseCase<MaintenancePlanEntity, String> {
  const GetMaintenancePlanByIdUseCase({
    required MaintenancePlansRepository repository,
  }) : _repository = repository;

  final MaintenancePlansRepository _repository;

  @override
  FutureData<MaintenancePlanEntity> call(String id) =>
      _repository.getMaintenancePlanById(id);
}
