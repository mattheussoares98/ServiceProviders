import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/extensions/service_provider_extensions.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
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
        final hasAccepted = invitations.any(
          (i) => i.status == ServiceProviderInvitationStatus.accepted,
        );
        final hasEmail =
            company?.contactEmail != null && company!.contactEmail!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseText.title('Usuários e convites'.hardcoded),
            gapH8,
            ...profiles.map((profile) {
              final correspondingInvitation = invitations.firstWhereOrNull(
                (e) => e.email == profile.email,
              );
              final isPendingInvitation =
                  correspondingInvitation?.status ==
                  ServiceProviderInvitationStatus.pending;

              return Column(
                crossAxisAlignment: .end,
                children: [
                  Row(
                    crossAxisAlignment: .end,
                    children: [
                      PlatformIcon(
                        materialIcon: Icons.person,
                        cupertinoIcon: CupertinoIcons.person,
                        color: correspondingInvitation?.status.color,
                      ),
                      gapW8,
                      Expanded(child: BaseText.title(profile.name)),
                    ],
                  ),
                  if (!hasPending && !hasAccepted && hasEmail)
                    BaseTextButton(
                      permission: const ActionPermission.resource(
                        resource: ResourceType.serviceProviders,
                        action: PermissionAction.update,
                      ),
                      text: 'Convidar por e-mail'.hardcoded,
                      onPressed: () {
                        context.read<ServiceProvidersCubit>().sendInvitation(
                          serviceProviderCompanyId: companyId,
                          email: company.contactEmail!,
                        );
                      },
                    ),
                  if (correspondingInvitation != null)
                    Row(
                      mainAxisAlignment: .end,
                      children: [
                        BaseText.caption(
                          correspondingInvitation.status.label,
                          color: correspondingInvitation.status.color,
                          fontWeight: FontWeight.bold,
                          fontStyle: .italic,
                        ),
                        if (isPendingInvitation) ...[
                          gapW8,
                          BaseIconButton(
                            platformIcon: const PlatformIcon(
                              materialIcon: Icons.delete_outline,
                              cupertinoIcon: CupertinoIcons.delete,
                              color: Colors.red,
                            ),
                            permission: const ResourceActionPermission(
                              resource: ResourceType.serviceProviders,
                              action: PermissionAction.delete,
                            ),
                            onPressed: () {
                              showAlertDialog(
                                context: context,
                                title: 'Atenção'.hardcoded,
                                contentText:
                                    'Tem certeza que deseja excluir o convite?'
                                        .hardcoded,
                                defaultActionText: 'Sim'.hardcoded,
                                cancelActionText: 'Não'.hardcoded,
                                onOkPressed: () => context
                                    .read<ServiceProvidersCubit>()
                                    .deleteInvitation(
                                      invitationId: correspondingInvitation.id,
                                      serviceProviderCompanyId: companyId,
                                    ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                ],
              );
            }),
          ],
        );
      },
    );
  }
}
