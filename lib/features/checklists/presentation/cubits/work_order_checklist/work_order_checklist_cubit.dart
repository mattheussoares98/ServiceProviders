import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:uuid/uuid.dart';

part 'work_order_checklist_state.dart';

enum WorkOrderChecklistSections implements SectionKey { saveAnswer }

@injectable
class WorkOrderChecklistCubit extends BaseCubit<WorkOrderChecklistState> {
  WorkOrderChecklistCubit({required WorkOrderChecklistCubitUseCases useCases})
    : _useCases = useCases,
      super(const WorkOrderChecklistState.initial());

  final WorkOrderChecklistCubitUseCases _useCases;

  Future<void> loadChecklist({
    required String templateId,
    required String workOrderId,
    bool emitLoading = true,
  }) async {
    if (emitLoading) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    }

    final itemsResult = await _useCases.getChecklistItemsByTemplate(templateId);
    final answersResult = await _useCases.getWorkOrderChecklistAnswers(
      workOrderId,
    );

    if (isClosed) return;

    if (itemsResult is SuccessState<List<ChecklistItemEntity>> &&
        answersResult is SuccessState<List<ChecklistAnswerEntity>>) {
      final items = itemsResult.data ?? [];
      final answersList = answersResult.data ?? [];
      final answersMap = {
        for (final ans in answersList) ans.checklistItemId: ans,
      };

      emit(
        state.copyWith(
          items: items,
          answers: answersMap,
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
    } else {
      final message =
          itemsResult.message ??
          answersResult.message ??
          'Erro ao carregar checklist da ordem de serviço'.hardcoded;
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

  Future<bool> answerItem({
    required String workOrderId,
    required String checklistItemId,
    bool? booleanValue,
    String? textValue,
    double? numberValue,
    String? photoUrl,
    String? selectedOption,
  }) async {
    emit(
      state.copyWith(
        sections: withSection(
          WorkOrderChecklistSections.saveAnswer,
          SectionStatus.running,
        ),
      ),
    );

    final existingAnswer = state.answers[checklistItemId];
    final now = DateTime.now();

    final answer = ChecklistAnswerEntity(
      id: existingAnswer?.id ?? const Uuid().v4(),
      workOrderId: workOrderId,
      checklistItemId: checklistItemId,
      booleanValue: booleanValue ?? existingAnswer?.booleanValue,
      textValue: textValue ?? existingAnswer?.textValue,
      numberValue: numberValue ?? existingAnswer?.numberValue,
      photoUrl: photoUrl ?? existingAnswer?.photoUrl,
      selectedOption: selectedOption ?? existingAnswer?.selectedOption,
      createdAt: existingAnswer?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await _useCases.saveChecklistResponse(answer);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final updatedAnswers = Map<String, ChecklistAnswerEntity>.from(
        state.answers,
      )..[checklistItemId] = answer;

      emit(
        state.copyWith(
          answers: updatedAnswers,
          sections: withSection(
            WorkOrderChecklistSections.saveAnswer,
            SectionStatus.success,
          ),
        ),
      );
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao salvar resposta do checklist'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrderChecklistSections.saveAnswer,
            SectionStatus.error,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }
}
