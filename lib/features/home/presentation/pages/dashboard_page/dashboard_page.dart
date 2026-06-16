import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/quick_action_button.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/recent_work_order_tile.dart';
import 'package:clean_architecture/features/home/presentation/pages/dashboard_page/widgets/stats_card.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
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

    final theme = context.theme;

    //TODO create default button because it is repeating in all tab pages
    final drawerButton = BaseIconButton(
      onPressed: Scaffold.of(context).openDrawer,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.menu,
        cupertinoIcon: CupertinoIcons.bars,
      ),
    );

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        Widget body;
        if (state.status == StateStatus.loading) {
          body = const LoadingCircle();
        }

        if (state.status == StateStatus.error) {
          body = Center(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.p16),
              child: Text(
                state.errorMessage ?? 'Erro desconhecido'.hardcoded,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          body = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gapH16,
              //TODO check this page and reduce the size creating more widgets
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: Sizes.p8,
                    mainAxisSpacing: Sizes.p8,
                    childAspectRatio: constraints.maxWidth > 350 ? 1.0 : 0.8,
                    children: [
                      StatsCard(
                        title: 'Abertas'.hardcoded,
                        value: state.openWorkOrdersCount.toString(),
                        icon: const PlatformIcon(
                          materialIcon: Icons.assignment_outlined,
                          cupertinoIcon: CupertinoIcons.list_bullet,
                        ),
                        color: Colors.blue,
                      ),
                      StatsCard(
                        title: 'Andamento'.hardcoded,
                        value: state.inProgressWorkOrdersCount.toString(),
                        icon: const PlatformIcon(
                          materialIcon: Icons.play_arrow_outlined,
                          cupertinoIcon: CupertinoIcons.play_circle,
                        ),
                        color: Colors.amber,
                      ),
                      StatsCard(
                        title: 'Revisões'.hardcoded,
                        value: state.pendingRevisionsCount.toString(),
                        icon: const PlatformIcon(
                          materialIcon: Icons.warning_amber_outlined,
                          cupertinoIcon:
                              CupertinoIcons.exclamationmark_triangle,
                        ),
                        color: Colors.orange,
                      ),
                    ],
                  );
                },
              ),
              gapH24,
              Text(
                'Ações Rápidas'.hardcoded,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              gapH12,
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: Sizes.p12,
                mainAxisSpacing: Sizes.p12,
                childAspectRatio: 2.8,
                children: [
                  QuickActionButton(
                    label: 'Nova Ordem'.hardcoded,
                    icon: const Icon(Icons.add_task),
                    onTap: () {
                      // Handled by user navigation
                    },
                  ),
                  QuickActionButton(
                    label: 'Novo Equipamento'.hardcoded,
                    icon: const Icon(Icons.add_box_outlined),
                    onTap: () {
                      // Handled by user navigation
                    },
                  ),
                ],
              ),
              gapH24,
              Text(
                'Ordens Recentes'.hardcoded,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              gapH12,
              if (state.recentWorkOrders.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Sizes.p24),
                    child: Text(
                      'Nenhuma ordem de serviço recente.'.hardcoded,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...state.recentWorkOrders.map(
                  (workOrder) => RecentWorkOrderTile(
                    workOrder: workOrder,
                    onTap: () {
                      // Handled by user navigation
                    },
                  ),
                ),
              gapH16,
            ],
          );
        }

        return BaseScaffold(
          appBar: BaseAppBar(title: 'Painel'.hardcoded, leading: drawerButton),
          onRefresh: cubit.loadDashboardData,
          scrollPhysics: const AlwaysScrollableScrollPhysics(),
          body: body,
        );
      },
    );
  }
}
