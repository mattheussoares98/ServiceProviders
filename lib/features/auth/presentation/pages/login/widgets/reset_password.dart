import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading_circle.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:clean_architecture/shared_ui/utils/validators/email_validator.dart';
import 'package:clean_architecture/shared_ui/utils/validators/form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ResetPassword extends HookWidget {
  const ResetPassword({super.key, required this.emailController});
  final TextEditingController emailController;

  void _showResetPasswordDialog(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController resetPasswordController,
  ) {
    if (EmailValidator().isValid(emailController.text)) {
      resetPasswordController.text = emailController.text;
    } else {
      resetPasswordController.clear();
    }

    Future<void> onSubmit() async {
      if (formKey.currentState?.validate() ?? false) {
        final email = resetPasswordController.text.trim();
        await context.read<LoginCubit>().resetPassword(email);
      }
    }

    final loginCubit = context.read<LoginCubit>();

    showAlertDialog(
      context: context,
      title: 'Recuperar Senha'.hardcoded,
      onOkPressed: onSubmit,
      actions: [],
      contentWidget: BlocProvider.value(
        value: loginCubit,
        child: _ResetPasswordDialog(
          resetPasswordController: resetPasswordController,
          onSubmit: onSubmit,
          formKey: formKey,
          loginCubit: loginCubit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final resetPasswordController = useTextEditingController();

    return BaseTextButton(
      isLoading: context.select(
        (LoginCubit cubit) =>
            cubit.state.resetPasswordStatus == StateStatus.loading,
      ),
      onPressed: () =>
          _showResetPasswordDialog(context, formKey, resetPasswordController),
      text: 'Esqueceu a senha?'.hardcoded,
    );
  }
}

class _ResetPasswordDialog extends StatelessWidget {
  const _ResetPasswordDialog({
    required this.resetPasswordController,
    required this.onSubmit,
    required this.formKey,
    required this.loginCubit,
  });

  final TextEditingController resetPasswordController;
  final GlobalKey<FormState> formKey;
  final LoginCubit loginCubit;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: BlocSelector<LoginCubit, LoginState, bool>(
        selector: (state) => state.resetPasswordStatus == StateStatus.loading,
        builder: (context, isLoading) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Insira o seu e-mail para receber o link de redefinição de senha.'
                    .hardcoded,
                style: context.theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: Sizes.p16),
              BaseTextFormField(
                autofocus: true,
                labelText: 'E-mail'.hardcoded,
                hintText: 'Digite seu e-mail'.hardcoded,
                controller: resetPasswordController,
                keyboardType: TextInputType.emailAddress,
                validator: FormValidators.compose([EmailValidator()]),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onFieldSubmitted: isLoading ? null : (_) => onSubmit(),
                enabled: !isLoading,
              ),
              Container(
                constraints: const BoxConstraints(minHeight: Sizes.p48),
                child: isLoading ? const LoadingCircle() : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: BaseTextButton(
                      isLoading: isLoading,
                      onPressed: () => Navigator.of(context).pop(),
                      text: 'Cancelar'.hardcoded,
                    ),
                  ),
                  Expanded(
                    child: BaseTextButton(
                      isLoading: isLoading,
                      onPressed: onSubmit,
                      text: 'Enviar'.hardcoded,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
