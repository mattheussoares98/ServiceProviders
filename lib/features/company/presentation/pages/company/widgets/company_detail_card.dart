import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class CompanyDetailCard extends StatelessWidget {
  const CompanyDetailCard({required this.company, super.key});

  final CompanyEntity company;

  void _showImageSourcePicker(BuildContext context) {
    showModalPage<void>(
      Padding(
        padding: const EdgeInsets.fromLTRB(Sizes.p24, Sizes.p8, Sizes.p24, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BaseText.title(
                'Alterar logo da empresa'.hardcoded,
                textAlign: .center,
              ),
            ),
            if (PlatformUtil.isMobile) ...[
              gapH16,
              BaseListTile(
                padding: EdgeInsets.zero,
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.camera_alt_outlined,
                  cupertinoIcon: CupertinoIcons.camera,
                ),
                title: 'Tirar foto'.hardcoded,
                onTap: () {
                  Navigator.pop(context);
                  context.read<CompanyCubit>().changeLogo(
                    AttachmentSource.cameraPhoto,
                  );
                },
              ),
            ],
            const Divider(height: 1),
            BaseListTile(
              padding: EdgeInsets.zero,
              platformIcon: const PlatformIcon(
                materialIcon: Icons.photo_library_outlined,
                cupertinoIcon: CupertinoIcons.photo,
              ),
              title: 'Escolher da galeria'.hardcoded,
              onTap: () {
                Navigator.pop(context);
                context.read<CompanyCubit>().changeLogo(
                  AttachmentSource.gallery,
                );
              },
            ),
          ],
        ),
      ),
      context,
      useDraggable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? cnpj = company.cnpj;
    final String formattedCnpj = (cnpj != null && cnpj.isNotEmpty)
        ? CNPJValidator.format(cnpj)
        : 'CNPJ não informado'.hardcoded;

    final logoUrl = company.logoUrl;
    final isAdmin = context.select<SessionCubit, bool>(
      (cubit) => cubit.state.user.isAdmin,
    );
    final isSaving = context.select<CompanyCubit, bool>(
      (cubit) => cubit.state.status == StateStatus.saving,
    );

    return Container(
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(Sizes.p16),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Flexible(
            child: Stack(
              children: [
                BaseImageWidget(
                  source: BaseImageSource.network(logoUrl),
                  enableFullScreenOnTap: true,
                  heroTag: '${company.id}_logo',
                  width: 120,
                  height: 120,
                ),
                if (isSaving)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(Sizes.p8),
                      ),
                      child: const Center(child: LoadingCircle()),
                    ),
                  )
                else if (isAdmin)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Material(
                      color: context.colorScheme.primary,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _showImageSourcePicker(context),
                        child: const Padding(
                          padding: EdgeInsets.all(Sizes.p8),
                          child: PlatformIcon(
                            materialIcon: Icons.camera_alt,
                            cupertinoIcon: CupertinoIcons.camera_fill,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          gapW16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseText.titleMedium(company.name, fontWeight: FontWeight.bold),
                gapH4,
                BaseText.bodyMedium(
                  formattedCnpj,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
