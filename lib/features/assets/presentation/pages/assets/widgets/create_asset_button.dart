import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/assets/presentation/pages/create_update_asset/create_update_asset_dialog.dart';
import 'package:clean_architecture/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/show_modal_page.dart';
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
      onPressed: assetHasError || locationsHasError || categoriesHasError
          ? null
          : () {
              showModalPage<void>(
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<AssetsCubit>()),
                    BlocProvider.value(value: context.read<LocationsCubit>()),
                    BlocProvider.value(value: context.read<CategoriesCubit>()),
                  ],
                  child: const CreateAssetDialog(),
                ),
                context,
              );
            },
      platformIcon: const PlatformIcon(
        materialIcon: Icons.add,
        cupertinoIcon: CupertinoIcons.add,
      ),
    );
  }
}
