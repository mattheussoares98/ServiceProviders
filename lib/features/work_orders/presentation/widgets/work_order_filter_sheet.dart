import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

/// Bottom sheet for filtering the work orders list.
class WorkOrderFilterSheet extends StatefulWidget {
  const WorkOrderFilterSheet({super.key, required this.currentFilter});

  final WorkOrderFilter currentFilter;

  @override
  State<WorkOrderFilterSheet> createState() => _WorkOrderFilterSheetState();
}

class _WorkOrderFilterSheetState extends State<WorkOrderFilterSheet> {
  late List<WorkOrderStatus> _statuses;
  late List<Priority> _priorities;
  WorkOrderType? _type;
  String? _assignedToId;
  DateTime? _scheduledDateFrom;
  DateTime? _scheduledDateTo;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _statuses = List.from(widget.currentFilter.statuses);
    _priorities = List.from(widget.currentFilter.priorities);
    _type = widget.currentFilter.type;
    _assignedToId = widget.currentFilter.assignedToId;
    _scheduledDateFrom = widget.currentFilter.scheduledDateFrom;
    _scheduledDateTo = widget.currentFilter.scheduledDateTo;
    _searchController.text = widget.currentFilter.searchText ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleStatus(WorkOrderStatus status) {
    setState(() {
      if (_statuses.contains(status)) {
        _statuses.remove(status);
      } else {
        _statuses.add(status);
      }
    });
  }

  void _togglePriority(Priority priority) {
    setState(() {
      if (_priorities.contains(priority)) {
        _priorities.remove(priority);
      } else {
        _priorities.add(priority);
      }
    });
  }

  void _apply() {
    final filter = WorkOrderFilter(
      statuses: _statuses,
      priorities: _priorities,
      type: _type,
      assignedToId: _assignedToId,
      scheduledDateFrom: _scheduledDateFrom,
      scheduledDateTo: _scheduledDateTo,
      searchText: _searchController.text.trimToNull(),
    );
    context.read<WorkOrdersCubit>().applyFilter(filter);
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _statuses = [];
      _priorities = [];
      _type = null;
      _assignedToId = null;
      _scheduledDateFrom = null;
      _scheduledDateTo = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = context.select<UsersCubit, List<UserProfileEntity>>(
      (c) => c.state.users,
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Column(
          children: [
            // handle
            Container(
              margin: const EdgeInsets.only(top: Sizes.p12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.p16,
                vertical: Sizes.p12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BaseText.titleMedium('Filtros'.hardcoded),
                  TextButton(
                    onPressed: _clear,
                    child: BaseText.bodyMedium(
                      'Limpar tudo'.hardcoded,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
                children: [
                  gapH16,
                  // Search by title
                  BaseText('Buscar por título'.hardcoded),
                  gapH8,
                  TextField(
                    controller: _searchController,
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
                    children: WorkOrderStatus.values
                        .map(
                          (s) => FilterChip(
                            label: Text(s.label),
                            selected: _statuses.contains(s),
                            onSelected: (_) => _toggleStatus(s),
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
                    children: Priority.values
                        .map(
                          (p) => FilterChip(
                            label: Text(p.label),
                            selected: _priorities.contains(p),
                            onSelected: (_) => _togglePriority(p),
                          ),
                        )
                        .toList(),
                  ),
                  gapH20,
                  // Type filter
                  BaseText('Tipo'.hardcoded),
                  gapH8,
                  DropdownButtonFormField<WorkOrderType?>(
                    initialValue: _type,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(child: Text('Todos os tipos'.hardcoded)),
                      ...WorkOrderType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ),
                          ),
                    ],
                    onChanged: (v) => setState(() => _type = v),
                  ),
                  gapH20,
                  // Responsible user filter
                  if (users.isNotEmpty) ...[
                    BaseText('Responsável'.hardcoded),
                    gapH8,
                    DropdownButtonFormField<String?>(
                      initialValue: _assignedToId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(child: Text('Todos'.hardcoded)),
                        ...users.map(
                          (u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(u.name),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _assignedToId = v),
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
                          value: _scheduledDateFrom,
                          onPicked: (d) =>
                              setState(() => _scheduledDateFrom = d),
                        ),
                      ),
                      const SizedBox(width: Sizes.p8),
                      Expanded(
                        child: _DatePickerField(
                          label: 'Até'.hardcoded,
                          value: _scheduledDateTo,
                          onPicked: (d) => setState(() => _scheduledDateTo = d),
                        ),
                      ),
                    ],
                  ),
                  gapH24,
                ],
              ),
            ),
            Padding(
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
                    child: PrimaryButton(
                      onTap: _apply,
                      text: 'Aplicar'.hardcoded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
