import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_action.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

extension AccessLogActionUiExtension on AccessLogAction {
  String get label => switch (this) {
    AccessLogAction.login => 'Login'.hardcoded,
    AccessLogAction.logout => 'Logout'.hardcoded,
    AccessLogAction.appAccess => 'Acesso ao App'.hardcoded,
  };

  Color get color => switch (this) {
    AccessLogAction.login => Colors.green,
    AccessLogAction.logout => Colors.orange,
    AccessLogAction.appAccess => Colors.blue,
  };

  PlatformIcon get platformIcon => switch (this) {
    AccessLogAction.login => const PlatformIcon(
      materialIcon: Icons.login_rounded,
      cupertinoIcon: CupertinoIcons.arrow_right_to_line,
    ),
    AccessLogAction.logout => const PlatformIcon(
      materialIcon: Icons.logout_rounded,
      cupertinoIcon: CupertinoIcons.arrow_left_to_line,
    ),
    AccessLogAction.appAccess => const PlatformIcon(
      materialIcon: Icons.devices_outlined,
      cupertinoIcon: CupertinoIcons.device_phone_portrait,
    ),
  };
}
