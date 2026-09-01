import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/change_password/change_password_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/change_password/widgets/change_password.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

@RoutePage()
class ChangePasswordPage extends HookWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final confirmPasswordFocusNode = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return BlocProvider(
      create: (context) => GetIt.I<ChangePasswordCubit>(),
      child: BaseScaffold(
        observeScreenChanges: true,
        appBar: BaseAppBar(title: 'Alterar Senha'.hardcoded),
        body: Padding(
          padding: const EdgeInsets.all(Sizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BaseText('Crie uma nova senha para acessar sua conta.'.hardcoded),
              gapH32,
              Form(
                key: formKey,
                child: ChangePasswordForm(
                  formKey: formKey,
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                  confirmPasswordFocusNode: confirmPasswordFocusNode,
                ),
              ),
              gapH48,
              Builder(
                builder: (context) {
                  final isLoading = context.select(
                    (ChangePasswordCubit cubit) =>
                        cubit.state.status == DataStatus.loading,
                  );
                  return BaseButton(
                    isLoading: isLoading,
                    expandWidth: true,
                    onTap: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      FocusManager.instance.primaryFocus?.unfocus();
                      await context.read<ChangePasswordCubit>().changePassword(
                        passwordController.text,
                      );
                    },
                    text: 'Salvar Nova Senha'.hardcoded,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
