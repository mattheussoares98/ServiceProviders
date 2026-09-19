import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/cubits/maintenance_plans/maintenance_plans_cubit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/pages/maintenance_plans/widgets/maintenance_plan_card.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

@RoutePage()
class MaintenancePlansPage extends StatelessWidget {
  const MaintenancePlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MaintenancePlansCubit>();

    return BaseScaffold(
      onRefresh: cubit.loadMaintenancePlans,
      isScrollable: false,
      appBar: BaseAppBar(
        title: 'Planos de manutenção'.hardcoded,
        actions: [
          BaseIconButton(
            permission: const ActionPermission.resource(
              resourceType: ResourceType.maintenancePlans,
              permissionAction: PermissionAction.create,
            ),
            onPressed: cubit.navigateToCreateUpdateMaintenancePlan,
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body:
          BaseStateView<
            MaintenancePlansCubit,
            MaintenancePlansState,
            List<MaintenancePlanEntity>
          >(
            dataSelector: (state) => state.maintenancePlans,
            onRetry: cubit.loadMaintenancePlans,
            builder: (context, plans) {
              if (plans.isEmpty) {
                return Center(
                  child: BaseText.bodyMedium(
                    'Nenhum plano de manutenção cadastrado'.hardcoded,
                  ),
                );
              }

              return ResponsiveListFlow(
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return MaintenancePlanCard(plan: plan);
                },
              );
            },
          ),
    );
  }
}
