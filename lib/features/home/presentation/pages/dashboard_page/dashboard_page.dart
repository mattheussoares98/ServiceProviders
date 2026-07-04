import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/active_work_items.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/fast_actions.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/hello_user.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/not_closed_work_orders.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/recent_work_orders.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (context) => GetIt.I<DashboardCubit>(),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends HookWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    useEffect(() {
      cubit.loadDashboardData();
      return null;
    }, []);

    //TODO create default button because it is repeating in all tab pages
    final drawerButton = BaseIconButton(
      onPressed: Scaffold.of(context).openDrawer,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.menu,
        cupertinoIcon: CupertinoIcons.bars,
      ),
    );

    return BlocListener<WorkOrdersCubit, WorkOrdersState>(
      listenWhen: (previous, current) =>
          (previous.status == StateStatus.saving ||
              previous.status == StateStatus.deleting) &&
          current.status == StateStatus.loaded,
      listener: (context, state) {
        cubit.loadDashboardData();
      },
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          Widget body;
          if (state.status == StateStatus.loading) {
            body = const LoadingCircle();
          }

          if (state.status == StateStatus.loadingError) {
            body = Center(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.p16),
                child: BaseText.error(
                  state.errorMessage ?? 'Erro desconhecido'.hardcoded,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            body = const Column(
              crossAxisAlignment: .start,
              children: [
                HelloUser(),
                ActiveWorkItems(),
                NotClosedWorkOrders(),
                FastActions(),
                RecentWorkOrders(),
              ],
            );
          }

          return BaseScaffold(
            padding: const EdgeInsets.all(Sizes.p12),
            appBar: BaseAppBar(
              title: 'Painel'.hardcoded,
              leading: drawerButton,
            ),
            onRefresh: cubit.loadDashboardData,
            scrollPhysics: const AlwaysScrollableScrollPhysics(),
            body: body,
          );
        },
      ),
    );
  }
}
