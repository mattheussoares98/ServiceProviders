import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class DeleteAssetButton extends StatelessWidget {
  const DeleteAssetButton({super.key, required this.assetId});
  final String? assetId;

  @override
  Widget build(BuildContext context) {
    if (assetId == null) return const SizedBox.shrink();

    return BaseIconButton(
      platformIcon: const PlatformIcon(
        materialIcon: Icons.delete,
        cupertinoIcon: CupertinoIcons.trash,
        color: Colors.red,
      ),
      permission: const ActionPermission.resource(
        resource: ResourceType.assets,
        action: PermissionAction.delete,
      ),
      onPressed: () async {
        final confirmed = await showAlertDialog(
          context: context,
          title: 'Excluir equipamento'.hardcoded,
          contentText:
              'Tem certeza que deseja excluir este equipamento?'.hardcoded,
          cancelActionText: 'Cancelar'.hardcoded,
          defaultActionText: 'Excluir'.hardcoded,
        );
        if (confirmed == true && context.mounted) {
          final succeeds = await context.read<AssetsCubit>().deleteAsset(
            assetId!,
          );
          if (succeeds && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }
}
