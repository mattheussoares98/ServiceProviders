import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/configurations/presentation/cubits/configurations/configurations_cubit.dart';
import 'package:clean_architecture/features/configurations/presentation/pages/configurations/widgets/configuration_item.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_switch.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          return DefaultSwitch(
            title:
                'Receber alertas e atualizações de ordens de serviço'.hardcoded,
            value: state.configurations.pushNotificationsEnabled,
            onChanged: context
                .read<ConfigurationsCubit>()
                .togglePushNotifications,
          );
        },
      ),
    );
  }
}
