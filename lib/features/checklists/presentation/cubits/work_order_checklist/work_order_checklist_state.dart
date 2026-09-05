part of 'work_order_checklist_cubit.dart';

class WorkOrderChecklistState extends BaseState {
  const WorkOrderChecklistState({
    required this.items,
    required this.answers,
    super.sections = const {},
  });

  const WorkOrderChecklistState.initial()
    : items = const [],
      answers = const {},
      super(sections: const {});

  const WorkOrderChecklistState.empty()
    : items = const [],
      answers = const {},
      super(sections: const {});

  final List<ChecklistItemEntity> items;
  final Map<String, ChecklistAnswerEntity> answers;

  /// Validates whether all required checklist items have valid answered values.
  bool get areRequiredItemsCompleted {
    for (final item in items) {
      if (item.isRequired) {
        final answer = answers[item.id];
        if (answer == null) return false;
        final hasValue = switch (item.type) {
          ChecklistItemType.boolean => answer.booleanValue != null,
          ChecklistItemType.text => answer.textValue?.trim().isNotEmpty == true,
          ChecklistItemType.number => answer.numberValue != null,
          ChecklistItemType.photo => answer.photoUrl?.trim().isNotEmpty == true,
          ChecklistItemType.documentation => answer.photoUrl?.trim().isNotEmpty == true || answer.textValue?.trim().isNotEmpty == true,
          ChecklistItemType.selection => answer.selectedOption?.trim().isNotEmpty == true,
        };
        if (!hasValue) return false;
      }
    }
    return true;
  }

  int get completedItemsCount {
    int count = 0;
    for (final item in items) {
      final answer = answers[item.id];
      if (answer == null) continue;
      final isDone = switch (item.type) {
        ChecklistItemType.boolean => answer.booleanValue != null,
        ChecklistItemType.text => answer.textValue?.trim().isNotEmpty == true,
        ChecklistItemType.number => answer.numberValue != null,
        ChecklistItemType.photo => answer.photoUrl?.trim().isNotEmpty == true,
        ChecklistItemType.documentation => answer.photoUrl?.trim().isNotEmpty == true || answer.textValue?.trim().isNotEmpty == true,
        ChecklistItemType.selection => answer.selectedOption?.trim().isNotEmpty == true,
      };
      if (isDone) count++;
    }
    return count;
  }

  double get progress => items.isEmpty ? 1.0 : completedItemsCount / items.length;

  WorkOrderChecklistState copyWith({
    List<ChecklistItemEntity>? items,
    Map<String, ChecklistAnswerEntity>? answers,
    Map<SectionKey, SectionState>? sections,
  }) {
    return WorkOrderChecklistState(
      items: items ?? this.items,
      answers: answers ?? this.answers,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    items,
    answers,
    sections,
  ];
}
