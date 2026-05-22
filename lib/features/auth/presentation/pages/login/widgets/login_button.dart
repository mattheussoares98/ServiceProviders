import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (LoginCubit cubit) => cubit.state.status == StateStatus.loading,
    );

    return PrimaryButton(
      isLoading: isLoading,
      expandWidth: true,
      onTap: () async {
        if (!formKey.currentState!.validate()) {
          return;
        }
        FocusManager.instance.primaryFocus?.unfocus();

        await context.read<LoginCubit>().fakeLogin(
          username: emailController.text,
          password: passwordController.text,
        );
      },
      text: 'LOGIN'.hardcoded,
    );
  }
}
