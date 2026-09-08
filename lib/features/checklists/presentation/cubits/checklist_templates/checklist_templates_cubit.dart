import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:uuid/uuid.dart';

part 'checklist_templates_state.dart';

enum ChecklistTemplatesSections implements SectionKey {
  saveTemplate,
  deleteTemplate,
  loadItems,
  saveItem,
  deleteItem,
  reorderItems,
}

@injectable
class ChecklistTemplatesCubit extends BaseCubit<ChecklistTemplatesState> {
  ChecklistTemplatesCubit({required ChecklistTemplatesCubitUseCases useCases})
    : _useCases = useCases,
      super(const ChecklistTemplatesState.initial());

  final ChecklistTemplatesCubitUseCases _useCases;
  StreamSubscription<RealtimeEvent<ChecklistTemplateEntity>>?
  _templatesRealtimeSub;
  StreamSubscription<RealtimeEvent<ChecklistItemEntity>>? _itemsRealtimeSub;

  @override
  Future<void> close() {
    _templatesRealtimeSub?.cancel();
    _itemsRealtimeSub?.cancel();
    return super.close();
  }

  void subscribeToRealtime() {
    final companyId = _useCases.getActiveCompanyId();

    _templatesRealtimeSub?.cancel();
    _templatesRealtimeSub = _useCases
        .watchChecklistTemplatesRealtime(companyId: companyId)
        .listen((_) => loadTemplates(emitLoading: false));

    _itemsRealtimeSub?.cancel();
    _itemsRealtimeSub = _useCases
        .watchChecklistItemsRealtime(companyId: companyId)
        .listen((_) {
          if (state.selectedTemplate != null) {
            loadItemsByTemplate(state.selectedTemplate!.id, emitLoading: false);
          }
        });
  }

  Future<void> loadTemplates({bool emitLoading = true}) async {
    final companyId = _useCases.getActiveCompanyId();

    if (emitLoading) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    }

    final result = await _useCases.getChecklists(companyId);
    if (isClosed) return;

    if (result is SuccessState<List<ChecklistTemplateEntity>>) {
      emit(
        state.copyWith(
          templates: result.data ?? [],
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
    } else {
      final message =
          result.message ?? 'Erro ao carregar modelos de checklist'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
    }
  }

  Future<void> selectTemplate(ChecklistTemplateEntity? template) async {
    emit(
      state.copyWith(
        selectedTemplate: template,
        annulSelectedTemplate: template == null,
      ),
    );
    if (template != null) {
      await loadItemsByTemplate(template.id);
    } else {
      emit(state.copyWith(templateItems: const []));
    }
  }

  Future<void> loadItemsByTemplate(
    String templateId, {
    bool emitLoading = true,
  }) async {
    if (emitLoading) {
      emit(
        state.copyWith(
          sections: withSection(
            ChecklistTemplatesSections.loadItems,
            SectionStatus.running,
          ),
        ),
      );
    }

    final result = await _useCases.getChecklistItemsByTemplate(templateId);
    if (isClosed) return;

    if (result is SuccessState<List<ChecklistItemEntity>>) {
      emit(
        state.copyWith(
          templateItems: result.data ?? [],
          sections: withSection(
            ChecklistTemplatesSections.loadItems,
            SectionStatus.success,
          ),
        ),
      );
    } else {
      final message =
          result.message ?? 'Erro ao carregar itens do modelo'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            ChecklistTemplatesSections.loadItems,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
    }
  }

  Future<bool> saveTemplate({
    required String? id,
    required String name,
    String? description,
    String? categoryId,
    DateTime? createdAt,
  }) async {
    emit(
      state.copyWith(
        sections: withSection(
          ChecklistTemplatesSections.saveTemplate,
          SectionStatus.running,
        ),
      ),
    );

    final isUpdate = id != null;
    final now = DateTime.now();
    final companyId = _useCases.getActiveCompanyId();

    final template = ChecklistTemplateEntity(
      id: id ?? const Uuid().v4(),
      companyId: companyId,
      name: name.trim(),
      description: description?.trimToNull(),
      categoryId: categoryId,
      createdAt: createdAt ?? now,
      updatedAt: now,
      deletedAt: null,
    );

    final result = isUpdate
        ? await _useCases.updateChecklistTemplate(template)
        : await _useCases.createChecklistTemplate(template);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          selectedTemplate: template,
          sections: withSection(
            ChecklistTemplatesSections.saveTemplate,
            SectionStatus.success,
          ),
        ),
      );
      await loadTemplates(emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao salvar modelo de checklist'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            ChecklistTemplatesSections.saveTemplate,
            SectionStatus.error,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> deleteTemplate(String id) async {
    emit(
      state.copyWith(
        sections: withSection(
          ChecklistTemplatesSections.deleteTemplate,
          SectionStatus.running,
        ),
      ),
    );

    final result = await _useCases.deleteChecklistTemplate(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final updatedTemplates = state.templates
          .where((t) => t.id != id)
          .toList();
      emit(
        state.copyWith(
          templates: updatedTemplates,
          selectedTemplate: state.selectedTemplate?.id == id
              ? null
              : state.selectedTemplate,
          annulSelectedTemplate: state.selectedTemplate?.id == id,
          sections: withSection(
            ChecklistTemplatesSections.deleteTemplate,
            SectionStatus.success,
          ),
        ),
      );
      await loadTemplates(emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao excluir modelo de checklist'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            ChecklistTemplatesSections.deleteTemplate,
            SectionStatus.error,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> saveItem({
    required String? id,
    required String templateId,
    required String label,
    required ChecklistItemType type,
    required bool isRequired,
    List<String>? options,
    int sortOrder = 0,
    DateTime? createdAt,
  }) async {
    emit(
      state.copyWith(
        sections: withSection(
          ChecklistTemplatesSections.saveItem,
          SectionStatus.running,
        ),
      ),
    );

    final isUpdate = id != null;
    final now = DateTime.now();
    final companyId = _useCases.getActiveCompanyId();

    final item = ChecklistItemEntity(
      id: id ?? const Uuid().v4(),
      templateId: templateId,
      companyId: companyId,
      label: label.trim(),
      type: type,
      isRequired: isRequired,
      options: options,
      sortOrder: sortOrder,
      createdAt: createdAt ?? now,
      deletedAt: null,
    );

    final result = isUpdate
        ? await _useCases.updateChecklistItem(item)
        : await _useCases.createChecklistItem(item);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            ChecklistTemplatesSections.saveItem,
            SectionStatus.success,
          ),
        ),
      );
      await loadItemsByTemplate(templateId, emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao salvar item do checklist'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            ChecklistTemplatesSections.saveItem,
            SectionStatus.error,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> deleteItem({
    required String id,
    required String templateId,
  }) async {
    emit(
      state.copyWith(
        sections: withSection(
          ChecklistTemplatesSections.deleteItem,
          SectionStatus.running,
        ),
      ),
    );

    final result = await _useCases.deleteChecklistItem(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final updatedItems = state.templateItems
          .where((i) => i.id != id)
          .toList();
      emit(
        state.copyWith(
          templateItems: updatedItems,
          sections: withSection(
            ChecklistTemplatesSections.deleteItem,
            SectionStatus.success,
          ),
        ),
      );
      await loadItemsByTemplate(templateId, emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao excluir item do checklist'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            ChecklistTemplatesSections.deleteItem,
            SectionStatus.error,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  /// Moves an item within its template and renumbers the run it displaced.
  ///
  /// `sortOrder` drives the order the technician answers in, so a checklist
  /// built in the wrong order could otherwise only be fixed by deleting items —
  /// which orphans the answers already recorded against them.
  Future<bool> reorderItems({
    required String templateId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final ordered = [...state.templateItems]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (oldIndex < 0 || oldIndex >= ordered.length) return false;
    // `onReorderItem` already accounts for the removal, so newIndex is final.
    if (newIndex == oldIndex || newIndex < 0 || newIndex >= ordered.length) {
      return false;
    }

    final moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, moved);

    final renumbered = <ChecklistItemEntity>[];
    for (var index = 0; index < ordered.length; index++) {
      renumbered.add(ordered[index].copyWith(sortOrder: index));
    }

    // Capture the old positions before emitting, or the comparison below reads
    // the list it is being compared against and nothing looks changed.
    final previousOrder = {
      for (final item in state.templateItems) item.id: item.sortOrder,
    };

    // Show the new order immediately; the writes below only persist it.
    emit(
      state.copyWith(
        templateItems: renumbered,
        sections: withSection(
          ChecklistTemplatesSections.reorderItems,
          SectionStatus.running,
        ),
      ),
    );

    final changed = renumbered.where(
      (item) => previousOrder[item.id] != item.sortOrder,
    );

    for (final item in changed) {
      final result = await _useCases.updateChecklistItem(item);
      if (isClosed) return false;

      if (result is! SuccessState<bool> || result.data != true) {
        final message =
            result.message ?? 'Erro ao reordenar os itens'.hardcoded;
        emit(
          state.copyWith(
            sections: withSection(
              ChecklistTemplatesSections.reorderItems,
              SectionStatus.error,
            ),
          ),
        );
        showErrorToast(message);
        await loadItemsByTemplate(templateId, emitLoading: false);
        return false;
      }
    }

    emit(
      state.copyWith(
        sections: withSection(
          ChecklistTemplatesSections.reorderItems,
          SectionStatus.success,
        ),
      ),
    );
    return true;
  }

  Future<void> navigateToCreateUpdateTemplate({
    ChecklistTemplateEntity? template,
  }) async {
    await pushRoute(CreateUpdateChecklistTemplateRoute(template: template));
    await loadTemplates(emitLoading: false);
  }

  Future<void> navigateToCreateUpdateItem({
    required String templateId,
    ChecklistItemEntity? item,
  }) async {
    await pushRoute(
      CreateUpdateChecklistItemRoute(
        templateId: templateId,
        item: item,
        sortOrder: item?.sortOrder ?? state.templateItems.length,
      ),
    );
    await loadItemsByTemplate(templateId, emitLoading: false);
  }
}
