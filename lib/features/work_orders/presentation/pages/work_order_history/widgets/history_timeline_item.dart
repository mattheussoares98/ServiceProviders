import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_entity_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_log_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_history/work_order_history_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/audit_change_ui_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

bool _isImageAttachment({String? fileType, String? fileName, String? fileUrl}) {
  if (fileType != null && fileType.toLowerCase() == 'image') {
    return true;
  }
  final target = (fileName ?? fileUrl ?? '').toLowerCase();
  return target.endsWith('.png') ||
      target.endsWith('.jpg') ||
      target.endsWith('.jpeg') ||
      target.endsWith('.webp') ||
      target.endsWith('.gif');
}

class HistoryTimelineItem extends StatelessWidget {
  const HistoryTimelineItem({
    super.key,
    required this.item,
    required this.isLast,
  });

  final AuditLogEntity item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final user = context.select<UsersCubit, UserProfileEntity?>(
      (cubit) => cubit.state.users.firstWhereOrNull((u) => u.id == item.userId),
    );

    final metadata = item.metadata;
    final fileUrl = metadata?.fileUrl;
    final fileName = metadata?.fileName;

    return Stack(
      children: [
        Positioned(
          left: Sizes.p8 + 5,
          top: 12,
          bottom: 0,
          child: isLast
              ? const SizedBox.shrink()
              : Container(width: 2, color: context.colorScheme.outlineVariant),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gapW8,
            Container(
              margin: const EdgeInsets.only(top: Sizes.p4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.primary,
              ),
            ),
            gapW8,
            // Content card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: Sizes.p8),
                padding: const EdgeInsets.all(Sizes.p8),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(Sizes.p12),
                  border: Border.all(color: context.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: BaseText.bodyMedium(
                            item.displayTitle.hardcoded,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        BaseText.caption(
                          item.createdAt.formatDate(.ddMMyyyyHHmmss),
                        ),
                      ],
                    ),
                    if (item.changes.isNotEmpty) ...[
                      gapH8,
                      ...item.changes
                          .where((change) => change.isDisplayable)
                          .map((change) {
                            final oldVal = change.localizedOldValue?.hardcoded;
                            final newVal = change.localizedNewValue?.hardcoded;
                            final showFieldLabel =
                                item.entityType !=
                                AuditEntityType.workOrderObservations;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: Sizes.p4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showFieldLabel)
                                    BaseText.bodySmall(
                                      change.localizedLabel.hardcoded,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  if (oldVal != null)
                                    BaseText.bodySmall(
                                      (item.action == 'deleted'
                                              ? oldVal
                                              : 'De: $oldVal')
                                          .hardcoded,
                                      color: context.colorScheme.error,
                                    ),
                                  if (newVal != null)
                                    BaseText.bodySmall(
                                      '${oldVal == null ? '' : 'Para: '}$newVal'
                                          .hardcoded,
                                      color: context.colorScheme.primary,
                                    )
                                  else if (oldVal != null &&
                                      item.action != 'deleted')
                                    BaseText.bodySmall(
                                      'Para: Nenhum'.hardcoded,
                                      color: context.colorScheme.outline,
                                    ),
                                ],
                              ),
                            );
                          }),
                    ],
                    if (fileUrl != null && fileUrl.isNotEmpty) ...[
                      gapH8,
                      if (_isImageAttachment(
                        fileType: metadata?.fileType,
                        fileName: fileName,
                        fileUrl: fileUrl,
                      )) ...[
                        Center(
                          child: BaseImageWidget(
                            source: BaseImageSource.network(fileUrl),
                            enableFullScreenOnTap: true,
                            heroTag: fileUrl + item.id,
                            height: 100,
                          ),
                        ),
                        gapH4,
                      ] else
                        FittedBox(
                          child: BaseTextButton(
                            text: (fileName != null && fileName.isNotEmpty)
                                ? 'Abrir anexo ($fileName)'.hardcoded
                                : 'Abrir anexo'.hardcoded,
                            platformIcon: const PlatformIcon(
                              materialIcon: Icons.attach_file,
                              cupertinoIcon: CupertinoIcons.paperclip,
                            ),
                            onPressed: () => context
                                .read<WorkOrderHistoryCubit>()
                                .openAttachmentUrl(fileUrl),
                          ),
                        ),
                    ],
                    gapH8,
                    BaseText.caption(
                      'Por: ${user?.name ?? item.userId ?? 'Sistema'}'
                          .hardcoded,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
