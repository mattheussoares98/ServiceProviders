import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/active_work_items.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/fast_actions.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/hello_user.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/not_closed_work_orders.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/recent_work_orders.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workOrdersCubit = context.read<WorkOrdersCubit>();

    return BaseScaffold(
      isScrollable: false,
      padding: const EdgeInsets.all(Sizes.p8),
      appBar: BaseAppBar(
        title: 'Painel'.hardcoded,
        leading: const OpenDrawerIconButton(),
      ),
      onRefresh: workOrdersCubit.loadWorkOrdersAndChangeRequests,
      body: BlocBuilder<WorkOrdersCubit, WorkOrdersState>(
        builder: (context, state) {
          if (state.status == StateStatus.loading && state.workOrders.isEmpty) {
            return const LoadingCircle();
          }

          if (state.status == StateStatus.loadingError &&
              state.workOrders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.p16),
                child: BaseText.error(
                  state.errorMessage != null && state.errorMessage!.isNotEmpty
                      ? state.errorMessage!
                      : 'Erro ao carregar dados'.hardcoded,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return const CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: HelloUser()),
              SliverToBoxAdapter(child: ActiveWorkItems()),
              SliverToBoxAdapter(child: NotClosedWorkOrders()),
              SliverToBoxAdapter(child: FastActions()),
              RecentWorkOrders(),
            ],
          );
        },
      ),
    );
  }
}

