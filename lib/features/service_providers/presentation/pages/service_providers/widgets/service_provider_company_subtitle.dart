import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/extensions/service_provider_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_rich_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ServiceProviderCompanySubtitle extends StatelessWidget {
  const ServiceProviderCompanySubtitle({super.key, required this.company});

  final ServiceProviderCompanyEntity company;

  @override
  Widget build(BuildContext context) {
    final invitations = context.read<ServiceProvidersCubit>().state.invitations;
    final hasPendingInvitation =
        invitations[company.id]?.any(
          (inv) =>
              inv.serviceProviderCompanyId == company.id &&
              inv.email != company.contactEmail &&
              inv.status == ServiceProviderInvitationStatus.pending,
        ) ??
        false;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        if (company.contactEmail?.isNotEmpty ?? false)
          BaseRichText(
            texts: [
              BaseText.title(
                company.contactEmail!,
                color: company.invitationStatus?.color,
              ),
              gapW8,
              if (company.invitationStatus == null)
                BaseTextButton(
                  text: 'Convidar'.hardcoded,
                  platformIcon: const PlatformIcon(
                    materialIcon: Icons.mail,
                    cupertinoIcon: CupertinoIcons.mail,
                  ),
                  onPressed: () {
                    showAlertDialog(
                      context: context,
                      title: 'Enviar convite'.hardcoded,
                      contentText:
                          'Deseja enviar o convite para ${company.contactEmail}?\n\n'
                                  'Após aceitar o convite, o prestador conseguirá manipular ordens de serviço atreladas a ele'
                              .hardcoded,
                      defaultActionText: 'Sim'.hardcoded,
                      cancelActionText: 'Não'.hardcoded,
                      onOkPressed: () {
                        context.read<ServiceProvidersCubit>().sendInvitation(
                          serviceProviderCompanyId: company.id,
                          email: company.contactEmail!,
                        );
                      },
                    );
                  },
                )
              else if (company.invitationStatus !=
                  ServiceProviderInvitationStatus.accepted)
                BaseText(
                  'Convite ${company.invitationStatus!.label.toLowerCase()}'
                      .hardcoded,
                  color: company.invitationStatus!.color,
                ),
            ],
          ),

        if (hasPendingInvitation)
          BaseText.bodySmall('Há convite(s) pendente(s)'.hardcoded),
        if (company.contactPhone != null &&
            company.contactPhone!.isNotEmpty) ...[
          TitleAndSubtitle(
            title: 'Telefone'.hardcoded,
            subtitle: company.contactPhone,
          ),
        ],
        TitleAndSubtitle(
          title: company.documentType.name.toUpperCase(),
          subtitle: company.document,
        ),
      ],
    );
  }
}
