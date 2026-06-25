import 'dart:async';

import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteAssetButton extends StatelessWidget {
  const DeleteAssetButton({super.key, required this.assetId});
  final String assetId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AssetsCubit, AssetsState, bool>(
      selector: (state) => state.deletingIds.contains(assetId),
      builder: (context, isLoading) {
        return BaseTextButton(
          isLoading: isLoading,
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
              unawaited(context.read<AssetsCubit>().deleteAsset(assetId));
            }
          },
          text: 'Excluir'.hardcoded,
          textColor: AppColors.error,
        );
      },
    );
  }
}
