import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ServiceProvidersProfilesItems extends StatelessWidget {
  const ServiceProvidersProfilesItems({super.key, required this.companyId});
  final String companyId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        BaseText.title('Técnicos'.hardcoded),
        gapH8,
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
