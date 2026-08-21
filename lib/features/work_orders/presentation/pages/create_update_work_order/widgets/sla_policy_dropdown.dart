part of '../create_update_work_order_page.dart';

class _SlaPolicyDropdown extends StatelessWidget {
  const _SlaPolicyDropdown({
    required this.selectedSlaPolicyId,
    required this.onChanged,
  });

  final String? selectedSlaPolicyId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlaPoliciesCubit, SlaPoliciesState>(
      builder: (context, state) {
        final dropdownItems = state.slaPolicies.map((policy) {
          return DropdownMenuItem<String>(
            value: policy.id,
            child: BaseText.bodyMedium(
              '${policy.name} (${policy.targetHours}h)',
            ),
          );
        }).toList();

        return BaseDropDown<String>(
          showLabelAtTopLeft: true,
          label: 'Política de SLA'.hardcoded,
          hint: BaseText.bodyMedium('Nenhuma (sem SLA)'.hardcoded),
          items: dropdownItems,
          selectedItem: selectedSlaPolicyId,
          onClear: onChanged == null ? null : () => onChanged!(null),
          onChanged: onChanged,
        );
      },
    );
  }
}
