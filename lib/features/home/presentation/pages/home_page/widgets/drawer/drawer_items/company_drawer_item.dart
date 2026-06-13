import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_drawer_item.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompanyDrawerItem extends StatelessWidget {
  const CompanyDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDrawerItem(
      onTap: context.read<HomeCubit>().navigateToCompany,
      title: 'Empresa'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.business,
        cupertinoIcon: CupertinoIcons.building_2_fill,
      ),
    );
  }
}
