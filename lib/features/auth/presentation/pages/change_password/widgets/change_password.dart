import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/change_password/change_password_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';

class ChangePasswordForm extends StatelessWidget {
  const ChangePasswordForm({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.confirmPasswordFocusNode,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode confirmPasswordFocusNode;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (ChangePasswordCubit cubit) => cubit.state.status == DataStatus.loading,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocSelector<ChangePasswordCubit, ChangePasswordState, bool>(
          selector: (state) => state.passwordVisibility,
          builder: (context, passwordVisibility) {
            return BaseTextFormField(
              enabled: !isLoading,
              labelText: 'Nova senha'.hardcoded,
              hintText: 'Digite sua nova senha'.hardcoded,
              controller: passwordController,
              validator: FormValidators.compose([MinLengthValidator(3)]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: !passwordVisibility,
              onFieldSubmitted: (_) => confirmPasswordFocusNode.requestFocus(),
              suffixIcon: BaseIconButton(
                onPressed: context
                    .read<ChangePasswordCubit>()
                    .togglePasswordVisibility,
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
        BlocSelector<ChangePasswordCubit, ChangePasswordState, bool>(
          selector: (state) => state.confirmPasswordVisibility,
          builder: (context, confirmPasswordVisibility) {
            return BaseTextFormField(
              enabled: !isLoading,
              focusNode: confirmPasswordFocusNode,
              labelText: 'Confirmar nova senha'.hardcoded,
              hintText: 'Confirme sua nova senha'.hardcoded,
              controller: confirmPasswordController,
              validator: (value) =>
                  confirmPasswordController.text == passwordController.text
                  ? null
                  : 'As senhas não conferem'.hardcoded,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: !confirmPasswordVisibility,
              suffixIcon: BaseIconButton(
                onPressed: context
                    .read<ChangePasswordCubit>()
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
              onFieldSubmitted: (_) async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                FocusManager.instance.primaryFocus?.unfocus();
                await context.read<ChangePasswordCubit>().changePassword(
                  passwordController.text,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
