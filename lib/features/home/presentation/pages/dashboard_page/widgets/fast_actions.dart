import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/quick_action_button.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/evaluate_prerequisites_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class FastActions extends StatelessWidget {
  const FastActions({super.key});

  void _handleCreateWorkOrder(BuildContext context) {
    final workType =
        context.read<CompanyCubit>().state.company?.workType ?? WorkType.hybrid;
    final locationsState = context.read<LocationsCubit>().state;
    final hasCustomers = context.read<CustomersCubit>().state.hasCustomers;
    final hasAssets = context.read<AssetsCubit>().state.hasAssets;
    final usersCubit = context.read<UsersCubit>();
    final hasLocationCreate = usersCubit.hasPermission(
      const ActionPermission.resource(
        resourceType: ResourceType.locations,
        permissionAction: PermissionAction.create,
      ),
    );
    final hasAssetCreate = usersCubit.hasPermission(
      const ActionPermission.resource(
        resourceType: ResourceType.assets,
        permissionAction: PermissionAction.create,
      ),
    );

    final eval = context.read<WorkOrdersCubit>().evaluatePrerequisites(
      EvaluatePrerequisitesParams(
        workType: workType,
        hasLocations: locationsState.hasLocations,
        hasAreas: locationsState.hasAreas,
        hasCustomers: hasCustomers,
        hasAssets: hasAssets,
        hasLocationCreatePermission: hasLocationCreate,
        hasAssetCreatePermission: hasAssetCreate,
      ),
    );

    if (eval.hasPendingRequiredPrerequisites) {
      final mandatorySteps = eval.steps.where((e) => !e.isOptional);
      if (mandatorySteps.isNotEmpty) {
        showAlertDialog(
          context: context,
          title: 'Etapas pendentes'.hardcoded,
          contentWidget: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                BaseText(
                  'Conclua as etapas obrigatórias antes de criar a primeira ordem de serviço'
                      .hardcoded,
                ),
                gapH32,
                ...mandatorySteps.map((e) => BaseText('• ${e.title}\n\n')),
              ],
            ),
          ),
          contentText:
              'Conclua as etapas obrigatórias antes de criar a primeira ordem de serviço'
                  .hardcoded +
              mandatorySteps.map((e) => e.description).join('\n'),
        );
      }
      return;
    }

    context.read<WorkOrdersCubit>().navigateToCreateUpdateWorkOrder(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText.title('Ações rápidas'.hardcoded),
        gapH4,
        Row(
          children: [
            Flexible(
              child: QuickActionButton(
                label: 'Nova ordem'.hardcoded,
                icon: const PlatformIcon(
                  materialIcon: Icons.add_task,
                  cupertinoIcon: CupertinoIcons.check_mark_circled,
                ),
                onTap: () => _handleCreateWorkOrder(context),
              ),
            ),
            gapW12,
            Flexible(
              child: QuickActionButton(
                label: 'Novo equipamento'.hardcoded,
                icon: const PlatformIcon(
                  materialIcon: Icons.add_box_outlined,
                  cupertinoIcon: CupertinoIcons.add_circled,
                ),
                onTap: () =>
                    context.read<AssetsCubit>().navigateToCreateUpdateAsset(),
              ),
            ),
          ],
        ),
        gapH12,
      ],
    );
  }
}
