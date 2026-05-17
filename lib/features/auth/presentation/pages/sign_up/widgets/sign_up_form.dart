import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/form/base_text_field.dart';
import 'package:clean_architecture/shared_ui/utils/ui_helpers.dart';
import 'package:clean_architecture/shared_ui/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BaseTextField(
          title: 'Name',
          controller: nameController,
          hintText: 'Enter your name',
          validator: Validators.username,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        UIHelpers.spaceV20,
        BaseTextField(
          title: 'Email',
          controller: emailController,
          hintText: 'Enter your email',
          validator: Validators.email,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        UIHelpers.spaceV20,
        BlocSelector<SignUpCubit, SignUpState, bool>(
          selector: (state) => state.passwordVisibility,
          builder: (context, passwordVisibility) {
            return BaseTextField(
              title: 'Password',
              hintText: 'Enter your password',
              controller: passwordController,
              validator: Validators.password,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: !passwordVisibility,
              suffixIcon: InkWell(
                customBorder: const CircleBorder(),
                onTap: context.read<SignUpCubit>().togglePasswordVisibility,
                child: Icon(
                  passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.black60,
                  size: 22,
                ),
              ),
            );
          },
        ),
        UIHelpers.spaceV4,
      ],
    );
  }
}
