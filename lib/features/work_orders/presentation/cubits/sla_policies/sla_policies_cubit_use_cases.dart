import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_sla_policies_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_sla_policy_by_id_use_case.dart';

@LazySingleton()
class SlaPoliciesCubitUseCases {
  const SlaPoliciesCubitUseCases({
    required this.getSessionUser,
    required this.getSlaPolicies,
    required this.getSlaPolicyById,
    required this.createSlaPolicy,
  });

  final GetSessionUserUseCase getSessionUser;
  final GetSlaPoliciesUseCase getSlaPolicies;
  final GetSlaPolicyByIdUseCase getSlaPolicyById;
  final CreateSlaPolicyUseCase createSlaPolicy;
}
