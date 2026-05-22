import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpButton extends StatelessWidget {
  const SignUpButton({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (SignUpCubit cubit) => cubit.state.status == StateStatus.loading,
    );

    return PrimaryButton(
      isLoading: isLoading,
      expandWidth: true,
      onTap: () async {
        if (!formKey.currentState!.validate()) {
          return;
        }
        FocusManager.instance.primaryFocus?.unfocus();

        await context.read<SignUpCubit>().signUp(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
        );
      },
      text: 'CONFIRMAR'.hardcoded,
    );
  }
}
