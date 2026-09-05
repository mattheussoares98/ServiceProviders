part of 'checklist_templates_cubit.dart';

class ChecklistTemplatesState extends BaseState {
  const ChecklistTemplatesState({
    required this.templates,
    required this.templateItems,
    this.selectedTemplate,
    super.sections = const {},
  });

  const ChecklistTemplatesState.initial()
    : templates = const [],
      templateItems = const [],
      selectedTemplate = null,
      super(sections: const {});

  const ChecklistTemplatesState.empty()
    : templates = const [],
      templateItems = const [],
      selectedTemplate = null,
      super(sections: const {});

  final List<ChecklistTemplateEntity> templates;
  final List<ChecklistItemEntity> templateItems;
  final ChecklistTemplateEntity? selectedTemplate;

  ChecklistTemplatesState copyWith({
    List<ChecklistTemplateEntity>? templates,
    List<ChecklistItemEntity>? templateItems,
    ChecklistTemplateEntity? selectedTemplate,
    bool? annulSelectedTemplate,
    Map<SectionKey, SectionState>? sections,
  }) {
    return ChecklistTemplatesState(
      templates: templates ?? this.templates,
      templateItems: templateItems ?? this.templateItems,
      selectedTemplate: annulSelectedTemplate == true
          ? null
          : selectedTemplate ?? this.selectedTemplate,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    templates,
    templateItems,
    selectedTemplate,
    sections,
  ];
}
