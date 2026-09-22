import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';

class SupportButton extends StatelessWidget {
  const SupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseTextButton(
      onPressed:
          context.select(
            (LoginCubit cubit) =>
                cubit.state.section(BaseSections.load).isRunning,
          )
          ? null
          : context.read<LoginCubit>().navigateToSupport,
      text: 'Precisa de ajuda? Contate o suporte'.hardcoded,
    );
  }
}
