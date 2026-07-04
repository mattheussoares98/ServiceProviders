import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      permission: const ActionPermission(
        resource: ResourceType.assets,
        action: PermissionAction.create,
      ),
      onPressed: assetHasError || locationsHasError || categoriesHasError
          ? null
          : () => context.router.push(CreateUpdateAssetRoute()),
      platformIcon: const PlatformIcon(
        materialIcon: Icons.add,
        cupertinoIcon: CupertinoIcons.add,
      ),
    );
  }
}
