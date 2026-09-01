import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachment_item.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachment_source_sheet.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

const _createAttachment = ActionPermission.resource(
  resourceType: ResourceType.attachments,
  permissionAction: PermissionAction.create,
);

class Attachments extends StatelessWidget {
  const Attachments({
    super.key,
    required this.isWorkOrderActive,
    this.padding,
    this.workOrderCompanyId,
    this.autoUpload = false,
  });

  /// Whether the work order still accepts evidence. Caller knowledge: this
  /// widget only knows the tenant, and the create form has no status at all.
  /// `attachments.create` / `attachments.delete` are enforced by the buttons
  /// themselves, so no caller can forget them.
  final bool isWorkOrderActive;
  final EdgeInsetsGeometry? padding;

  /// Tenant that owns the work order. Null while creating a new one.
  final String? workOrderCompanyId;

  /// Whether to automatically upload/delete attachments immediately (e.g. on details page)
  /// instead of deferring to the work order form save action.
  final bool autoUpload;

  @override
  Widget build(BuildContext context) {
    final (isLoading, hasError, errorMessage, attachments, processingCount) =
        context.select<
          AttachmentsCubit,
          (bool, bool, String?, List<AttachmentEntity>, int)
        >(
          (cubit) => (
            cubit.state.status == DataStatus.loading,
            cubit.state.status == DataStatus.loadingError,
            cubit.state.errorMessage,
            cubit.state.attachments,
            cubit.state.processingCount,
          ),
        );

    if (isLoading) {
      return const SliverToBoxAdapter(child: Center(child: LoadingCircle()));
    }

    if (hasError) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BaseText(
                  errorMessage ?? 'Erro ao carregar anexos'.hardcoded,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
                gapH8,
                BaseButton(
                  color: Colors.red,
                  onTap: () =>
                      context.read<AttachmentsCubit>().refreshAttachments(),
                  text: 'Tentar novamente'.hardcoded,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        gapSliverH8,
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ScreenType.phone.maxWidth),
              child: _AttachmentsAndAddRow(
                isWorkOrderActive: isWorkOrderActive,
                workOrderCompanyId: workOrderCompanyId,
                autoUpload: autoUpload,
              ),
            ),
          ),
        ),
        gapSliverH8,
        if (attachments.isEmpty && processingCount == 0) ...[
          SliverToBoxAdapter(
            child: _EmptyAttachment(
              isWorkOrderActive: isWorkOrderActive,
              workOrderCompanyId: workOrderCompanyId,
              autoUpload: autoUpload,
            ),
          ),
          gapSliverH8,
        ],
        ResponsiveListFlow(
          isSliver: true,
          maxItemWidth: 170,
          padding: padding,
          useMultiColumnWhenMobile: true,
          itemCount: attachments.length + processingCount,
          itemBuilder: (context, index) {
            if (index < attachments.length) {
              final attachment = attachments[index];
              return AttachmentItem(
                attachment: attachment,
                autoDelete: autoUpload,
              );
            }
            return const ProcessingAttachmentItem();
          },
        ),
      ],
    );
  }
}

class _AttachmentsAndAddRow extends StatelessWidget {
  const _AttachmentsAndAddRow({
    required this.isWorkOrderActive,
    required this.workOrderCompanyId,
    required this.autoUpload,
  });
  final bool isWorkOrderActive;
  final String? workOrderCompanyId;
  final bool autoUpload;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AttachmentsCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: BaseText.titleMedium('Anexos'.hardcoded)),
        if (isWorkOrderActive)
          Flexible(
            child: BaseTextButton(
              permission: _createAttachment,
              onPressed: () async {
                final source = await AttachmentSourceSheet.show(context);
                if (source != null && context.mounted) {
                  await cubit.pickAttachment(
                    source,
                    workOrderCompanyId: workOrderCompanyId,
                    autoUpload: autoUpload,
                  );
                }
              },
              text: 'Adicionar'.hardcoded,
              platformIcon: const PlatformIcon(
                materialIcon: Icons.add,
                cupertinoIcon: CupertinoIcons.add,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyAttachment extends StatelessWidget {
  const _EmptyAttachment({
    required this.isWorkOrderActive,
    required this.workOrderCompanyId,
    required this.autoUpload,
  });
  final bool isWorkOrderActive;
  final String? workOrderCompanyId;
  final bool autoUpload;

  @override
  Widget build(BuildContext context) {
    final canAdd =
        isWorkOrderActive && context.hasPermission(_createAttachment);

    return InkWell(
      onTap: canAdd
          ? () async {
              final source = await AttachmentSourceSheet.show(context);
              if (source != null && context.mounted) {
                await context.read<AttachmentsCubit>().pickAttachment(
                  source,
                  workOrderCompanyId: workOrderCompanyId,
                  autoUpload: autoUpload,
                );
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(Sizes.p24),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(Sizes.p12),
          border: Border.all(color: AppColors.dashedBorder),
        ),
        child: Column(
          children: [
            const PlatformIcon(
              materialIcon: Icons.cloud_upload_outlined,
              cupertinoIcon: CupertinoIcons.cloud_upload,
            ),
            gapH8,
            BaseText.bodyMedium('Nenhum anexo adicionado'.hardcoded),
          ],
        ),
      ),
    );
  }
}
