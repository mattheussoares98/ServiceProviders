part of '../edit_group_permissions_page.dart';

class _GroupWorkOrdersCard extends StatelessWidget {
  const _GroupWorkOrdersCard();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PermissionsCubit>();
    final isAdmin = context.select<PermissionsCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );

    return Card(
      color: context.theme.primaryColorLight.withAlpha(40),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseText(
              ResourceType.workOrders.label,
              fontWeight: FontWeight.bold,
            ),
            const Divider(height: Sizes.p20),
            BlocSelector<
              PermissionsCubit,
              PermissionsState,
              WorkOrdersPermissionEntity
            >(
              selector: (state) => state.draftGroupWorkOrders,
              builder: (context, draft) {
                return Column(
                  children: [
                    _ScopeRow<WorkOrderReadScope>(
                      label: 'Escopo de leitura (visualizar)'.hardcoded,
                      items: WorkOrderReadScope.values,
                      selectedValue: draft.readScope,
                      onChanged: isAdmin
                          ? null
                          : cubit.changeGroupWorkOrdersReadScope,
                      labelBuilder: (val) => val.label,
                      colorBuilder: (val) => Colors.indigo.shade600,
                    ),
                    BaseSwitch(
                      title: 'Criar ordens de serviço'.hardcoded,
                      value: draft.create,
                      onChanged: isAdmin
                          ? null
                          : cubit.toggleGroupWorkOrdersCreate,
                    ),
                    _ScopeRow<WorkOrderUpdateScope>(
                      label: 'Escopo de Edição (Alterar)'.hardcoded,
                      items: WorkOrderUpdateScope.values,
                      selectedValue: draft.updateScope,
                      onChanged: isAdmin
                          ? null
                          : cubit.changeGroupWorkOrdersUpdateScope,
                      labelBuilder: (val) => val.label,
                      colorBuilder: (val) => Colors.teal.shade600,
                    ),
                    BaseSwitch(
                      title: 'Excluir ordens de serviço'.hardcoded,
                      value: draft.delete,
                      onChanged: isAdmin
                          ? null
                          : cubit.toggleGroupWorkOrdersDelete,
                    ),
                    const Divider(height: Sizes.p20),
                    BaseSwitch(
                      title: 'Alterar status'.hardcoded,
                      value: draft.changeStatus,
                      onChanged: isAdmin
                          ? null
                          : cubit.toggleGroupWorkOrdersChangeStatus,
                    ),
                    BaseSwitch(
                      title: 'Reatribuir responsável'.hardcoded,
                      value: draft.reassign,
                      onChanged: isAdmin
                          ? null
                          : cubit.toggleGroupWorkOrdersReassign,
                    ),
                    BaseSwitch(
                      title: 'Aprovar mudanças de status'.hardcoded,
                      value: draft.managePendingRequests,
                      onChanged: isAdmin
                          ? null
                          : cubit.toggleGroupWorkOrdersmanagePendingRequests,
                    ),
                    BaseSwitch(
                      title: 'Excluir observações'.hardcoded,
                      value: draft.deleteObservation,
                      onChanged: isAdmin
                          ? null
                          : cubit.toggleGroupWorkOrdersDeleteObservation,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeRow<T> extends StatelessWidget {
  const _ScopeRow({
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.labelBuilder,
    required this.colorBuilder,
  });

  final String label;
  final List<T> items;
  final T selectedValue;
  final ValueChanged<T>? onChanged;
  final String Function(T) labelBuilder;
  final Color Function(T) colorBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
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
              onChanged: onChanged,
              itemLabelBuilder: labelBuilder,
              itemColorBuilder: colorBuilder,
            ),
          ),
        ],
      ),
    );
  }
}
