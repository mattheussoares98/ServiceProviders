import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/extensions.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/frequency.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_applies_to.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/extensions/sla_applies_to_ui_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_change_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_entity_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_log_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/work_order_change_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';

extension AuditChangeUiExtension on AuditChangeEntity {
  bool get isDisplayable {
    const ignoredFields = {
      'completed_at',
      'started_at',
      'deleted_at',
      'updated_at',
      'created_at',
      'reviewed_at',
      'paused_at',
      'resumed_at',
    };
    return !ignoredFields.contains(field);
  }

  String get localizedLabel {
    return switch (field) {
      'status' => 'Status'.hardcoded,
      'priority' => 'Prioridade'.hardcoded,
      'type' => 'Tipo'.hardcoded,
      'title' => 'Título'.hardcoded,
      'description' => 'Descrição'.hardcoded,
      'name' => 'Nome'.hardcoded,
      'email' => 'E-mail'.hardcoded,
      'phone' => 'Telefone'.hardcoded,
      'notes' => 'Observações'.hardcoded,
      'reason' => 'Motivo'.hardcoded,
      'event_type' => 'Tipo de evento'.hardcoded,
      'review_observation' => 'Observação de revisão'.hardcoded,
      'frequency' => 'Frequência'.hardcoded,
      'criticality' => 'Criticidade'.hardcoded,
      'location_id' => 'Localização'.hardcoded,
      'area_id' => 'Área'.hardcoded,
      'asset_id' => 'Ativo'.hardcoded,
      'category_id' => 'Categoria'.hardcoded,
      'assigned_to_id' => 'Responsável'.hardcoded,
      'created_by_id' => 'Criado por'.hardcoded,
      'requested_by_id' => 'Solicitado por'.hardcoded,
      'reviewed_by_id' => 'Revisado por'.hardcoded,
      'service_provider_company_id' => 'Empresa prestadora'.hardcoded,
      'estimated_duration_minutes' => 'Duração estimada (min)'.hardcoded,
      'is_required' => 'Obrigatório'.hardcoded,
      'is_active' => 'Ativo'.hardcoded,
      'requires_approval' => 'Requer aprovação'.hardcoded,
      'deleted_at' => 'Exclusão'.hardcoded,
      'started_at' => 'Iniciado em'.hardcoded,
      'completed_at' => 'Concluído em'.hardcoded,
      'due_date' => 'Data limite'.hardcoded,
      'scheduled_date' => 'Data agendada'.hardcoded,
      'file_type' => 'Tipo de arquivo'.hardcoded,
      'file_name' => 'Nome do arquivo'.hardcoded,
      'file_size_bytes' => 'Tamanho do arquivo'.hardcoded,
      _ => label ?? field,
    };
  }

  String? formatValue(String? rawValue) {
    if (rawValue == null) return null;

    final dateTime = DateTime.tryParse(rawValue);
    if (dateTime != null) return dateTime.formatDate(.ddMMyyyyHHmm);

    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return rawValue;

    // Handle boolean strings
    if (trimmed.toLowerCase() == 'true') return 'Sim'.hardcoded;
    if (trimmed.toLowerCase() == 'false') return 'Não'.hardcoded;

    return switch (field) {
      'status' => _formatStatus(trimmed),
      'priority' => Priority.fromCode(trimmed).label,
      'criticality' => AssetCriticality.fromCode(trimmed).label,
      'type' => _formatType(trimmed),
      'frequency' => _formatFrequency(trimmed),
      'applies_to' => SlaAppliesTo.fromValue(trimmed).label,
      'responsibility' => PauseResponsibility.fromValue(trimmed).label,
      'event_type' => _formatEventType(trimmed),
      'file_type' => _formatFileType(trimmed),
      'change_type' => _formatChangeType(trimmed),
      'is_required' || 'is_active' || 'requires_approval' =>
        trimmed == 'true' ? 'Sim'.hardcoded : 'Não'.hardcoded,
      _ => rawValue,
    };
  }

  String _formatStatus(String code) {
    if (entityType?.code == 'assets') {
      return AssetStatus.fromCode(code).label;
    }
    if (entityType?.code == 'work_order_pause_requests') {
      return PauseRequestStatus.fromValue(code).label;
    }
    if (entityType?.code == 'work_order_change_requests') {
      return switch (ChangeRequestStatus.fromCode(code)) {
        ChangeRequestStatus.pending => 'Pendente'.hardcoded,
        ChangeRequestStatus.approved => 'Aprovado'.hardcoded,
        ChangeRequestStatus.rejected => 'Rejeitado'.hardcoded,
      };
    }
    return WorkOrderStatus.fromCode(code).label;
  }

  String _formatType(String code) {
    if (entityType?.code == 'checklist_items') {
      return switch (ChecklistItemType.fromCode(code)) {
        ChecklistItemType.boolean => 'Verificação (Sim/Não)'.hardcoded,
        ChecklistItemType.text => 'Texto'.hardcoded,
        ChecklistItemType.number => 'Numérico'.hardcoded,
        ChecklistItemType.photo => 'Foto'.hardcoded,
        ChecklistItemType.selection => 'Seleção múltipla'.hardcoded,
      };
    }
    return WorkOrderType.fromCode(code).label;
  }

  String _formatFrequency(String code) => switch (Frequency.fromCode(code)) {
    Frequency.daily => 'Diária'.hardcoded,
    Frequency.weekly => 'Semanal'.hardcoded,
    Frequency.biweekly => 'Quinzenal'.hardcoded,
    Frequency.monthly => 'Mensal'.hardcoded,
    Frequency.quarterly => 'Trimestral'.hardcoded,
    Frequency.semiannual => 'Semestral'.hardcoded,
    Frequency.annual => 'Anual'.hardcoded,
  };

  String _formatEventType(String code) =>
      switch (PauseEventType.fromValue(code)) {
        PauseEventType.pause => 'Pausa'.hardcoded,
        PauseEventType.completion => 'Conclusão'.hardcoded,
      };

  String _formatFileType(String code) => switch (FileType.fromCode(code)) {
    FileType.image => 'Imagem'.hardcoded,
    FileType.video => 'Vídeo'.hardcoded,
    FileType.pdf => 'PDF'.hardcoded,
    FileType.document => 'Documento'.hardcoded,
    FileType.spreadsheet => 'Planilha'.hardcoded,
    FileType.signature => 'Assinatura'.hardcoded,
  };

  String _formatChangeType(String code) =>
      switch (WorkOrderChangeType.fromCode(code)) {
        WorkOrderChangeType.addTask => 'Adicionar tarefa'.hardcoded,
        WorkOrderChangeType.addAttachment => 'Adicionar anexo'.hardcoded,
        WorkOrderChangeType.updateNotes => 'Atualizar notas'.hardcoded,
        WorkOrderChangeType.fillChecklist => 'Preencher checklist'.hardcoded,
      };

  String? get localizedOldValue => formatValue(oldDisplay ?? oldValue);
  String? get localizedNewValue => formatValue(newDisplay ?? newValue);
}

extension AuditEntityTypeUiExtension on AuditEntityType {
  String get label => switch (this) {
    AuditEntityType.companies => 'Empresas'.hardcoded,
    AuditEntityType.companyParameters => 'Parâmetros da empresa'.hardcoded,
    AuditEntityType.locations => 'Localizações'.hardcoded,
    AuditEntityType.areas => 'Áreas'.hardcoded,
    AuditEntityType.categories => 'Categorias'.hardcoded,
    AuditEntityType.assets => 'Ativos'.hardcoded,
    AuditEntityType.checklistTemplates => 'Modelos de checklist'.hardcoded,
    AuditEntityType.checklistItems => 'Itens de checklist'.hardcoded,
    AuditEntityType.maintenancePlans => 'Planos de manutenção'.hardcoded,
    AuditEntityType.workOrders => 'Ordens de serviço'.hardcoded,
    AuditEntityType.tasks => 'Tarefas'.hardcoded,
    AuditEntityType.workOrderChangeRequests =>
      'Solicitações de alteração'.hardcoded,
    AuditEntityType.workOrderObservations => 'Observações da OS'.hardcoded,
    AuditEntityType.attachments => 'Anexos'.hardcoded,
    AuditEntityType.workOrderPauseRequests => 'Solicitações de pausa'.hardcoded,
    AuditEntityType.userProfiles => 'Perfis de usuário'.hardcoded,
    AuditEntityType.permissionGroups => 'Grupos de permissão'.hardcoded,
    AuditEntityType.slaPolicies => 'Políticas de SLA'.hardcoded,
    AuditEntityType.sectors => 'Setores'.hardcoded,
    AuditEntityType.pauseReasons => 'Motivos de pausa'.hardcoded,
    AuditEntityType.serviceProviderCompanies =>
      'Empresas prestadoras'.hardcoded,
    AuditEntityType.serviceProviderProfiles =>
      'Perfis de prestadores'.hardcoded,
    AuditEntityType.unknown => 'Registro'.hardcoded,
  };
}

extension AuditLogUiExtension on AuditLogEntity {
  String get displayTitle {
    if (summary != null && summary!.trim().isNotEmpty) {
      return summary!;
    }
    final entityLabel = entityType.label;
    return switch (action) {
      'created' => 'Criação - ${entityLabel.toUpperCase()}'.hardcoded,
      'deleted' => 'Exclusão - ${entityLabel.toUpperCase()}'.hardcoded,
      'restored' => 'Restauração - ${entityLabel.toUpperCase()}'.hardcoded,
      'updated' => 'Alteração - ${entityLabel.toUpperCase()}'.hardcoded,
      _ => action.hardcoded,
    };
  }
}
