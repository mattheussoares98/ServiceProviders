import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class HelloUser extends StatelessWidget {
  const HelloUser({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.select<SessionCubit, UserProfileEntity?>(
      (cubit) => cubit.state.user,
    );
    if (userProfile == null || userProfile.id.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

