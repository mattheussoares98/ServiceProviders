import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_switch.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.onTap,
  });

  factory SettingsItem.switchType({
    Key? key,
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
    PlatformIcon? leading,
  }) {
    return SettingsItem(
      key: key,
      title: title,
      leading: leading,
      onTap: onChanged != null ? () => onChanged(!value) : null,
      trailing: _SettingsItemSwitch(value: value, onChanged: onChanged),
    );
  }

  final String title;
  final PlatformIcon? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Sizes.p12)),
          side: BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Sizes.p16,
          vertical: Sizes.p8,
        ),
        horizontalTitleGap: 8,
        leading: leading,
        title: BaseText.bodyLarge(title),
        trailing: trailing,
      ),
    );
  }
}

class _SettingsItemSwitch extends StatelessWidget {
  const _SettingsItemSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DefaultSwitch(value: value, onChanged: onChanged);
  }
}
