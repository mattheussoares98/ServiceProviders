import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class CompanySwitcherSection extends StatelessWidget {
  const CompanySwitcherSection({
    required this.companies,
    required this.selectedCompanyId,
    super.key,
  });

  final List<CompanyEntity> companies;
  final String? selectedCompanyId;

  @override
  Widget build(BuildContext context) {
    if (companies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gapH16,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.p8),
          child: BaseText.titleMedium(
            'Alternar Empresa'.hardcoded,
            color: context.colorScheme.onSurface,
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.p16),
            side: BorderSide(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: companies.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: Sizes.p64,
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final company = companies[index];
              final isSelected = company.id == selectedCompanyId;

              return ListTile(
                contentPadding: const .symmetric(horizontal: Sizes.p8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.p16),
                ),
                horizontalTitleGap: Sizes.p12,
                leading: SizedBox(
                  width: Sizes.p40,
                  height: Sizes.p40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Sizes.p4),
                    child:
                        company.logoUrl != null && company.logoUrl!.isNotEmpty
                        ? BaseImageWidget(
                            source: BaseImageSource.network(company.logoUrl),
                            enableFullScreenOnTap: true,
                          )
                        : Container(
                            color: context.colorScheme.primaryContainer,
                            child: PlatformIcon(
                              materialIcon: Icons.business,
                              cupertinoIcon: CupertinoIcons.building_2_fill,
                              color: context.colorScheme.primary,
                            ),
                          ),
                  ),
                ),
                title: BaseText.bodyLarge(
                  company.name,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                subtitle: company.cnpj != null && company.cnpj!.isNotEmpty
                    ? BaseText.caption(
                        CNPJValidator.format(company.cnpj!),
                        color: context.colorScheme.onSurfaceVariant,
                      )
                    : null,
                trailing: isSelected
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.p8,
                          vertical: Sizes.p4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(Sizes.p12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PlatformIcon(
                              materialIcon: Icons.check_circle,
                              cupertinoIcon:
                                  CupertinoIcons.checkmark_alt_circle_fill,
                              color: context.colorScheme.primary,
                              size: Sizes.p16,
                            ),
                            gapW4,
                            BaseText.caption(
                              'Ativa'.hardcoded,
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      )
                    : PlatformIcon(
                        materialIcon: Icons.radio_button_unchecked,
                        cupertinoIcon: CupertinoIcons.circle,
                        color: context.colorScheme.outline,
                        size: Sizes.p20,
                      ),
                onTap: isSelected
                    ? null
                    : () => context.read<CompanyCubit>().switchCompany(
                        company.id,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
