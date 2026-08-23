import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/services/sync_engine.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class WorkOrderSyncErrorBanner extends HookWidget {
  const WorkOrderSyncErrorBanner({required this.workOrder, super.key});

  final WorkOrderEntity workOrder;
  @override
  Widget build(BuildContext context) {
    final engine = GetIt.I<SyncEngine>();
    final stream = useMemoized(
      () => engine.watchDeadLetterItemsForEntity(workOrder.id),
      [engine, workOrder.id],
    );
    final snapshot = useStream<List<SyncQueueItemEntity>>(
      stream,
      initialData: const [],
    );

    final deadLetterItems = snapshot.data ?? const [];
    final isRetrying = useState(false);

    if (deadLetterItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final lastErrorMessage = deadLetterItems
        .map((e) => e.lastError)
        .firstWhere((err) => err != null && err.isNotEmpty, orElse: () => null);

    final bannerColor = AppColors.error.withValues(alpha: 0.1);
    final borderColor = AppColors.error.withValues(alpha: 0.7);

    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.p8),
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PlatformIcon(
                materialIcon: Icons.sync_problem_rounded,
                cupertinoIcon: CupertinoIcons.exclamationmark_triangle_fill,
                color: AppColors.error,
              ),
              gapW8,
              Expanded(
                child: BaseText.title('Falha na sincronização'.hardcoded),
              ),
            ],
          ),
          gapH8,
          BaseText(
            'As alterações feitas offline não puderam ser sincronizadas com o servidor.'
                .hardcoded,
          ),
          if (lastErrorMessage != null) ...[
            gapH4,
            BaseText(
              lastErrorMessage,
              textType: TextType.caption,
              color: AppColors.error,
            ),
          ],
          gapH12,
          Align(
            alignment: Alignment.centerRight,
            child: BaseButton(
              color: AppColors.error,
              text: 'Tentar novamente'.hardcoded,
              isLoading: isRetrying.value,
              onTap: () async {
                isRetrying.value = true;
                try {
                  await engine.retryEntity(workOrder.id);
                } finally {
                  isRetrying.value = false;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
