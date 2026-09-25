import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';

class CreateAccountButton extends StatelessWidget {
  const CreateAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseButton.secondary(
      expandWidth: true,
      isLoading: context.select(
        (LoginCubit cubit) => cubit.state.section(BaseSections.load).isRunning,
      ),
      onTap: context.read<LoginCubit>().navigateToSignUp,
      text: 'CRIAR CONTA'.hardcoded,
    );
  }
}
