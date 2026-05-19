import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/constants/app_icons.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingItems extends StatelessWidget {
  const SettingItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(Sizes.p12)),
        boxShadow: [BoxShadow(color: AppColors.black15, blurRadius: 24)],
      ),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: const [SettingsItem()],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        onTap: () {},
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Sizes.p12)),
          side: BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Sizes.p16,
          vertical: Sizes.p8,
        ),
        horizontalTitleGap: 8,
        leading: const PlatformIcon(
          materialIcon: AppIcons.lock,
          cupertinoIcon: CupertinoIcons.lock_fill,
          size: 22,
        ),
        title: BaseText.bodyLarge('Alterar senha'.hardcoded),
        trailing: const PlatformIcon(
          materialIcon: AppIcons.arrowRight,
          cupertinoIcon: CupertinoIcons.chevron_forward,
          size: 22,
        ),
      ),
    );
  }
}
