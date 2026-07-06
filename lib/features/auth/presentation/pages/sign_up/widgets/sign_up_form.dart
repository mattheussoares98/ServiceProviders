import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/sign_up/sign_up_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/email_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.passwordConfirmationFocusNode,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode passwordConfirmationFocusNode;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (SignUpCubit cubit) => cubit.state.status == StateStatus.loading,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BaseTextFormField(
          enabled: !isLoading,
          labelText: 'Nome'.hardcoded,
          hintText: 'Digite seu nome'.hardcoded,
          controller: nameController,
          validator: FormValidators.compose([MinLengthValidator(3)]),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onFieldSubmitted: (_) => emailFocusNode.requestFocus(),
        ),
        gapH20,
        BaseTextFormField(
          enabled: !isLoading,
          focusNode: emailFocusNode,
          onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
          labelText: 'Email'.hardcoded,
          hintText: 'Digite seu email'.hardcoded,
          controller: emailController,
          validator: FormValidators.compose([EmailValidator()]),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        gapH20,
        BlocSelector<SignUpCubit, SignUpState, bool>(
          selector: (state) => state.passwordVisibility,
          builder: (context, passwordVisibility) {
            return BaseTextFormField(
              enabled: !isLoading,
              focusNode: passwordFocusNode,
              onFieldSubmitted: (_) =>
                  passwordConfirmationFocusNode.requestFocus(),
              labelText: 'Senha'.hardcoded,
              hintText: 'Digite sua senha'.hardcoded,
              controller: passwordController,
              validator: FormValidators.compose([MinLengthValidator(3)]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: !passwordVisibility,
              suffixIcon: BaseIconButton(
                onPressed: context.read<SignUpCubit>().togglePasswordVisibility,
                platformIcon: PlatformIcon(
                  materialIcon: passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  cupertinoIcon: passwordVisibility
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                ),
              ),
            );
          },
        ),
        gapH20,
        BlocSelector<SignUpCubit, SignUpState, bool>(
          selector: (state) => state.confirmPasswordVisibility,
          builder: (context, confirmPasswordVisibility) {
            return BaseTextFormField(
              enabled: !isLoading,
              focusNode: passwordConfirmationFocusNode,
              labelText: 'Confirmar senha'.hardcoded,
              hintText: 'Digite sua senha'.hardcoded,
              controller: passwordConfirmationController,
              validator: (value) =>
                  passwordConfirmationController.text == passwordController.text
                  ? null
                  : 'Senhas não conferem'.hardcoded,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onFieldSubmitted: (_) async {
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
              obscureText: !confirmPasswordVisibility,
              suffixIcon: BaseIconButton(
                onPressed: context
                    .read<SignUpCubit>()
                    .toggleConfirmPasswordVisibility,
                platformIcon: PlatformIcon(
                  materialIcon: confirmPasswordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  cupertinoIcon: confirmPasswordVisibility
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
