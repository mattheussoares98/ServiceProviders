import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class HelloUser extends StatelessWidget {
  const HelloUser({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.select<DashboardCubit, UserProfileEntity?>(
      (cubit) => cubit.state.userProfile,
    );
    if (userProfile == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: .start,
      children: [
        BaseText.headline('Olá, ${userProfile.name}'.hardcoded),
        BaseText(
          userProfile.isAdmin
              ? 'Administrador'.hardcoded
              : 'Técnico de manutenção'.hardcoded,
        ),
      ],
    );
  }
}
