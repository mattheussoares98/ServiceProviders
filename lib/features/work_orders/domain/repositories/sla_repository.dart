import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/sla_policy_entity.dart';

abstract interface class SlaRepository {
  FutureList<SlaPolicyEntity> getSlaPolicies(String companyId);
  FutureData<SlaPolicyEntity> getSlaPolicyById(String id);
  FutureBool createSlaPolicy(SlaPolicyEntity policy);
  FutureBool updateSlaPolicy(SlaPolicyEntity policy);
  FutureBool deleteSlaPolicy(String id);
}
