import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/material.dart';

class BaseDrawerItem extends StatelessWidget {
  const BaseDrawerItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.platformIcon,
    this.closeAutomatically = true,
  });
  final bool closeAutomatically;
  final VoidCallback onTap;
  final String title;
  final PlatformIcon platformIcon;

  @override
  Widget build(BuildContext context) {
    return BaseListTile(
      title: title,
      platformIcon: platformIcon,
      onTap: () {
        if (closeAutomatically) {
          Navigator.of(context).pop();
        }
        onTap();
      },
    );
  }
}
