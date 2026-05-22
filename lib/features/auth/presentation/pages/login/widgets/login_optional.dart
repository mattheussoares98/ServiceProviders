import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:clean_architecture/shared_ui/utils/validators/email_validator.dart';
import 'package:clean_architecture/shared_ui/utils/validators/form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RestorePassword extends StatelessWidget {
  const RestorePassword({super.key, required this.usernameController});
  final TextEditingController usernameController;

  void _showResetPasswordDialog(BuildContext context) {
    final loginCubit = context.read<LoginCubit>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: loginCubit,
          child: _ResetPasswordDialog(
            usernameController: usernameController,
            loginCubit: loginCubit,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseTextButton(
      isLoading: context.select(
        (LoginCubit cubit) => cubit.state.status == StateStatus.loading,
      ),
      onPressed: () => _showResetPasswordDialog(context),
      text: 'Esqueceu a senha?'.hardcoded,
    );
  }
}

class _ResetPasswordDialog extends HookWidget {
  const _ResetPasswordDialog({
    required this.usernameController,
    required this.loginCubit,
  });

  final TextEditingController usernameController;
  final LoginCubit loginCubit;

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController(
      text: EmailValidator().isValid(usernameController.text)
          ? usernameController.text
          : '',
    );
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return AlertDialog.adaptive(
      title: Text('Recuperar Senha'.hardcoded),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insira o seu e-mail para receber o link de redefinição de senha.'
                  .hardcoded,
              style: context.theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            BaseTextFormField(
              labelText: 'E-mail'.hardcoded,
              hintText: 'Digite seu e-mail'.hardcoded,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.compose([EmailValidator()]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'.hardcoded),
        ),
        TextButton(
          onPressed: () async {
            if (formKey.currentState?.validate() ?? false) {
              final email = emailController.text.trim();
              Navigator.of(context).pop();
              await loginCubit.resetPassword(email);
            }
          },
          child: Text('Enviar'.hardcoded),
        ),
      ],
    );
  }
}
