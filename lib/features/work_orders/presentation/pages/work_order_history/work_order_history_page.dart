import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_log_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_history/work_order_history_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_history/widgets/history_date_filter_bar.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_history/widgets/history_timeline_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

@RoutePage()
class WorkOrderHistoryPage extends StatelessWidget {
  const WorkOrderHistoryPage({super.key, required this.workOrderId});

  final String workOrderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.I<WorkOrderHistoryCubit>()..loadHistory(workOrderId),
      child: Builder(
        builder: (context) {
          return BaseScaffold(
            isScrollable: false,
            onRefresh: () => context.read<WorkOrderHistoryCubit>().loadHistory(
              workOrderId,
              showLoading: false,
            ),
            appBar: BaseAppBar(title: 'Histórico de alterações'.hardcoded),
            body: Column(
              children: [
                const HistoryDateFilterBar(),
                Expanded(
                  child:
                      BaseStateView<
                        WorkOrderHistoryCubit,
                        WorkOrderHistoryState,
                        List<AuditLogEntity>
                      >(
                        dataSelector: (state) => state.filteredHistory,
                        onRetry: () => context
                            .read<WorkOrderHistoryCubit>()
                            .loadHistory(workOrderId),
                        builder: (context, history) {
                          if (history.isEmpty) {
                            return Center(
                              child: BaseText.bodySmall(
                                'Nenhum registro encontrado'.hardcoded,
                                fontStyle: FontStyle.italic,
                              ),
                            );
                          }

                          return ResponsiveListFlow(
                            itemCount: history.length,
                            padding: const EdgeInsets.all(Sizes.p16),
                            itemBuilder: (context, index) {
                              final item = history[index];
                              final isLast = index == history.length - 1;
                              return HistoryTimelineItem(
                                item: item,
                                isLast: isLast,
                              );
                            },
                          );
                        },
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
