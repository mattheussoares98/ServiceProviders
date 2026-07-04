import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteWorkOrderIconButton extends StatelessWidget {
  const DeleteWorkOrderIconButton({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      return const SizedBox.shrink();
    }
    return BaseIconButton(
      permission: const ActionPermission(
        resource: ResourceType.workOrders,
        action: PermissionAction.delete,
      ),
      onPressed: () async {
        final confirmed = await showAlertDialog(
          context: context,
          title: 'Atenção!'.hardcoded,
          contentText: 'Deseja realmente excluir a ordem de serviço?'.hardcoded,
          defaultActionText: 'Sim'.hardcoded,
          cancelActionText: 'Não'.hardcoded,
        );
        if (confirmed == true && context.mounted) {
          final deleted = await context.read<WorkOrdersCubit>().deleteWorkOrder(
            id!,
          );
          if (deleted && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      platformIcon: const PlatformIcon(
        materialIcon: Icons.delete,
        cupertinoIcon: CupertinoIcons.delete,
        color: Colors.red,
      ),
    );
  }
}
