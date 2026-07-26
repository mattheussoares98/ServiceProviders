import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
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
    final company = context.select(
      (ServiceProvidersCubit cubit) =>
          cubit.state.companies.firstWhereOrNull((c) => c.id == companyId),
    );
    //TODO read and test this page
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BaseText.title('Convites'.hardcoded),
            BlocSelector<
              ServiceProvidersCubit,
              ServiceProvidersState,
              List<ServiceProviderInvitationEntity>
            >(
              selector: (state) => state.invitations[companyId] ?? [],
              builder: (context, invitations) {
                final hasPending = invitations.any(
                  (i) => i.status == ServiceProviderInvitationStatus.pending,
                );
                final hasEmail =
                    company?.contactEmail != null &&
                    company!.contactEmail!.isNotEmpty;

                if (!hasPending && hasEmail) {
                  return BaseTextButton(
                    text: 'Convidar por E-mail'.hardcoded,
                    onPressed: () {
                      context.read<ServiceProvidersCubit>().sendInvitation(
                        serviceProviderCompanyId: companyId,
                        email: company.contactEmail!,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        gapH8,
        BlocSelector<
          ServiceProvidersCubit,
          ServiceProvidersState,
          List<ServiceProviderInvitationEntity>
        >(
          selector: (state) => state.invitations[companyId] ?? [],
          builder: (context, invitations) {
            if (invitations.isEmpty) {
              return BaseText.bodySmall('Nenhum convite enviado'.hardcoded);
            }

            return Column(
              children: invitations.map((invitation) {
                final isPendingOrExpired =
                    invitation.status ==
                        ServiceProviderInvitationStatus.pending ||
                    invitation.status ==
                        ServiceProviderInvitationStatus.expired;

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
                        label: BaseText.bodySmall(
                          invitation.status.label,
                          color: invitation.status.color,
                        ),
                        backgroundColor: invitation.status.color.withValues(
                          alpha: 0.12,
                        ),
                        side: BorderSide(
                          color: invitation.status.color.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.p4,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (isPendingOrExpired) ...[
                        gapW4,
                        BaseIconButton(
                          platformIcon: const PlatformIcon(
                            materialIcon: Icons.refresh,
                            cupertinoIcon: Icons.refresh,
                          ),
                          onPressed: () {
                            context
                                .read<ServiceProvidersCubit>()
                                .sendInvitation(
                                  serviceProviderCompanyId: companyId,
                                  email: invitation.email,
                                );
                          },
                        ),
                        BaseIconButton(
                          platformIcon: const PlatformIcon(
                            materialIcon: Icons.delete_outline,
                            cupertinoIcon: Icons.delete,
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
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
