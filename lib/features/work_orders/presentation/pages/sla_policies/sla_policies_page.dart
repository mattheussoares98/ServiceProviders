import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

@RoutePage()
class SlaPoliciesPage extends StatelessWidget {
  const SlaPoliciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      onRefresh: () => context.read<SlaPoliciesCubit>().loadSlaPolicies(),
      isScrollable: false,
      appBar: BaseAppBar(
        title: 'Políticas de SLA'.hardcoded,
        leading: const OpenDrawerIconButton(),
        actions: [
          BaseIconButton(
            permission: const ActionPermission.resource(
              resource: ResourceType.workOrders,
              action: PermissionAction.create,
            ),
            onPressed: () async {
              final result = await context.router.push(
                CreateUpdateSlaPolicyRoute(),
              );
              if (result == true && context.mounted) {
                context.read<SlaPoliciesCubit>().loadSlaPolicies();
              }
            },
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: BaseStateView<SlaPoliciesCubit, SlaPoliciesState, List<SlaPolicyEntity>>(
        dataSelector: (state) => state.slaPolicies,
        onRetry: () => context.read<SlaPoliciesCubit>().loadSlaPolicies(),
        builder: (context, policies) {
          if (policies.isEmpty) {
            return Center(
              child: BaseText.bodyMedium('Nenhuma política de SLA cadastrada'.hardcoded),
            );
          }

          return ResponsiveListFlow(
            itemCount: policies.length,
            itemBuilder: (context, index) {
              final policy = policies[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.timer_outlined),
                  ),
                  title: BaseText.titleMedium(policy.name),
                  subtitle: BaseText.bodySmall(
                    '${policy.targetHours}h (${policy.appliesTo.label})',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BaseIconButton(
                        permission: const ActionPermission.resource(
                          resource: ResourceType.workOrders,
                          action: PermissionAction.update,
                        ),
                        onPressed: () async {
                          final result = await context.router.push(
                            CreateUpdateSlaPolicyRoute(slaPolicy: policy),
                          );
                          if (result == true && context.mounted) {
                            context.read<SlaPoliciesCubit>().loadSlaPolicies();
                          }
                        },
                        platformIcon: const PlatformIcon(
                          materialIcon: Icons.edit_outlined,
                          cupertinoIcon: CupertinoIcons.pencil,
                        ),
                      ),
                      BaseIconButton(
                        permission: const ActionPermission.resource(
                          resource: ResourceType.workOrders,
                          action: PermissionAction.delete,
                        ),
                        onPressed: () => context
                            .read<SlaPoliciesCubit>()
                            .deleteSlaPolicy(policy.id),
                        platformIcon: const PlatformIcon(
                          materialIcon: Icons.delete_outline,
                          cupertinoIcon: CupertinoIcons.trash,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
