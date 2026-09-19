import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/calculate_next_due_date_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/create_maintenance_plan_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/delete_maintenance_plan_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/generate_maintenance_plan_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/get_maintenance_plan_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/get_maintenance_plans_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/update_maintenance_plan_use_case.dart';

@LazySingleton()
class MaintenancePlansCubitUseCases {
  const MaintenancePlansCubitUseCases({
    required this.getActiveCompanyId,
    required this.getMaintenancePlans,
    required this.getMaintenancePlanById,
    required this.createMaintenancePlan,
    required this.updateMaintenancePlan,
    required this.deleteMaintenancePlan,
    required this.calculateNextDueDate,
    required this.generateMaintenancePlanWorkOrder,
  });

  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetMaintenancePlansUseCase getMaintenancePlans;
  final GetMaintenancePlanByIdUseCase getMaintenancePlanById;
  final CreateMaintenancePlanUseCase createMaintenancePlan;
  final UpdateMaintenancePlanUseCase updateMaintenancePlan;
  final DeleteMaintenancePlanUseCase deleteMaintenancePlan;
  final CalculateNextDueDateUseCase calculateNextDueDate;
  final GenerateMaintenancePlanWorkOrderUseCase
  generateMaintenancePlanWorkOrder;
}
