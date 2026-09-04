import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_update_scope.dart';

extension WorkOrderUpdateScopeUiExtension on WorkOrderUpdateScope {
  String get label => switch (this) {
    WorkOrderUpdateScope.all => 'Todos'.hardcoded,
    WorkOrderUpdateScope.assigned => 'Atribuídos'.hardcoded,
    WorkOrderUpdateScope.own => 'Criados por mim'.hardcoded,
    WorkOrderUpdateScope.none => 'Nenhum'.hardcoded,
  };
}
