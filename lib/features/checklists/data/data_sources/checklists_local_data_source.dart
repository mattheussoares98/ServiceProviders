import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_answer_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_item_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_template_model.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';

abstract interface class ChecklistsLocalDataSource {
  // Templates
  FutureList<ChecklistTemplateModel> getTemplates(String companyId);
  FutureData<ChecklistTemplateModel> getTemplateById(String id);
  FutureBool saveTemplate(ChecklistTemplateModel template);
  FutureBool deleteTemplate(String id);

  // Items
  FutureList<ChecklistItemModel> getItemsByTemplate(String templateId);
  FutureBool saveItem(ChecklistItemModel item);
  FutureBool deleteItem(String id);

  // Execution Responses
  FutureList<ChecklistAnswerModel> getResponsesByWorkOrder(String workOrderId);
  FutureBool saveResponse(ChecklistAnswerModel response);
}

@LazySingleton(as: ChecklistsLocalDataSource)
final class ChecklistsLocalDataSourceImpl implements ChecklistsLocalDataSource {
  const ChecklistsLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  // ============================================
  // Templates
  // ============================================

  @override
  FutureList<ChecklistTemplateModel> getTemplates(String companyId) {
    return ErrorHandler.execute(() async {
      final list =
          await (_database.select(_database.checklistTemplates)..where(
                (t) => t.companyId.equals(companyId) & t.deletedAt.isNull(),
              ))
              .get();

      return SuccessState(
        data: list
            .map(
              (t) => ChecklistTemplateModel(
                id: t.id,
                companyId: t.companyId,
                name: t.name,
                description: t.description,
                categoryId: t.categoryId,
                createdAt: t.createdAt.toUtc(),
                updatedAt: t.updatedAt.toUtc(),
                deletedAt: t.deletedAt?.toUtc(),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  FutureData<ChecklistTemplateModel> getTemplateById(String id) {
    return ErrorHandler.execute(() async {
      final item =
          await (_database.select(_database.checklistTemplates)
                ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
              .getSingleOrNull();

      if (item == null) {
        return FailureState(
          message: 'Template de checklist não encontrado'.hardcoded,
        );
      }

      return SuccessState(
        data: ChecklistTemplateModel(
          id: item.id,
          companyId: item.companyId,
          name: item.name,
          description: item.description,
          categoryId: item.categoryId,
          createdAt: item.createdAt.toUtc(),
          updatedAt: item.updatedAt.toUtc(),
          deletedAt: item.deletedAt?.toUtc(),
        ),
      );
    });
  }

  @override
  FutureBool saveTemplate(ChecklistTemplateModel template) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.checklistTemplates)
          .insertOnConflictUpdate(
            ChecklistTemplatesCompanion(
              id: Value(template.id),
              companyId: Value(template.companyId),
              name: Value(template.name),
              description: Value(template.description),
              categoryId: Value(template.categoryId),
              createdAt: Value(template.createdAt),
              updatedAt: Value(template.updatedAt),
              deletedAt: Value(template.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteTemplate(String id) {
    return ErrorHandler.execute(() async {
      await (_database.update(_database.checklistTemplates)
            ..where((t) => t.id.equals(id)))
          .write(ChecklistTemplatesCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }

  // ============================================
  // Items
  // ============================================

  @override
  FutureList<ChecklistItemModel> getItemsByTemplate(String templateId) {
    return ErrorHandler.execute(() async {
      final list =
          await (_database.select(_database.checklistItems)..where(
                (t) => t.templateId.equals(templateId) & t.deletedAt.isNull(),
              ))
              .get();

      return SuccessState(
        data: list
            .map(
              (t) => ChecklistItemModel(
                id: t.id,
                templateId: t.templateId,
                companyId: t.companyId,
                label: t.label,
                type: ChecklistItemType.fromCode(t.type),
                isRequired: t.isRequired,
                options: t.options != null
                    ? (jsonDecode(t.options!) as List)
                          .map((e) => e.toString())
                          .toList()
                    : null,
                sortOrder: t.sortOrder,
                createdAt: t.createdAt.toUtc(),
                deletedAt: t.deletedAt?.toUtc(),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  FutureBool saveItem(ChecklistItemModel item) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.checklistItems)
          .insertOnConflictUpdate(
            ChecklistItemsCompanion(
              id: Value(item.id),
              templateId: Value(item.templateId),
              companyId: Value(item.companyId),
              label: Value(item.label),
              type: Value(item.type.code),
              isRequired: Value(item.isRequired),
              options: Value(
                item.options != null ? jsonEncode(item.options) : null,
              ),
              sortOrder: Value(item.sortOrder),
              createdAt: Value(item.createdAt),
              deletedAt: Value(item.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteItem(String id) {
    return ErrorHandler.execute(() async {
      await (_database.update(_database.checklistItems)
            ..where((t) => t.id.equals(id)))
          .write(ChecklistItemsCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }

  // ============================================
  // Execution Responses
  // ============================================

  @override
  FutureList<ChecklistAnswerModel> getResponsesByWorkOrder(String workOrderId) {
    return ErrorHandler.execute(() async {
      final list = await (_database.select(
        _database.tasks,
      )..where((t) => t.workOrderId.equals(workOrderId))).get();

      return SuccessState(
        data: list
            .map(
              (t) => ChecklistAnswerModel(
                id: t.id,
                workOrderId: t.workOrderId,
                checklistItemId: t.title,
                booleanValue: t.isCompleted,
                createdAt: t.createdAt,
                updatedAt: t.updatedAt,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  FutureBool saveResponse(ChecklistAnswerModel response) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.tasks)
          .insertOnConflictUpdate(
            TasksCompanion(
              id: Value(response.id),
              workOrderId: Value(response.workOrderId),
              title: Value(response.checklistItemId),
              isCompleted: Value(response.booleanValue ?? false),
              createdAt: Value(response.createdAt),
              updatedAt: Value(response.updatedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }
}
