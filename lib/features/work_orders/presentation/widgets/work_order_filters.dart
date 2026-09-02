import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

/// Bottom sheet for filtering the work orders list.
class WorkOrderFilters extends HookWidget {
  const WorkOrderFilters({super.key, required this.currentFilter});

  final WorkOrderFilter currentFilter;

  @override
  Widget build(BuildContext context) {
    final statuses = useState<List<WorkOrderStatus>>(
      List.from(currentFilter.statuses),
    );
    final priorities = useState<List<Priority>>(
      List.from(currentFilter.priorities),
    );
    final type = useState<WorkOrderType?>(currentFilter.type);
    final assignedToId = useState<String?>(currentFilter.assignedToId);
    final scheduledDateFrom = useState<DateTime?>(
      currentFilter.scheduledDateFrom,
    );
    final scheduledDateTo = useState<DateTime?>(currentFilter.scheduledDateTo);
    final isDelayed = useState<bool>(currentFilter.isDelayed);
    final searchController = useTextEditingController(
      text: currentFilter.searchText ?? '',
    );

    void toggleStatus(WorkOrderStatus status) {
      if (statuses.value.contains(status)) {
        statuses.value = statuses.value.where((s) => s != status).toList();
      } else {
        statuses.value = [...statuses.value, status];
      }
    }

    void togglePriority(Priority priority) {
      if (priorities.value.contains(priority)) {
        priorities.value = priorities.value
            .where((p) => p != priority)
            .toList();
      } else {
        priorities.value = [...priorities.value, priority];
      }
    }

    void apply() {
      final filter = WorkOrderFilter(
        statuses: statuses.value,
        priorities: priorities.value,
        type: type.value,
        assignedToId: assignedToId.value,
        scheduledDateFrom: scheduledDateFrom.value,
        scheduledDateTo: scheduledDateTo.value,
        searchText: searchController.text.trimToNull(),
        isDelayed: isDelayed.value,
      );
      context.read<WorkOrdersCubit>().applyFilter(filter);
      Navigator.of(context).pop();
    }

    void clear() {
      statuses.value = [];
      priorities.value = [];
      type.value = null;
      assignedToId.value = null;
      scheduledDateFrom.value = null;
      scheduledDateTo.value = null;
      isDelayed.value = false;
      searchController.clear();
    }

    final users = context.select<UsersCubit, List<UserProfileEntity>>(
      (c) => c.state.users,
    );

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          automaticallyImplyLeading: false,
          titleSpacing: Sizes.p16,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BaseText.titleMedium('Filtros'.hardcoded),
              TextButton(
                onPressed: clear,
                child: BaseText.bodyMedium(
                  'Limpar tudo'.hardcoded,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: Divider(height: 1)),
        SliverToBoxAdapter(
          child: Column(
            children: [
              gapH16,
              // Search by title
              BaseText('Buscar por título'.hardcoded),
              gapH8,
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Ex: Revisão bomba'.hardcoded,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Sizes.p12,
                    vertical: Sizes.p8,
                  ),
                ),
              ),
              gapH20,
              // Status filter
              BaseText('Status'.hardcoded),
              gapH8,
              Wrap(
                spacing: Sizes.p8,
                runSpacing: Sizes.p4,
                children: WorkOrderStatus.values
                    .map(
                      (s) => FilterChip(
                        label: Text(s.label),
                        selected: statuses.value.contains(s),
                        onSelected: (_) => toggleStatus(s),
                      ),
                    )
                    .toList(),
              ),
              gapH20,
              // Priority filter
              BaseText('Prioridade'.hardcoded),
              gapH8,
              Wrap(
                spacing: Sizes.p8,
                runSpacing: Sizes.p4,
                children: Priority.values
                    .map(
                      (p) => FilterChip(
                        label: Text(p.label),
                        selected: priorities.value.contains(p),
                        onSelected: (_) => togglePriority(p),
                      ),
                    )
                    .toList(),
              ),
              gapH20,
              // Type filter
              BaseText('Tipo'.hardcoded),
              gapH8,
              DropdownButtonFormField<WorkOrderType?>(
                initialValue: type.value,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  DropdownMenuItem(child: Text('Todos os tipos'.hardcoded)),
                  ...WorkOrderType.values.map(
                    (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                  ),
                ],
                onChanged: (v) => type.value = v,
              ),
              gapH20,
              // Responsible user filter
              if (users.isNotEmpty) ...[
                BaseText('Responsável'.hardcoded),
                gapH8,
                DropdownButtonFormField<String?>(
                  initialValue: assignedToId.value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(child: Text('Todos'.hardcoded)),
                    ...users.map(
                      (u) => DropdownMenuItem(value: u.id, child: Text(u.name)),
                    ),
                  ],
                  onChanged: (v) => assignedToId.value = v,
                ),
                gapH20,
              ],
              // Date range
              BaseText('Data programada'.hardcoded),
              gapH8,
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'De'.hardcoded,
                      value: scheduledDateFrom.value,
                      onPicked: (d) => scheduledDateFrom.value = d,
                    ),
                  ),
                  const SizedBox(width: Sizes.p8),
                  Expanded(
                    child: _DatePickerField(
                      label: 'Até'.hardcoded,
                      value: scheduledDateTo.value,
                      onPicked: (d) => scheduledDateTo.value = d,
                    ),
                  ),
                ],
              ),
              gapH20,
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: BaseText('Apenas ordens atrasadas'.hardcoded),
                subtitle: BaseText.bodySmall(
                  'Filtrar ordens não concluídas com SLA vencido'.hardcoded,
                ),
                value: isDelayed.value,
                onChanged: (val) => isDelayed.value = val,
              ),
              gapH24,
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Sizes.p16,
              Sizes.p8,
              Sizes.p16,
              Sizes.p16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    onTap: () => Navigator.of(context).pop(),
                    text: 'Cancelar'.hardcoded,
                  ),
                ),
                const SizedBox(width: Sizes.p12),
                Expanded(
                  child: BaseButton(onTap: apply, text: 'Aplicar'.hardcoded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onPicked,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onPicked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Sizes.p12,
            vertical: Sizes.p8,
          ),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () => onPicked(null),
                )
              : const Icon(CupertinoIcons.calendar, size: 18),
        ),
        child: BaseText.bodySmall(
          value != null
              ? '${value!.day.toString().padLeft(2, '0')}/'
                    '${value!.month.toString().padLeft(2, '0')}/'
                    '${value!.year}'
              : '—',
        ),
      ),
    );
  }
}
