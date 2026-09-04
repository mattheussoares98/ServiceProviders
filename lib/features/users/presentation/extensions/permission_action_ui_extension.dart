import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';

extension PermissionActionUiExtension on PermissionAction {
  String get label => switch (this) {
    PermissionAction.create => 'Criar'.hardcoded,
    PermissionAction.read => 'Pesquisar'.hardcoded,
    PermissionAction.update => 'Alterar'.hardcoded,
    PermissionAction.delete => 'Excluir'.hardcoded,
  };
}
