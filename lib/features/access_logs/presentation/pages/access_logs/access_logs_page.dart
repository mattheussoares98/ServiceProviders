import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/presentation/cubits/access_logs/access_logs_cubit.dart';
import 'package:o_jogo_da_obra/features/access_logs/presentation/pages/access_logs/widgets/access_log_item_card.dart';
import 'package:o_jogo_da_obra/features/access_logs/presentation/pages/access_logs/widgets/access_logs_filter_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

@RoutePage()
class AccessLogsPage extends HookWidget {
  const AccessLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<AccessLogsCubit>()..loadInitialData(),
      child: const _Page(),
    );
  }
}

class _Page extends HookWidget {
  const _Page();

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          context.read<AccessLogsCubit>().loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return BaseScaffold(
      isScrollable: false,
      onRefresh: () => context.read<AccessLogsCubit>().refresh(),
      appBar: BaseAppBar(title: 'Logs de acesso'.hardcoded),
      body: Column(
        children: [
          const AccessLogsFilterBar(),
          gapH16,
          Expanded(
            child:
                BaseStateView<
                  AccessLogsCubit,
                  AccessLogsState,
                  List<AccessLogEntity>
                >(
                  dataSelector: (state) => state.logs,
                  onRetry: () =>
                      context.read<AccessLogsCubit>().loadInitialData(),
                  builder: (context, logs) {
                    if (logs.isEmpty) {
                      return Center(
                        child: BaseText.bodySmall(
                          'Nenhum log de acesso encontrado'.hardcoded,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }

                    return SizedBox(
                      width: ScreenUtil.I.type.maxWidth,
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          return AccessLogItemCard(log: logs[index]);
                        },
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
