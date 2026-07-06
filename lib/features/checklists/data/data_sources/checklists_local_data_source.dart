import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_item_response_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_template_response_model.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';

abstract interface class ChecklistsLocalDataSource {
  // Templates
  FutureList<ChecklistTemplateResponseModel> getTemplates(String companyId);
  FutureData<ChecklistTemplateResponseModel> getTemplateById(String id);
  FutureBool saveTemplate(ChecklistTemplateResponseModel template);
  FutureBool deleteTemplate(String id);

  // Items
  FutureList<ChecklistItemResponseModel> getItemsByTemplate(String templateId);
  FutureBool saveItem(ChecklistItemResponseModel item);
  FutureBool deleteItem(String id);
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
  FutureList<ChecklistTemplateResponseModel> getTemplates(String companyId) {
    return ErrorHandler.execute(() async {
      final list =
          await (_database.select(_database.checklistTemplates)..where(
                (t) => t.companyId.equals(companyId) & t.deletedAt.isNull(),
              ))
              .get();

      return SuccessState(
        data: list
            .map(
              (t) => ChecklistTemplateResponseModel(
                id: t.id,
                companyId: t.companyId,
                name: t.name,
                description: t.description,
                categoryId: t.categoryId,
                createdAt: t.createdAt,
                updatedAt: t.updatedAt,
                deletedAt: t.deletedAt,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  FutureData<ChecklistTemplateResponseModel> getTemplateById(String id) {
    return ErrorHandler.execute(() async {
      final t =
          await (_database.select(_database.checklistTemplates)
                ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
              .getSingleOrNull();

      if (t != null) {
        return SuccessState(
          data: ChecklistTemplateResponseModel(
            id: t.id,
            companyId: t.companyId,
            name: t.name,
            description: t.description,
            categoryId: t.categoryId,
            createdAt: t.createdAt,
            updatedAt: t.updatedAt,
            deletedAt: t.deletedAt,
          ),
        );
      }

      return FailureState<ChecklistTemplateResponseModel>(
        message: 'Checklist template not found'.hardcoded,
      );
    });
  }

  @override
  FutureBool saveTemplate(ChecklistTemplateResponseModel template) {
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
      final now = DateTime.now();

      // Soft delete template
      await (_database.update(_database.checklistTemplates)
            ..where((t) => t.id.equals(id)))
          .write(ChecklistTemplatesCompanion(deletedAt: Value(now)));

      // Soft delete linked items
      await (_database.update(_database.checklistItems)
            ..where((t) => t.templateId.equals(id)))
          .write(ChecklistItemsCompanion(deletedAt: Value(now)));

      return const SuccessState(data: true);
    });
  }

  // ============================================
  // Items
  // ============================================

  @override
  FutureList<ChecklistItemResponseModel> getItemsByTemplate(String templateId) {
    return ErrorHandler.execute(() async {
      final list =
          await (_database.select(_database.checklistItems)
                ..where(
                  (t) => t.templateId.equals(templateId) & t.deletedAt.isNull(),
                )
                ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
              .get();

      return SuccessState(
        data: list
            .map(
              (item) => ChecklistItemResponseModel(
                id: item.id,
                templateId: item.templateId,
                companyId: item.companyId,
                label: item.label,
                type: ChecklistItemType.fromCode(item.type),
                isRequired: item.isRequired,
                options: item.options != null
                    ? (jsonDecode(item.options!) as List)
                          .map((e) => e.toString())
                          .toList()
                    : null,
                sortOrder: item.sortOrder,
                createdAt: item.createdAt,
                deletedAt: item.deletedAt,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  FutureBool saveItem(ChecklistItemResponseModel item) {
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
}
