import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/accept_invite/accept_invite_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';

@RoutePage()
class AcceptInvitePage extends HookWidget {
  const AcceptInvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final passwordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    //TODO organize better this page
    return BlocProvider(
      create: (context) => GetIt.I<AcceptInviteCubit>()..initialize(),
      child: BlocConsumer<AcceptInviteCubit, AcceptInviteState>(
        listener: (context, state) {
          if (state.userProfile != null && nameController.text.isEmpty) {
            nameController.text = state.userProfile!.name;
          }
        },
        builder: (context, state) {
          final cubit = context.read<AcceptInviteCubit>();
          final isLoading = state.status == StateStatus.loading;

          return BaseScaffold(
            observeScreenChanges: true,
            appBar: BaseAppBar(
              title: 'Aceitar Convite'.hardcoded,
              leading: BaseIconButton(
                onPressed: () {
                  cubit.navigateToHome();
                },
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.arrow_back,
                  cupertinoIcon: CupertinoIcons.arrow_left,
                  color: Colors.white,
                ),
              ),
            ),
            body:
                BaseStateView<
                  AcceptInviteCubit,
                  AcceptInviteState,
                  UserProfileEntity?
                >(
                  dataSelector: (state) => state.userProfile,
                  onRetry: () {
                    final userId =
                        GetIt.I<SupabaseAuthClient>().currentSession?.user.id;
                    if (userId != null) {
                      cubit.loadProfile(userId);
                    }
                  },
                  builder: (context, userProfile) {
                    if (userProfile != null && userProfile.isActive) {
                      return Padding(
                        padding: const EdgeInsets.all(Sizes.p24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BaseText.bodyLarge(
                              'Sua conta já está ativa e vinculada. Deseja prosseguir para a tela inicial?'
                                  .hardcoded,
                              textAlign: TextAlign.center,
                            ),
                            gapH48,
                            PrimaryButton(
                              isLoading: isLoading,
                              expandWidth: true,
                              onTap: () async {
                                await cubit.navigateToHome();
                              },
                              text: 'Prosseguir'.hardcoded,
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(Sizes.p24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BaseText.bodyLarge(
                              'Complete seus dados e crie uma senha para ativar sua conta.'
                                  .hardcoded,
                            ),
                            gapH32,
                            BaseTextFormField(
                              enabled: !isLoading,
                              labelText: 'Nome Completo'.hardcoded,
                              hintText: 'Digite seu nome completo'.hardcoded,
                              controller: nameController,
                              validator: FormValidators.compose([
                                MinLengthValidator(3),
                              ]),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onFieldSubmitted: (_) =>
                                  passwordFocusNode.requestFocus(),
                            ),
                            gapH20,
                            BaseTextFormField(
                              enabled: !isLoading,
                              focusNode: passwordFocusNode,
                              labelText: 'Senha'.hardcoded,
                              hintText: 'Crie uma senha de acesso'.hardcoded,
                              controller: passwordController,
                              validator: FormValidators.compose([
                                MinLengthValidator(6),
                              ]),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              obscureText: !state.passwordVisibility,
                              onFieldSubmitted: (_) =>
                                  confirmPasswordFocusNode.requestFocus(),
                              suffixIcon: BaseIconButton(
                                onPressed: cubit.togglePasswordVisibility,
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
                            gapH20,
                            BaseTextFormField(
                              enabled: !isLoading,
                              focusNode: confirmPasswordFocusNode,
                              labelText: 'Confirmar Senha'.hardcoded,
                              hintText:
                                  'Confirme sua senha de acesso'.hardcoded,
                              controller: confirmPasswordController,
                              validator: (value) =>
                                  confirmPasswordController.text ==
                                      passwordController.text
                                  ? null
                                  : 'As senhas não conferem'.hardcoded,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              obscureText: !state.confirmPasswordVisibility,
                              suffixIcon: BaseIconButton(
                                onPressed:
                                    cubit.toggleConfirmPasswordVisibility,
                                platformIcon: PlatformIcon(
                                  materialIcon: state.confirmPasswordVisibility
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  cupertinoIcon: state.confirmPasswordVisibility
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                ),
                              ),
                              onFieldSubmitted: (_) async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                FocusManager.instance.primaryFocus?.unfocus();
                                final success = await cubit.acceptInvite(
                                  name: nameController.text,
                                  password: passwordController.text,
                                );
                                if (success) {
                                  await cubit.navigateToHome();
                                }
                              },
                            ),
                            gapH48,
                            PrimaryButton(
                              isLoading: isLoading,
                              expandWidth: true,
                              onTap: () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                FocusManager.instance.primaryFocus?.unfocus();
                                final success = await cubit.acceptInvite(
                                  name: nameController.text,
                                  password: passwordController.text,
                                );
                                if (success) {
                                  await cubit.navigateToHome();
                                }
                              },
                              text: 'Ativar Minha Conta'.hardcoded,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          );
        },
      ),
    );
  }
}
