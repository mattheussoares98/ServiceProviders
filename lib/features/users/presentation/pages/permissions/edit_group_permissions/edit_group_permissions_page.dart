import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/permissions/permissions_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/edit_group_permissions/widgets/group_permissions_header.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/edit_group_permissions/widgets/resource_permission_card.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_segmented_buttons.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

@RoutePage()
class EditGroupPermissionsPage extends StatelessWidget {
  const EditGroupPermissionsPage({super.key, required this.group});
  final PermissionGroupEntity group;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<PermissionsCubit>()..initGroup(group),
      child: _Body(group: group),
    );
  }
}

class _Body extends HookWidget {
  const _Body({required this.group});
  final PermissionGroupEntity group;

  @override
  Widget build(BuildContext context) {
    observeLoading(
      [context.read<PermissionsCubit>()],
      statuses: {StateStatus.saving, StateStatus.loading, StateStatus.deleting},
    );
    return BlocSelector<
      PermissionsCubit,
      PermissionsState,
      (bool, StateStatus)
    >(
      selector: (state) => (state.isAdmin, state.status),
      builder: (context, state) {
        final isAdmin = state.$1;
        final status = state.$2;

        Future<void> onSave() async {
          final cubit = context.read<PermissionsCubit>();

          final success = await cubit.saveGroupPermissions(
            context.read<UsersCubit>(),
          );
          if (success && context.mounted) {
            cubit.popRoute();
          }
        }

        return BaseScaffold(
          isScrollable: false,
          appBar: BaseAppBar(
            title: 'Editar Grupo'.hardcoded,
            actionsPadding: const EdgeInsets.only(right: Sizes.p12),
            actions: [
              if (!isAdmin)
                BaseTextButton(
                  platformIcon: const PlatformIcon(
                    materialIcon: Icons.save,
                    cupertinoIcon: CupertinoIcons.check_mark,
                  ),
                  onPressed: status == StateStatus.saving ? null : onSave,
                  text: 'Salvar'.hardcoded,
                  isLoading: status == StateStatus.saving,
                ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: GroupPermissionsHeader(
                  group: group,
                  isAdminGroup: isAdmin,
                ),
              ),
              BlocSelector<
                PermissionsCubit,
                PermissionsState,
                Map<ResourceType, Set<PermissionAction>>
              >(
                selector: (state) => state.draftGroupPermissions,
                builder: (context, draftGroupPermissions) {
                  final standardResources = ResourceType.values
                      .where((r) => r != ResourceType.workOrders)
                      .toList();

                  return ResponsiveListFlow(
                    isSliver: true,
                    maxItemWidth: 350,
                    itemCount: standardResources.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const _GroupWorkOrdersCard();
                      }

                      final resource = standardResources[index - 1];
                      final allowedPermissions =
                          draftGroupPermissions[resource] ?? {};
                      return ResourcePermissionCard(
                        resource: resource,
                        allowedPermissions: allowedPermissions,
                        isAdminGroup: isAdmin,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GroupWorkOrdersCard extends StatelessWidget {
  const _GroupWorkOrdersCard();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PermissionsCubit>();
    final isAdmin = context.select<PermissionsCubit, bool>(
      (cubit) => cubit.state.isAdmin,
    );

    return Card(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
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
                Widget buildScopeRow<T>({
                  required String label,
                  required List<T> items,
                  required T selectedValue,
                  required ValueChanged<T>? onChanged,
                  required String Function(T) labelBuilder,
                  required Color Function(T) colorBuilder,
                }) {
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
                            onChanged: isAdmin ? null : onChanged,
                            itemLabelBuilder: labelBuilder,
                            itemColorBuilder: colorBuilder,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                Widget buildSwitchRow({
                  required String label,
                  required bool selectedValue,
                  required ValueChanged<bool>? onChanged,
                }) {
                  return DefaultSwitch(
                    title: label,
                    value: selectedValue,
                    onChanged: isAdmin ? null : onChanged,
                  );
                }

                return Column(
                  children: [
                    buildScopeRow<WorkOrderReadScope>(
                      label: 'Escopo de Leitura (Visualizar)'.hardcoded,
                      items: WorkOrderReadScope.values,
                      selectedValue: draft.readScope,
                      onChanged: cubit.changeGroupWorkOrdersReadScope,
                      labelBuilder: (val) => val.label,
                      colorBuilder: (val) => Colors.indigo.shade600,
                    ),
                    buildSwitchRow(
                      label: 'Criar ordens de serviço'.hardcoded,
                      selectedValue: draft.create,
                      onChanged: cubit.toggleGroupWorkOrdersCreate,
                    ),
                    buildScopeRow<WorkOrderUpdateScope>(
                      label: 'Escopo de Edição (Alterar)'.hardcoded,
                      items: WorkOrderUpdateScope.values,
                      selectedValue: draft.updateScope,
                      onChanged: cubit.changeGroupWorkOrdersUpdateScope,
                      labelBuilder: (val) => val.label,
                      colorBuilder: (val) => Colors.teal.shade600,
                    ),
                    buildSwitchRow(
                      label: 'Excluir ordens de serviço'.hardcoded,
                      selectedValue: draft.delete,
                      onChanged: cubit.toggleGroupWorkOrdersDelete,
                    ),
                    const Divider(height: Sizes.p20),
                    buildSwitchRow(
                      label: 'Alterar status'.hardcoded,
                      selectedValue: draft.changeStatus,
                      onChanged: cubit.toggleGroupWorkOrdersChangeStatus,
                    ),
                    buildSwitchRow(
                      label: 'Reatribuir responsável'.hardcoded,
                      selectedValue: draft.reassign,
                      onChanged: cubit.toggleGroupWorkOrdersReassign,
                    ),
                    buildSwitchRow(
                      label: 'Aprovar pausas'.hardcoded,
                      selectedValue: draft.approvePause,
                      onChanged: cubit.toggleGroupWorkOrdersApprovePause,
                    ),
                    buildSwitchRow(
                      label: 'Aprovar conclusão'.hardcoded,
                      selectedValue: draft.approveCompletion,
                      onChanged: cubit.toggleGroupWorkOrdersApproveCompletion,
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

class DefaultSwitch extends StatelessWidget {
  const DefaultSwitch({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: BaseText(title)),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
