import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';

extension ResourceTypeUiExtension on ResourceType {
  String get label => switch (this) {
    ResourceType.assets => 'Ativos'.hardcoded,
    ResourceType.attachments => 'Anexos'.hardcoded,
    ResourceType.categories => 'Categorias'.hardcoded,
    ResourceType.locations => 'Locais'.hardcoded,
    ResourceType.sectors => 'Setores'.hardcoded,
    ResourceType.serviceProviders => 'Prestadores de serviço'.hardcoded,
    ResourceType.slaPolicies => 'Políticas de SLA'.hardcoded,
    ResourceType.users => 'Usuários'.hardcoded,
    ResourceType.workOrders => 'Ordens de serviço'.hardcoded,
    ResourceType.accessLogs => 'Logs de acesso'.hardcoded,
  };
}
