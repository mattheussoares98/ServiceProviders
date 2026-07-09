import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class TryAgainButton extends StatelessWidget {
  const TryAgainButton({
    required this.assetsError,
    required this.locationsError,
    required this.usersError,
    super.key,
  });

  final String? assetsError;
  final String? locationsError;
  final String? usersError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          children: [
            BaseText.error(
              '${assetsError ?? ''}\n${locationsError ?? ''}\n${usersError ?? ''}',
            ),
            gapH32,
            PrimaryButton(
              onTap: () async {
                await Future.wait([
                  if (assetsError?.isNotEmpty == true)
                    context.read<AssetsCubit>().loadAssets(),
                  if (locationsError?.isNotEmpty == true)
                    context.read<LocationsCubit>().loadLocationsAndAreas(),
                  if (usersError?.isNotEmpty == true)
                    context.read<UsersCubit>().loadUsers(),
                ]);
              },
              text: 'Tentar novamente'.hardcoded,
            ),
          ],
        ),
      ),
    );
  }
}
