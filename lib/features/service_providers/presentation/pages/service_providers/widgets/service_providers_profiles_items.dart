import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ServiceProvidersProfilesItems extends StatelessWidget {
  const ServiceProvidersProfilesItems({super.key, required this.companyId});
  final String companyId;

  @override
  Widget build(BuildContext context) {
    final hasPendingInvite = context.select<ServiceProvidersCubit, bool>(
      (cubit) =>
          cubit.state.invitations[companyId]?.any(
            (inv) => inv.status == ServiceProviderInvitationStatus.pending,
          ) ??
          false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText.title('Técnicos'.hardcoded),
        gapH8,
        if (hasPendingInvite) ...[
          //TODO read and test this
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Sizes.p12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(Sizes.p8),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade800,
                  size: 20,
                ),
                gapW8,
                Expanded(
                  child: BaseText.bodySmall(
                    'Aguardando aceite do convite enviado para a empresa. O cadastro de técnicos estará disponível assim que o convite for aceito.'
                        .hardcoded,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
          gapH8,
        ],
        BlocSelector<
          ServiceProvidersCubit,
          ServiceProvidersState,
          List<ServiceProviderProfileEntity>
        >(
          selector: (state) => state.profiles[companyId] ?? [],
          builder: (context, profiles) {
            if (profiles.isEmpty) {
              return BaseText.bodySmall('Nenhum técnico cadastrado'.hardcoded);
            }

            return Column(
              children: profiles
                  .map(
                    (profile) => BaseListTile(
                      title: profile.name,
                      subtitle: profile.email,
                      platformIcon: const PlatformIcon(
                        materialIcon: Icons.person,
                        cupertinoIcon: CupertinoIcons.person,
                      ),
                      trailing: profile.phone != null
                          ? BaseText(profile.phone!)
                          : null,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
