import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showCloseAppDialog(BuildContext context) {
  showDialog<dynamic>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Prestadores de serviço APP'.hardcoded),
        content: Text('Tem certeza que deseja fechar o aplicativo?'.hardcoded),
        actionsPadding: const EdgeInsets.all(Sizes.p16),
        actions: [
          PrimaryButton(
            height: 40,
            width: 80,
            onTap: () async => Navigator.pop(dialogContext),
            text: 'Não'.hardcoded,
          ),
          gapH4,
          PrimaryButton(
            height: 40,
            width: 80,
            color: AppColors.red600,
            onTap: () async {
              Navigator.pop(dialogContext);
              await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            text: 'Sim'.hardcoded,
          ),
        ],
      );
    },
  );
}
