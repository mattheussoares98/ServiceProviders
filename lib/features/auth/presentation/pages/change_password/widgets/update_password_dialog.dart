import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/change_password/change_password_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/change_password/widgets/change_password.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class UpdatePasswordDialog extends HookWidget {
  const UpdatePasswordDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const UpdatePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(() => GetIt.I<ChangePasswordCubit>());
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final confirmPasswordFocusNode = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
        builder: (context, state) {
          final isSaving =
              state.sections[BaseSections.load] == const SectionState.running();

          return PopScope(
            canPop: !isSaving,
            child: IgnorePointer(
              ignoring: isSaving,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.p16),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Sizes.p24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BaseText.titleMedium(
                        'Alterar senha'.hardcoded,
                        fontWeight: FontWeight.bold,
                      ),
                      gapH12,
                      BaseText(
                        'Crie uma nova senha para acessar sua conta'.hardcoded,
                      ),
                      gapH24,
                      Form(
                        key: formKey,
                        child: ChangePasswordForm(
                          formKey: formKey,
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController,
                          confirmPasswordFocusNode: confirmPasswordFocusNode,
                        ),
                      ),
                      gapH24,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: BaseButton.secondary(
                              text: 'Cancelar'.hardcoded,
                              isLoading: isSaving,
                              onTap: () => Navigator.of(context).pop(false),
                            ),
                          ),
                          gapW12,
                          Flexible(
                            child: BaseButton(
                              text: 'Salvar'.hardcoded,
                              isLoading: isSaving,
                              onTap: () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                FocusManager.instance.primaryFocus?.unfocus();
                                final success = await cubit.changePassword(
                                  passwordController.text,
                                  redirectOnSuccess: false,
                                );
                                if (success &&
                                    context.mounted &&
                                    (ModalRoute.of(context)?.isCurrent ??
                                        false)) {
                                  Navigator.of(context).pop(true);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
