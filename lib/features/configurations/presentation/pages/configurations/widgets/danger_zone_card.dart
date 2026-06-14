import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/configurations/presentation/cubits/configurations/configurations_cubit.dart';
import 'package:clean_architecture/features/configurations/presentation/pages/configurations/widgets/configuration_item.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DangerZoneCard extends StatelessWidget {
  const DangerZoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfigurationItem(
      platformIcon: PlatformIcon(
        materialIcon: Icons.warning_amber_rounded,
        cupertinoIcon: CupertinoIcons.exclamationmark_triangle,
        color: context.colorScheme.error,
      ),
      title: 'Zona de Perigo'.hardcoded,
      subtitle:
          'Ações irreversíveis para a sua conta e dados locais.'.hardcoded,
      actionWidget: PrimaryButton(
        onTap: () => _showConfirmationDialog(context),
        text: 'Limpar Cache do Aplicativo'.hardcoded,
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showAlertDialog(
      context: context,
      title: 'Limpar Cache?'.hardcoded,
      contentText:
          'Tem certeza de que deseja limpar todos os dados locais? '.hardcoded +
          'Você será desconectado e as preferências serão resetadas.'.hardcoded,
      defaultActionText: 'Limpar'.hardcoded,
      cancelActionText: 'Cancelar'.hardcoded,
      onOkPressed: context.read<ConfigurationsCubit>().clearAppCache,
    );
  }
}
