import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/validators/form_validators.dart';
import 'package:clean_architecture/shared_ui/utils/validators/min_length_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
  });
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (LoginCubit cubit) => cubit.state.status == StateStatus.loading,
    );

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BaseTextFormField(
              enabled: !isLoading,
              labelText: 'Usuário'.hardcoded,
              hintText: 'Digite seu usuário'.hardcoded,
              controller: usernameController,
              validator: FormValidators.compose([MinLengthValidator(3)]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            gapH8,
            BaseTextFormField(
              enabled: !isLoading,
              labelText: 'Senha'.hardcoded,
              hintText: 'Digite sua senha'.hardcoded,
              controller: passwordController,
              validator: FormValidators.compose([MinLengthValidator(3)]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: !state.passwordVisibility,
              suffixIcon: BaseIconButton(
                excludeFromFocus: true,
                onPressed: context.read<LoginCubit>().togglePasswordVisibility,
                platformIcon: PlatformIcon(
                  materialIcon: state.passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  cupertinoIcon: state.passwordVisibility
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
