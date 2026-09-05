import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_order.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_answer_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_item_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_template_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ChecklistsRemoteDataSource {
  // Templates
  FutureList<ChecklistTemplateModel> getTemplates(String companyId);
  FutureData<ChecklistTemplateModel> getTemplateById(String id);
  FutureBool createTemplate(ChecklistTemplateModel template);
  FutureBool updateTemplate(ChecklistTemplateModel template);
  FutureVoid deleteTemplate(String id);
  Stream<RealtimeEvent<ChecklistTemplateModel>>
  watchChecklistTemplatesRealtime({String? companyId});

  // Items
  FutureList<ChecklistItemModel> getItemsByTemplate(String templateId);
  FutureBool createItem(ChecklistItemModel item);
  FutureBool updateItem(ChecklistItemModel item);
  FutureVoid deleteItem(String id);
  Stream<RealtimeEvent<ChecklistItemModel>> watchChecklistItemsRealtime({
    String? companyId,
  });

  // Execution Responses / Tasks
  FutureList<ChecklistAnswerModel> getResponsesByWorkOrder(String workOrderId);
  FutureBool saveResponse(ChecklistAnswerModel response);
}

@LazySingleton(as: ChecklistsRemoteDataSource)
final class ChecklistsRemoteDataSourceImpl
    implements ChecklistsRemoteDataSource {
  const ChecklistsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
    required SupabaseRealtimeClient realtimeClient,
  }) : _database = database,
       _realtimeClient = realtimeClient;

  final SupabaseDatabaseClient _database;
  final SupabaseRealtimeClient _realtimeClient;

  // ============================================
  // Templates
  // ============================================

  @override
  FutureList<ChecklistTemplateModel> getTemplates(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'checklist_templates',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
          orderBy: [const SupabaseOrder(column: 'name', ascending: true)],
        );
        return response.map(ChecklistTemplateModel.fromJson).toList();
      });

  @override
  FutureData<ChecklistTemplateModel> getTemplateById(String id) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectOne(
          table: 'checklist_templates',
          filters: [
            SupabaseFilter.eq('id', id),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        if (response == null) {
          throw Exception('Template de checklist não encontrado'.hardcoded);
        }
        return ChecklistTemplateModel.fromJson(response);
      });

  @override
  FutureBool createTemplate(ChecklistTemplateModel template) =>
      SupabaseHandler.call(() async {
        await _database.insert(
          table: 'checklist_templates',
          values: template.toJson(),
        );
        return true;
      });

  @override
  FutureBool updateTemplate(ChecklistTemplateModel template) =>
      SupabaseHandler.call(() async {
        await _database.update(
          table: 'checklist_templates',
          values: template.toJson(),
          filters: [SupabaseFilter.eq('id', template.id)],
        );
        return true;
      });

  @override
  FutureVoid deleteTemplate(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'checklist_templates',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  Stream<RealtimeEvent<ChecklistTemplateModel>>
  watchChecklistTemplatesRealtime({String? companyId}) {
    final filter = companyId != null && companyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          )
        : null;

    return _realtimeClient
        .streamTableChanges(table: 'checklist_templates', filter: filter)
        .map(
          (payload) => RealtimePayloadMapper.map(
            payload,
            ChecklistTemplateModel.fromJson,
          ),
        );
  }

  // ============================================
  // Items
  // ============================================

  @override
  FutureList<ChecklistItemModel> getItemsByTemplate(String templateId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'checklist_items',
          filters: [
            SupabaseFilter.eq('template_id', templateId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
          orderBy: [const SupabaseOrder(column: 'sort_order', ascending: true)],
        );
        return response.map(ChecklistItemModel.fromJson).toList();
      });

  @override
  FutureBool createItem(ChecklistItemModel item) =>
      SupabaseHandler.call(() async {
        await _database.insert(table: 'checklist_items', values: item.toJson());
        return true;
      });

  @override
  FutureBool updateItem(ChecklistItemModel item) =>
      SupabaseHandler.call(() async {
        await _database.update(
          table: 'checklist_items',
          values: item.toJson(),
          filters: [SupabaseFilter.eq('id', item.id)],
        );
        return true;
      });

  @override
  FutureVoid deleteItem(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'checklist_items',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  Stream<RealtimeEvent<ChecklistItemModel>> watchChecklistItemsRealtime({
    String? companyId,
  }) {
    final filter = companyId != null && companyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          )
        : null;

    return _realtimeClient
        .streamTableChanges(table: 'checklist_items', filter: filter)
        .map(
          (payload) =>
              RealtimePayloadMapper.map(payload, ChecklistItemModel.fromJson),
        );
  }

  // ============================================
  // Execution Responses / Tasks
  // ============================================

  @override
  FutureList<ChecklistAnswerModel> getResponsesByWorkOrder(
    String workOrderId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'tasks',
      filters: [
        SupabaseFilter.eq('work_order_id', workOrderId),
        SupabaseFilter.isFilter('deleted_at', null),
      ],
    );
    return response.map(ChecklistAnswerModel.fromJson).toList();
  });

  @override
  FutureBool saveResponse(ChecklistAnswerModel response) =>
      SupabaseHandler.call(() async {
        await _database.upsert(table: 'tasks', values: response.toJson());
        return true;
      });
}
