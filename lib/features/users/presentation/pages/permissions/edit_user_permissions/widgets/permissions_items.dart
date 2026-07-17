import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/permissions/permissions_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_segmented_buttons.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class PermissionsItems extends StatelessWidget {
  const PermissionsItems({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PermissionsCubit>();
    final isAdmin = context.select<PermissionsCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );

    // Filter standard resources (everything except workOrders)
    final standardResources = ResourceType.values
        .where((r) => r != ResourceType.workOrders)
        .toList();

    return ResponsiveListFlow(
      maxItemWidth: 350,
      isSliver: true,
      itemCount:
          standardResources.length +
          1, // standard resources + 1 for work orders
      itemBuilder: (context, index) {
        if (index == 0) {
          // Dedicated card for Work Orders permissions with scopes
          return const _WorkOrdersCard();
        }

        final resource = standardResources[index - 1];
        // Standard actions: create, update, delete only (read is mandatory)
        final standardActions = [
          PermissionAction.create,
          PermissionAction.update,
          PermissionAction.delete,
        ];

        return Card(
          child: ExpansionTile(
            title: BaseText.titleMedium(resource.label),
            subtitle: _Subtitle(resource: resource),
            children: standardActions.map((action) {
              return BlocSelector<PermissionsCubit, PermissionsState, bool?>(
                selector: (state) =>
                    state.draftUserPermissions[resource]?[action],
                builder: (context, currentValue) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p16,
                      vertical: Sizes.p8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: BaseText(
                            action.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        gapW8,
                        Expanded(
                          flex: 8,
                          child: BaseSegmentedButtons<bool?>(
                            items: const [null, true, false],
                            selectedValue: currentValue,
                            onChanged: isAdmin
                                ? null
                                : (value) => cubit.setUserPermissionOverride(
                                    resource,
                                    action,
                                    value,
                                  ),
                            itemLabelBuilder: (value) {
                              switch (value) {
                                case null:
                                  return 'Herdar'.hardcoded;
                                case true:
                                  return 'Ativo'.hardcoded;
                                case false:
                                  return 'Inativo'.hardcoded;
                              }
                            },
                            itemColorBuilder: (value) {
                              switch (value) {
                                case null:
                                  return context.theme.primaryColor;
                                case true:
                                  return Colors.green.shade600;
                                case false:
                                  return Colors.red.shade600;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.resource});
  final ResourceType resource;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      PermissionsCubit,
      PermissionsState,
      Map<PermissionAction, bool?>?
    >(
      selector: (state) => state.draftUserPermissions[resource],
      builder: (context, permissions) {
        if (permissions == null) {
          return const SizedBox.shrink();
        }
        final items = permissions.entries
            .where((entry) => entry.key != PermissionAction.read)
            .toList();

        return Row(
          children: items.map((entry) {
            final value = entry.value;
            final Color color;
            if (value == null) {
              color = Colors.lightBlue;
            } else if (!value) {
              color = Colors.red;
            } else {
              color = Colors.green;
            }
            return Padding(
              padding: const EdgeInsets.only(right: Sizes.p8),
              child: BaseText.bodySmall(entry.key.label, color: color),
            );
          }).toList(),
        );
      },
    );
  }
}

class _WorkOrdersCard extends StatelessWidget {
  const _WorkOrdersCard();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PermissionsCubit>();
    final isAdmin = context.select<PermissionsCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );

    return Card(
      color: context.theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
      child: ExpansionTile(
        title: BaseText.titleMedium(
          ResourceType.workOrders.label,
          color: context.theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
        subtitle: BaseText.bodySmall(
          'Permissões e Escopos Customizados'.hardcoded,
        ),
        children: [
          BlocSelector<
            PermissionsCubit,
            PermissionsState,
            UserWorkOrdersPermissionOverrideEntity
          >(
            selector: (state) => state.draftUserWorkOrders,
            builder: (context, draft) {
              Widget buildScopeRow<T>({
                required String label,
                required List<T> items,
                required T selectedValue,
                required ValueChanged<T>? onChanged,
                required String Function(T) labelBuilder,
                required Color Function(T) colorBuilder,
              }) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.p16,
                    vertical: Sizes.p8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BaseText.bodyMedium(label, fontWeight: FontWeight.w600),
                      gapH4,
                      SizedBox(
                        width: double.infinity,
                        child: BaseSegmentedButtons<T>(
                          items: items,
                          selectedValue: selectedValue,
                          onChanged: isAdmin ? null : onChanged,
                          itemLabelBuilder: labelBuilder,
                          itemColorBuilder: colorBuilder,
                        ),
                      ),
                    ],
                  ),
                );
              }

              Widget buildToggleRow({
                required String label,
                required bool? selectedValue,
                required ValueChanged<bool?>? onChanged,
              }) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.p16,
                    vertical: Sizes.p8,
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 5, child: BaseText(label)),
                      gapW8,
                      Expanded(
                        flex: 6,
                        child: BaseSegmentedButtons<bool?>(
                          items: const [null, true, false],
                          selectedValue: selectedValue,
                          onChanged: isAdmin ? null : onChanged,
                          itemLabelBuilder: (val) {
                            if (val == null) return 'Herdar'.hardcoded;
                            return val
                                ? 'Ativo'.hardcoded
                                : 'Inativo'.hardcoded;
                          },
                          itemColorBuilder: (val) {
                            if (val == null) return context.theme.primaryColor;
                            return val
                                ? Colors.green.shade600
                                : Colors.red.shade600;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  buildScopeRow<WorkOrderReadScope?>(
                    label: 'Escopo de Leitura (Visualizar)'.hardcoded,
                    items: const [
                      null,
                      WorkOrderReadScope.all,
                      WorkOrderReadScope.assigned,
                    ],
                    selectedValue: draft.readScope,
                    onChanged: cubit.changeUserWorkOrdersReadScope,
                    labelBuilder: (val) =>
                        val == null ? 'Herdar'.hardcoded : val.label,
                    colorBuilder: (val) => val == null
                        ? context.theme.primaryColor
                        : Colors.indigo.shade600,
                  ),
                  buildToggleRow(
                    label: 'Criar ordens de serviço'.hardcoded,
                    selectedValue: draft.create,
                    onChanged: cubit.toggleUserWorkOrdersCreate,
                  ),
                  buildScopeRow<WorkOrderUpdateScope?>(
                    label: 'Escopo de Edição (Alterar)'.hardcoded,
                    items: const [
                      null,
                      WorkOrderUpdateScope.all,
                      WorkOrderUpdateScope.assigned,
                      WorkOrderUpdateScope.own,
                      WorkOrderUpdateScope.none,
                    ],
                    selectedValue: draft.updateScope,
                    onChanged: cubit.changeUserWorkOrdersUpdateScope,
                    labelBuilder: (val) =>
                        val == null ? 'Herdar'.hardcoded : val.label,
                    colorBuilder: (val) => val == null
                        ? context.theme.primaryColor
                        : Colors.teal.shade600,
                  ),
                  buildToggleRow(
                    label: 'Excluir ordens de serviço'.hardcoded,
                    selectedValue: draft.delete,
                    onChanged: cubit.toggleUserWorkOrdersDelete,
                  ),
                  const Divider(),
                  buildToggleRow(
                    label: 'Alterar status'.hardcoded,
                    selectedValue: draft.changeStatus,
                    onChanged: cubit.toggleUserWorkOrdersChangeStatus,
                  ),
                  buildToggleRow(
                    label: 'Reatribuir responsável'.hardcoded,
                    selectedValue: draft.reassign,
                    onChanged: cubit.toggleUserWorkOrdersReassign,
                  ),
                  buildToggleRow(
                    label: 'Aprovar pausas'.hardcoded,
                    selectedValue: draft.approvePause,
                    onChanged: cubit.toggleUserWorkOrdersApprovePause,
                  ),
                  buildToggleRow(
                    label: 'Aprovar conclusão'.hardcoded,
                    selectedValue: draft.approveCompletion,
                    onChanged: cubit.toggleUserWorkOrdersApproveCompletion,
                  ),
                  gapH8,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
