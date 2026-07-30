import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/extensions/service_provider_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ServiceProvidersInvitationsItems extends StatelessWidget {
  const ServiceProvidersInvitationsItems({super.key, required this.companyId});
  final String companyId;

  @override
  Widget build(BuildContext context) {
    final company = context
        .select<ServiceProvidersCubit, ServiceProviderCompanyEntity?>(
          (cubit) =>
              cubit.state.companies.firstWhereOrNull((c) => c.id == companyId),
        );

    return BlocBuilder<ServiceProvidersCubit, ServiceProvidersState>(
      builder: (context, state) {
        final invitations = state.invitations[companyId] ?? [];
        final profiles = state.profiles[companyId] ?? [];

        final hasPending = invitations.any(
          (i) => i.status == ServiceProviderInvitationStatus.pending,
        );
        final hasAccepted =
            invitations.any(
              (i) => i.status == ServiceProviderInvitationStatus.accepted,
            ) ||
            profiles.isNotEmpty;
        final hasEmail =
            company?.contactEmail != null && company!.contactEmail!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BaseText.title('Usuários e Convites'.hardcoded),
                if (!hasPending && !hasAccepted && hasEmail)
                  BaseTextButton(
                    text: 'Convidar por e-mail'.hardcoded,
                    onPressed: () {
                      context.read<ServiceProvidersCubit>().sendInvitation(
                        serviceProviderCompanyId: companyId,
                        email: company.contactEmail!,
                      );
                    },
                  ),
              ],
            ),
            gapH8,
            if (invitations.isEmpty && profiles.isEmpty)
              BaseText.bodySmall(
                'Nenhum usuário ou convite registrado'.hardcoded,
              )
            else ...[
              // Render Profiles (Active Users)
              ...profiles.map(
                (profile) => BaseListTile(
                  title: profile.name,
                  subtitle: profile.email,
                  platformIcon: const PlatformIcon(
                    materialIcon: Icons.person,
                    cupertinoIcon: CupertinoIcons.person,
                    color: Colors.green,
                  ),
                  trailing: Chip(
                    backgroundColor: Colors.green.shade50,
                    label: BaseText.bodySmall(
                      'Ativo'.hardcoded,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ),
              // Render Invitations (Pending/Accepted/Expired)
              ...invitations
                  .where(
                    (inv) => !profiles.any(
                      (p) => p.email.toLowerCase() == inv.email.toLowerCase(),
                    ),
                  )
                  .map((invitation) {
                    final isPending =
                        invitation.status ==
                        ServiceProviderInvitationStatus.pending;

                    return BaseListTile(
                      title: invitation.email,
                      subtitle: invitation.acceptedAt != null
                          ? 'Aceito em ${invitation.acceptedAt!.day.toString().padLeft(2, '0')}/${invitation.acceptedAt!.month.toString().padLeft(2, '0')}/${invitation.acceptedAt!.year}'
                                .hardcoded
                          : 'Enviado em ${invitation.createdAt.day.toString().padLeft(2, '0')}/${invitation.createdAt.month.toString().padLeft(2, '0')}/${invitation.createdAt.year}'
                                .hardcoded,
                      platformIcon: invitation.status.platformIcon.copyWith(
                        color: invitation.status.color,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            backgroundColor: invitation.status.color.withValues(
                              alpha: 0.1,
                            ),
                            label: BaseText.bodySmall(
                              invitation.status.label,
                              color: invitation.status.color,
                            ),
                          ),
                          if (isPending) ...[
                            gapW8,
                            BaseIconButton(
                              platformIcon: const PlatformIcon(
                                materialIcon: Icons.delete_outline,
                                cupertinoIcon: CupertinoIcons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                context
                                    .read<ServiceProvidersCubit>()
                                    .deleteInvitation(
                                      invitationId: invitation.id,
                                      serviceProviderCompanyId: companyId,
                                    );
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
            ],
          ],
        );
      },
    );
  }
}
