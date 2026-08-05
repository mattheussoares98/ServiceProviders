import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/create_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/delete_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/get_sla_policies_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/get_sla_policy_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/use_cases/update_sla_policy_use_case.dart';

@LazySingleton()
class SlaPoliciesCubitUseCases {
  const SlaPoliciesCubitUseCases({
    required this.getActiveCompanyId,
    required this.getSlaPolicies,
    required this.getSlaPolicyById,
    required this.createSlaPolicy,
    required this.updateSlaPolicy,
    required this.deleteSlaPolicy,
  });

  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetSlaPoliciesUseCase getSlaPolicies;
  final GetSlaPolicyByIdUseCase getSlaPolicyById;
  final CreateSlaPolicyUseCase createSlaPolicy;
  final UpdateSlaPolicyUseCase updateSlaPolicy;
  final DeleteSlaPolicyUseCase deleteSlaPolicy;
}
