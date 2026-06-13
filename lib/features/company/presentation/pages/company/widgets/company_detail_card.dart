import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompanyDetailCard extends StatelessWidget {
  const CompanyDetailCard({required this.company, super.key});

  final CompanyEntity company;

  @override
  Widget build(BuildContext context) {
    final String? cnpj = company.cnpj;
    final String formattedCnpj = (cnpj != null && cnpj.isNotEmpty)
        ? CNPJValidator.format(cnpj)
        : 'CNPJ não informado'.hardcoded;

    final logoUrl = company.logoUrl;

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
          Container(
            width: Sizes.p64,
            height: Sizes.p64,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer.withValues(
                alpha: 0.2,
              ),
              borderRadius: BorderRadius.circular(Sizes.p12),
            ),
            clipBehavior: Clip.antiAlias,
            child: logoUrl != null && logoUrl.isNotEmpty
                ? Image.network(
                    //TODO centralize where will show images to improve it
                    logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.business,
                      size: Sizes.p32,
                      color: context.colorScheme.primary,
                    ),
                  )
                : PlatformIcon(
                    cupertinoIcon: CupertinoIcons.building_2_fill,
                    materialIcon: Icons.business,
                    size: Sizes.p32,
                    color: context.colorScheme.primary,
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
