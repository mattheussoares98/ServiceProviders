import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/constants/app_icons.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/dashboard/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/screen_util/screen_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25.widthPart(max: 300),
      child: Material(
        color: AppColors.border,
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<DashboardCubit, DashboardState>(
                buildWhen: (previous, current) =>
                    previous.activeIndex != current.activeIndex,
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BaseText.headline('Dashboard'.hardcoded),
                      gapH16,
                      ListTile(
                        onTap: () => context.read<DashboardCubit>().setIndex(0),
                        visualDensity: VisualDensity.standard,
                        horizontalTitleGap: 8,
                        leading: PlatformIcon(
                          materialIcon: AppIcons.home,
                          cupertinoIcon: CupertinoIcons.house_fill,
                          size: 20,
                          color: state.activeIndex == 0
                              ? AppColors.primary
                              : AppColors.fade.withAlpha(153),
                        ),
                        title: BaseText(
                          'Home'.hardcoded,
                          color: state.activeIndex == 0
                              ? AppColors.primary
                              : AppColors.fade.withAlpha(153),
                        ),
                      ),
                      ListTile(
                        onTap: () => context.read<DashboardCubit>().setIndex(1),
                        visualDensity: VisualDensity.standard,
                        horizontalTitleGap: 8,
                        leading: PlatformIcon(
                          materialIcon: AppIcons.setting,
                          cupertinoIcon: CupertinoIcons.settings,
                          size: 20,
                          color: state.activeIndex == 1
                              ? AppColors.primary
                              : AppColors.fade.withAlpha(153),
                        ),
                        title: BaseText(
                          'Configurações'.hardcoded,
                          color: state.activeIndex == 1
                              ? AppColors.primary
                              : AppColors.fade.withAlpha(153),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
