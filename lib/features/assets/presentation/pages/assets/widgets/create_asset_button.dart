import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class CreateAssetButton extends StatelessWidget {
  const CreateAssetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final assetHasError = context.select<AssetsCubit, bool>(
      (cubit) => cubit.state.errorMessage?.isNotEmpty ?? false,
    );
    final locationsHasError = context.select<LocationsCubit, bool>(
      (cubit) => cubit.state.errorMessage?.isNotEmpty ?? false,
    );
    final categoriesHasError = context.select<CategoriesCubit, bool>(
      (cubit) => cubit.state.errorMessage?.isNotEmpty ?? false,
    );

    return BaseIconButton(
      permission: const ActionPermission.resource(
        resource: ResourceType.assets,
        action: PermissionAction.create,
      ),
      onPressed: assetHasError || locationsHasError || categoriesHasError
          ? null
          : () => context.read<AssetsCubit>().navigateToCreateUpdateAsset(),
      platformIcon: const PlatformIcon(
        materialIcon: Icons.add,
        cupertinoIcon: CupertinoIcons.add,
      ),
    );
  }
}
