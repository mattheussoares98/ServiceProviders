import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class EditAndDeleteIcons extends StatelessWidget {
  const EditAndDeleteIcons({super.key, required this.workOrderId});
  final String workOrderId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      mainAxisAlignment: .end,
      children: [
        Flexible(
          child: BaseIconButton(
            permission: const ActionPermission(
              resource: ResourceType.workOrders,
              action: PermissionAction.update,
            ),
            onPressed: () {
              context.read<WorkOrdersCubit>().navigateToCreateUpdateWorkOrder(
                workOrderId,
              );
            },
            platformIcon: const PlatformIcon(
              materialIcon: Icons.edit_outlined,
              cupertinoIcon: CupertinoIcons.pencil,
            ),
          ),
        ),
        Flexible(
          child: BaseIconButton(
            permission: const ActionPermission(
              resource: ResourceType.workOrders,
              action: PermissionAction.delete,
            ),
            onPressed: () {
              showAlertDialog(
                context: context,
                title: 'Atenção!'.hardcoded,
                contentText:
                    'Deseja realmente excluir a ordem de serviço?'.hardcoded,
                defaultActionText: 'Sim'.hardcoded,
                cancelActionText: 'Não'.hardcoded,
                onOkPressed: () async {
                  final succeeds = await context
                      .read<WorkOrdersCubit>()
                      .deleteWorkOrder(workOrderId);
                  if (succeeds && context.mounted) {
                    context.pop();
                  }
                },
              );
            },
            platformIcon: const PlatformIcon(
              materialIcon: Icons.delete,
              cupertinoIcon: CupertinoIcons.delete,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
