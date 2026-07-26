import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/extensions/service_provider_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ServiceProvidersInvitationsItems extends StatelessWidget {
  const ServiceProvidersInvitationsItems({super.key, required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText.title('Convites'.hardcoded),
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
                  trailing: Chip(
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
                    padding: const EdgeInsets.symmetric(horizontal: Sizes.p4),
                    visualDensity: VisualDensity.compact,
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
