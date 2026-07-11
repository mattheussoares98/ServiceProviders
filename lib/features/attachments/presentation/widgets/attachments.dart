import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachment_item.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachment_source_sheet.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class Attachments extends StatelessWidget {
  const Attachments({
    super.key,
    required this.workOrderId,
    required this.isEditing,
  });
  final String workOrderId;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final (
      isLoading,
      attachments,
    ) = context.select<AttachmentsCubit, (bool, List<AttachmentEntity>)>(
      (cubit) =>
          (cubit.state.status == StateStatus.loading, cubit.state.attachments),
    );

    if (isLoading) {
      return const SliverToBoxAdapter(child: Center(child: LoadingCircle()));
    }

    return SliverMainAxisGroup(
      slivers: [
        gapSliverH8,
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ScreenType.phone.maxWidth),
              child: _AttachmentsAndAddRow(isEditing: isEditing),
            ),
          ),
        ),
        if (attachments.isEmpty) ...[
          SliverToBoxAdapter(child: _EmptyAttachment(isEditing: isEditing)),
          gapSliverH8,
        ],
        ResponsiveListFlow(
          isSliver: true,
          padding: EdgeInsets.zero,
          maxItemWidth: 170,
          useMultiColumnWhenMobile: true,
          itemCount: attachments.length,
          itemBuilder: (context, index) {
            final attachment = attachments[index];
            return AttachmentItem(attachment: attachment, isEditing: isEditing);
          },
        ),
      ],
    );
  }
}

class _AttachmentsAndAddRow extends StatelessWidget {
  const _AttachmentsAndAddRow({required this.isEditing});
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AttachmentsCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FittedBox(child: BaseText.titleMedium('Anexos'.hardcoded)),
        if (isEditing)
          Flexible(
            child: BaseTextButton(
              onPressed: () async {
                final source = await AttachmentSourceSheet.show(context);
                if (source != null && context.mounted) {
                  await cubit.pickAttachment(source);
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
  const _EmptyAttachment({required this.isEditing});
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEditing
          ? () async {
              final source = await AttachmentSourceSheet.show(context);
              if (source != null && context.mounted) {
                await context.read<AttachmentsCubit>().pickAttachment(source);
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
