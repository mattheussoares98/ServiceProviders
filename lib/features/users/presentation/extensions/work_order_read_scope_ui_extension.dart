import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_read_scope.dart';

extension WorkOrderReadScopeUiExtension on WorkOrderReadScope {
  String get label => switch (this) {
    WorkOrderReadScope.all => 'Todos'.hardcoded,
    WorkOrderReadScope.assigned => 'Atribuídos'.hardcoded,
  };
}
