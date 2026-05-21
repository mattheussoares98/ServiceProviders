import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/constants/app_icons.dart';
import 'package:clean_architecture/features/dashboard/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:clean_architecture/features/dashboard/presentation/pages/dashboard/widgets/dashboard_drawer.dart';
import 'package:clean_architecture/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_bottom_navigation_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/screen_util/screen_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetIt.I<DashboardCubit>()..initialize(),
        ),
      ],
      child: BlocBuilder<ScreenObserverCubit, ScreenObserverState>(
        buildWhen: (previous, current) =>
            previous.desktopLayoutChanges != current.desktopLayoutChanges,
        builder: (context, observerState) {
          final isDesktopLargeScreen = ScreenUtil.I.isWebDesktopScreen;
          return BlocBuilder<DashboardCubit, DashboardState>(
            buildWhen: (previous, current) =>
                previous.activeIndex != current.activeIndex,
            builder: (context, dashboardState) {
              return BaseScaffold(
                isScrollable: false,
                usePadding: false,
                useBottomNavigationPadding: false,
                bottomNavigationItems: !isDesktopLargeScreen
                    ? const [
                        BaseBottomNavigationBarItem(
                          platformIcon: PlatformIcon(
                            materialIcon: AppIcons.home,
                            cupertinoIcon: CupertinoIcons.house_fill,
                          ),
                          label: 'Home',
                        ),
                        BaseBottomNavigationBarItem(
                          platformIcon: PlatformIcon(
                            materialIcon: AppIcons.setting,
                            cupertinoIcon: CupertinoIcons.settings,
                          ),
                          label: 'Configurações',
                        ),
                      ]
                    : null,
                bottomNavigationIndex: !isDesktopLargeScreen
                    ? dashboardState.activeIndex
                    : null,
                onBottomNavigationTap: !isDesktopLargeScreen
                    ? (index) => context.read<DashboardCubit>().setIndex(index)
                    : null,
                body: Row(
                  children: [
                    if (isDesktopLargeScreen) const DashboardDrawer(),
                    Flexible(
                      child: Container(
                        color: AppColors.surface,
                        child: const AutoRouter(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
