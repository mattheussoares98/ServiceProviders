import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class SlaPolicyDropdown extends StatelessWidget {
  const SlaPolicyDropdown({
    required this.selectedSlaPolicyId,
    required this.onChanged,
    super.key,
  });

  final String? selectedSlaPolicyId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlaPoliciesCubit, SlaPoliciesState>(
      builder: (context, state) {
        final dropdownItems =
            state.slaPolicies.map((policy) {
              return DropdownMenuItem<String>(
                value: policy.id,
                child: BaseText.bodyMedium(
                  '${policy.name} (${policy.targetHours}h)',
                ),
              );
            }).toList();

        return BaseDropDown<String>(
          label: 'Política de SLA'.hardcoded,
          hint: BaseText.bodyMedium('Nenhuma (sem SLA)'.hardcoded),
          items: dropdownItems,
          selectedItem: selectedSlaPolicyId,
          onChanged: onChanged,
        );
      },
    );
  }
}
