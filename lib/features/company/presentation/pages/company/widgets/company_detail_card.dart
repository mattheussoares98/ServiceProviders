import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

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
          Flexible(
            child: BaseImageWidget(
              source: BaseImageSource.network(logoUrl),
              enableFullScreenOnTap: true,
              heroTag: '${company.id}_logo',
              width: 120,
              height: 120,
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
