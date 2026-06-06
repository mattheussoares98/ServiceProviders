import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';

abstract interface class MaintenancePlansRepository {
  FutureList<MaintenancePlanEntity> getMaintenancePlans(String companyId);
  FutureData<MaintenancePlanEntity> getMaintenancePlanById(String id);
  FutureBool createMaintenancePlan(MaintenancePlanEntity plan);
  FutureBool updateMaintenancePlan(MaintenancePlanEntity plan);
  FutureBool deleteMaintenancePlan(String id);
}