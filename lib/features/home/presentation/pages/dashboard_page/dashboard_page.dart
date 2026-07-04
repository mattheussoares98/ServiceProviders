import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/active_stopwatch_card.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/quick_action_button.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/stats_card.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/features/work_orders/presentation/widgets/work_order_item.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
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
            final userProfile = state.userProfile;
            final totalStats =
                state.openWorkOrdersCount +
                state.inProgressWorkOrdersCount +
                state.pendingRevisionsCount;

            body = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userProfile != null) ...[
                  gapH16,
                  BaseText.headline('Olá, ${userProfile.name}'.hardcoded),
                  BaseText(
                    userProfile.isAdmin
                        ? 'Administrador'.hardcoded
                        : 'Técnico de Manutenção'.hardcoded,
                  ),
                ],
                if (state.activeWorkOrders.isNotEmpty) ...[
                  gapH8,
                  BaseText.title('TRABALHOS EM ANDAMENTO'.hardcoded),
                  gapH4,
                  SizedBox(
                    height: 105,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.activeWorkOrders.length,
                      itemBuilder: (context, index) {
                        final workOrder = state.activeWorkOrders[index];
                        return Container(
                          width: 300,
                          padding: const EdgeInsets.only(right: Sizes.p8),
                          child: ActiveStopwatchCard(
                            workOrder: workOrder,
                            onTap: () => context.router.push(
                              CreateUpdateWorkOrderRoute(workOrder: workOrder),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  gapH20,
                ],
                Row(
                  children: [
                    Flexible(
                      child: StatsCard(
                        title: 'Abertas'.hardcoded,
                        value: state.openWorkOrdersCount.toString(),
                        icon: const PlatformIcon(
                          materialIcon: Icons.assignment_outlined,
                          cupertinoIcon: CupertinoIcons.list_bullet,
                        ),
                        color: Colors.blue,
                        onTap: () {},
                      ),
                    ),
                    gapW8,
                    Flexible(
                      child: StatsCard(
                        title: 'Andamento'.hardcoded,
                        value: state.inProgressWorkOrdersCount.toString(),
                        icon: const PlatformIcon(
                          materialIcon: Icons.play_arrow_outlined,
                          cupertinoIcon: CupertinoIcons.play_circle,
                        ),
                        color: Colors.amber,
                        onTap: () {},
                      ),
                    ),
                    gapW8,
                    Flexible(
                      child: StatsCard(
                        title: 'Revisões'.hardcoded,
                        value: state.pendingRevisionsCount.toString(),
                        icon: const PlatformIcon(
                          materialIcon: Icons.warning_amber_outlined,
                          cupertinoIcon:
                              CupertinoIcons.exclamationmark_triangle,
                        ),
                        color: Colors.orange,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                if (totalStats > 0) ...[
                  gapH12,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Sizes.p4),
                    child: SizedBox(
                      height: 6,
                      width: double.infinity,
                      child: Row(
                        children: [
                          if (state.openWorkOrdersCount > 0)
                            Expanded(
                              flex: state.openWorkOrdersCount,
                              child: Container(
                                color: Colors.blue.withValues(alpha: 0.8),
                              ),
                            ),
                          if (state.inProgressWorkOrdersCount > 0)
                            Expanded(
                              flex: state.inProgressWorkOrdersCount,
                              child: Container(
                                color: Colors.amber.withValues(alpha: 0.8),
                              ),
                            ),
                          if (state.pendingRevisionsCount > 0)
                            Expanded(
                              flex: state.pendingRevisionsCount,
                              child: Container(
                                color: Colors.orange.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                gapH24,
                BaseText.title('Ações rápidas'.hardcoded),
                gapH12,
                Row(
                  children: [
                    Flexible(
                      child: QuickActionButton(
                        label: 'Nova ordem'.hardcoded,
                        icon: const PlatformIcon(
                          materialIcon: Icons.add_task,
                          cupertinoIcon: CupertinoIcons.check_mark_circled,
                        ),
                        onTap: () =>
                            context.router.push(CreateUpdateWorkOrderRoute()),
                      ),
                    ),
                    gapW12,
                    Flexible(
                      child: QuickActionButton(
                        label: 'Novo equipamento'.hardcoded,
                        icon: const PlatformIcon(
                          materialIcon: Icons.add_box_outlined,
                          cupertinoIcon: CupertinoIcons.add_circled,
                        ),
                        onTap: () =>
                            context.router.push(CreateUpdateAssetRoute()),
                      ),
                    ),
                  ],
                ),
                gapH24,
                BaseText.title('Ordens recentes'.hardcoded),
                gapH12,
                if (state.recentWorkOrders.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Sizes.p24),
                      child: BaseText(
                        'Nenhuma ordem de serviço recente.'.hardcoded,
                      ),
                    ),
                  )
                else
                  ...state.recentWorkOrders.map(
                    (workOrder) => WorkOrderItem(workOrder: workOrder),
                  ),
                gapH16,
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
