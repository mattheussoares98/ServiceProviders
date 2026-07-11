import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class EditAssetButton extends StatelessWidget {
  const EditAssetButton({super.key, required this.asset});
  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return BaseTextButton(
      permission: const ActionPermission(
        resource: ResourceType.locations,
        action: PermissionAction.update,
      ),
      onPressed: () =>
          context.read<AssetsCubit>().navigateToCreateUpdateAsset(asset),
      text: 'Editar'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.edit,
        cupertinoIcon: CupertinoIcons.pencil,
      ),
    );
  }
}
