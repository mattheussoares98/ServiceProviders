import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:clean_architecture/features/auth/presentation/pages/login/widgets/login_optional.dart';
import 'package:clean_architecture/shared_ui/ui/base/form/base_text_field.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/ui_helpers.dart';
import 'package:clean_architecture/shared_ui/utils/validators.dart';
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
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BaseTextField(
              title: 'Usuário'.hardcoded,
              controller: usernameController,
              hintText: 'Digite seu usuário'.hardcoded,
              validator: Validators.username,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            UIHelpers.spaceV8,
            BaseTextField(
              title: 'Senha'.hardcoded,
              hintText: 'Digite sua senha'.hardcoded,
              controller: passwordController,
              validator: Validators.password,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: !state.passwordVisibility,
              suffixIcon: InkWell(
                customBorder: const CircleBorder(),
                onTap: context.read<LoginCubit>().togglePasswordVisibility,
                child: PlatformIcon(
                  materialIcon: state.passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  cupertinoIcon: state.passwordVisibility
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                  color: AppColors.black60,
                  size: 22,
                ),
              ),
            ),
            UIHelpers.spaceV16,
            LoginOptional(saveUserCredential: state.saveUserCredential),
          ],
        );
      },
    );
  }
}
