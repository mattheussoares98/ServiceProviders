import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/constants/app_icons.dart';
import 'package:clean_architecture/features/dashboard/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseBottomNavigation extends StatelessWidget {
  const BaseBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final materialIcons = [AppIcons.home, AppIcons.setting];
    final cupertinoIcons = [CupertinoIcons.house_fill, CupertinoIcons.settings];

    return Container(
      height: 50,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Sizes.p16),
        boxShadow: const [
          BoxShadow(color: AppColors.black10, spreadRadius: 2, blurRadius: 4),
        ],
      ),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.activeIndex != current.activeIndex,
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(materialIcons.length, (index) {
              return BaseIconButton(
                onPressed: () => context.read<DashboardCubit>().setIndex(index),
                visualDensity: VisualDensity.standard,
                padding: const EdgeInsets.all(Sizes.p8),
                platformIcon: PlatformIcon(
                  materialIcon: materialIcons[index],
                  cupertinoIcon: cupertinoIcons[index],
                  size: 20,
                  color: index == state.activeIndex
                      ? AppColors.primary
                      : AppColors.fade.withAlpha(153),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
