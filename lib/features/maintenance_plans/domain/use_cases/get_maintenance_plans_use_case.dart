import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetMaintenancePlansUseCase
    implements UseCase<List<MaintenancePlanEntity>, String> {
  GetMaintenancePlansUseCase(
      {required MaintenancePlansRepository maintenancePlansRepository})
      : _maintenancePlansRepository = maintenancePlansRepository;

  final MaintenancePlansRepository _maintenancePlansRepository;

  @override
  FutureList<MaintenancePlanEntity> call(String request) =>
      _maintenancePlansRepository.getMaintenancePlans(request);
}
