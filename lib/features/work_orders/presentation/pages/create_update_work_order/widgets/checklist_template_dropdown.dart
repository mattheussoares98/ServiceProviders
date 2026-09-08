part of '../create_update_work_order_page.dart';

class _ChecklistTemplateDropdown extends StatelessWidget {
  const _ChecklistTemplateDropdown({
    required this.selectedTemplateId,
    required this.onChanged,
  });

  final String? selectedTemplateId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      builder: (context, state) {
        final templates = state.templates;
        final ids = templates.map((template) => template.id).toSet();

        return BaseDropDown<String>(
          showLabelAtTopLeft: true,
          label: 'Checklist'.hardcoded,
          hint: BaseText.bodyMedium('Nenhum checklist'.hardcoded),
          items: templates
              .map(
                (template) => DropdownMenuItem<String>(
                  value: template.id,
                  child: BaseText.bodyMedium(template.name),
                ),
              )
              .toList(),
          selectedItem: ids.contains(selectedTemplateId)
              ? selectedTemplateId
              : null,
          onClear: onChanged == null ? null : () => onChanged!(null),
          onChanged: onChanged,
        );
      },
    );
  }
}
