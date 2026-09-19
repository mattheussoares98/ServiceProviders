import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/calculate_next_due_date_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/create_maintenance_plan_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/delete_maintenance_plan_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/generate_maintenance_plan_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/get_maintenance_plan_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/get_maintenance_plans_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/update_maintenance_plan_use_case.dart';

class MockGetMaintenancePlansUseCase extends Mock
    implements GetMaintenancePlansUseCase {}

class MockGetMaintenancePlanByIdUseCase extends Mock
    implements GetMaintenancePlanByIdUseCase {}

class MockCreateMaintenancePlanUseCase extends Mock
    implements CreateMaintenancePlanUseCase {}

class MockUpdateMaintenancePlanUseCase extends Mock
    implements UpdateMaintenancePlanUseCase {}

class MockDeleteMaintenancePlanUseCase extends Mock
    implements DeleteMaintenancePlanUseCase {}

class MockCalculateNextDueDateUseCase extends Mock
    implements CalculateNextDueDateUseCase {}

class MockGenerateMaintenancePlanWorkOrderUseCase extends Mock
    implements GenerateMaintenancePlanWorkOrderUseCase {}
