import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/assets/presentation/pages/create_update_asset/create_update_asset_dialog.dart';
import 'package:clean_architecture/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/show_modal_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditAssetButton extends StatelessWidget {
  const EditAssetButton({super.key, required this.asset});
  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return BaseTextButton(
      onPressed: () {
        showModalPage<void>(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<AssetsCubit>()),
              BlocProvider.value(value: context.read<LocationsCubit>()),
              BlocProvider.value(value: context.read<CategoriesCubit>()),
            ],
            child: CreateAssetDialog(asset: asset),
          ),
          context,
        );
      },
      text: 'Editar'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.edit,
        cupertinoIcon: CupertinoIcons.pencil,
      ),
    );
  }
}
