import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class PlanAssignmentSelectors extends StatelessWidget {
  const PlanAssignmentSelectors({
    super.key,
    required this.selectedPriority,
    required this.selectedChecklistTemplateId,
    required this.selectedAssignedToId,
    required this.selectedServiceProviderCompanyId,
    required this.onPriorityChanged,
    required this.onChecklistChanged,
    required this.onAssignedToChanged,
    required this.onServiceProviderCompanyChanged,
  });

  final Priority selectedPriority;
  final String? selectedChecklistTemplateId;
  final String? selectedAssignedToId;
  final String? selectedServiceProviderCompanyId;
  final ValueChanged<Priority?> onPriorityChanged;
  final ValueChanged<String?> onChecklistChanged;
  final ValueChanged<String?> onAssignedToChanged;
  final ValueChanged<String?> onServiceProviderCompanyChanged;

  @override
  Widget build(BuildContext context) {
    final templates = context.select(
      (ChecklistTemplatesCubit cubit) => cubit.state.templates,
    );
    final users = context.select((UsersCubit cubit) => cubit.state.users);
    final spCompanies = context.select(
      (ServiceProvidersCubit cubit) => cubit.state.companies,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseDropDown<Priority>(
          key: const ValueKey('PlanPriority'),
          showLabelAtTopLeft: true,
          label: 'Prioridade *'.hardcoded,
          selectedItem: selectedPriority,
          items: Priority.values
              .map((p) => DropdownMenuItem(value: p, child: BaseText(p.label)))
              .toList(),
          onChanged: onPriorityChanged,
        ),
        gapH16,
        BaseDropDown<String>(
          key: const ValueKey('PlanChecklist'),
          showLabelAtTopLeft: selectedChecklistTemplateId != null,
          label: 'Checklist padrão'.hardcoded,
          hint: BaseText('Nenhum checklist'.hardcoded),
          selectedItem: selectedChecklistTemplateId,
          items: templates
              .map(
                (t) => DropdownMenuItem(value: t.id, child: BaseText(t.name)),
              )
              .toList(),
          onClear: () => onChecklistChanged(null),
          onChanged: onChecklistChanged,
        ),
        gapH16,
        BaseDropDown<String>(
          key: const ValueKey('PlanAssignedTo'),
          showLabelAtTopLeft: selectedAssignedToId != null,
          label: 'Responsável interno'.hardcoded,
          hint: BaseText('Selecione o responsável'.hardcoded),
          selectedItem: selectedAssignedToId,
          items: users
              .map(
                (u) => DropdownMenuItem(value: u.id, child: BaseText(u.name)),
              )
              .toList(),
          onClear: () => onAssignedToChanged(null),
          onChanged: onAssignedToChanged,
        ),
        gapH16,
        BaseDropDown<String>(
          key: const ValueKey('PlanServiceProvider'),
          showLabelAtTopLeft: selectedServiceProviderCompanyId != null,
          label: 'Empresa prestadora'.hardcoded,
          hint: BaseText('Selecione a prestadora'.hardcoded),
          selectedItem: selectedServiceProviderCompanyId,
          items: spCompanies
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: BaseText(c.name),
                ),
              )
              .toList(),
          onClear: () => onServiceProviderCompanyChanged(null),
          onChanged: onServiceProviderCompanyChanged,
        ),
      ],
    );
  }
}
