import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/cubits/configurations/configurations_cubit.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/pages/configurations/widgets/configuration_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_switch.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsToggle extends StatelessWidget {
  const NotificationsToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfigurationItem(
      platformIcon: const PlatformIcon(
        materialIcon: Icons.notifications_none_outlined,
        cupertinoIcon: CupertinoIcons.bell,
      ),
      title: 'Notificações Push'.hardcoded,
      actionWidget: BlocBuilder<ConfigurationsCubit, ConfigurationsState>(
        builder: (context, state) {
          final isMobile = PlatformUtil.isMobile;
          final systemEnabled =
              !isMobile || state.configurations.systemNotificationsEnabled;
          final pushEnabled = state.configurations.pushNotificationsEnabled;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultSwitch(
                title: 'Receber alertas e atualizações de ordens de serviço'
                    .hardcoded,
                value: systemEnabled && pushEnabled,
                onChanged: (enabled) async {
                  if (!systemEnabled && isMobile) {
                    await openAppSettings();
                  } else {
                    await context
                        .read<ConfigurationsCubit>()
                        .togglePushNotifications(enabled);
                  }
                },
              ),
              if (!systemEnabled && isMobile) ...[
                gapH8,
                BaseTextButton(
                  onPressed: openAppSettings,
                  text:
                      'As notificações estão desativadas no sistema. Clique aqui para abrir as configurações do dispositivo.'
                          .hardcoded,
                  color: context.colorScheme.error,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
