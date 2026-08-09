import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/extensions/service_provider_extensions.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_rich_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/email_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';

class ServiceProvidersInvitationsItems extends HookWidget {
  const ServiceProvidersInvitationsItems({super.key, required this.company});
  final ServiceProviderCompanyEntity company;

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    if (company.invitationStatus != ServiceProviderInvitationStatus.accepted) {
      return const SizedBox.shrink();
    }

    Future<void> sendInvitation() async {
      if (formKey.currentState?.validate() != true) {
        return;
      }
      final succeeds = await context
          .read<ServiceProvidersCubit>()
          .sendInvitation(
            serviceProviderCompanyId: company.id,
            email: emailController.text,
          );

      if (succeeds && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return BaseStateView<
      ServiceProvidersCubit,
      ServiceProvidersState,
      ServiceProvidersState
    >(
      sectionKey: ServiceProviderSection.selectCompany,
      onRetry: () =>
          context.read<ServiceProvidersCubit>().selectCompany(company.id),
      dataSelector: (state) => state,
      builder: (context, state) {
        final invitations = state.invitations[company.id] ?? [];
        final profiles = state.profiles[company.id] ?? [];

        final hasPending = invitations.any(
          (i) => i.status == ServiceProviderInvitationStatus.pending,
        );
        final hasAccepted = invitations.any(
          (i) => i.status == ServiceProviderInvitationStatus.accepted,
        );
        final hasEmail =
            company.contactEmail != null && company.contactEmail!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseRichText(
              texts: [
                BaseText.title('Usuários e convites'.hardcoded),
                BlocSelector<
                  ServiceProvidersCubit,
                  ServiceProvidersState,
                  bool
                >(
                  selector: (state) => state.status == StateStatus.saving,
                  builder: (context, isLoading) {
                    return BaseIconButton(
                      platformIcon: const PlatformIcon(
                        materialIcon: Icons.add,
                        cupertinoIcon: CupertinoIcons.add,
                      ),
                      permission: const ActionPermission.resource(
                        resource: ResourceType.serviceProviders,
                        action: PermissionAction.update,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              showModalPage<void>(
                                Padding(
                                  padding: const EdgeInsets.all(Sizes.p16),
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                      mainAxisSize: .min,
                                      crossAxisAlignment: .stretch,
                                      children: [
                                        BaseText.headline(
                                          'Convidar novo prestador'.hardcoded,
                                          textAlign: .center,
                                        ),
                                        gapH32,
                                        BaseTextFormField(
                                          controller: emailController,
                                          labelText: 'E-mail'.hardcoded,
                                          hintText: 'E-mail'.hardcoded,
                                          validator: FormValidators.compose([
                                            EmailValidator(),
                                          ]),
                                          onFieldSubmitted: (_) =>
                                              sendInvitation(),
                                        ),
                                        gapH32,
                                        BaseTextButton(
                                          onPressed: sendInvitation,
                                          text: 'Convidar'.hardcoded,
                                        ),
                                        const SizedBox(height: 300),
                                      ],
                                    ),
                                  ),
                                ),
                                context,
                                useDraggable: false,
                              );
                            },
                    );
                  },
                ),
              ],
            ),
            ...profiles.map((profile) {
              final correspondingInvitation = invitations.firstWhereOrNull(
                (e) => e.email == profile.email,
              );
              final isPendingInvitation =
                  correspondingInvitation?.status ==
                  ServiceProviderInvitationStatus.pending;

              return Column(
                crossAxisAlignment: .stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: BaseRichText(
                          texts: [
                            Column(
                              children: [
                                PlatformIcon(
                                  materialIcon: Icons.person,
                                  cupertinoIcon: CupertinoIcons.person,
                                  color: correspondingInvitation?.status.color,
                                ),
                                if (correspondingInvitation != null)
                                  BaseText.caption(
                                    correspondingInvitation.status.label,
                                    color: correspondingInvitation.status.color,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: .italic,
                                  ),
                              ],
                            ),
                            gapW8,
                            BaseText.title(profile.name),
                          ],
                        ),
                      ),
                      if (correspondingInvitation != null &&
                          isPendingInvitation)
                        BaseIconButton(
                          platformIcon: const PlatformIcon(
                            materialIcon: Icons.delete_outline,
                            cupertinoIcon: CupertinoIcons.delete,
                            color: Colors.red,
                          ),
                          permission: const ResourceActionPermission(
                            resource: ResourceType.serviceProviders,
                            action: PermissionAction.delete,
                          ),
                          onPressed: () {
                            showAlertDialog(
                              context: context,
                              title: 'Atenção'.hardcoded,
                              contentText:
                                  'Tem certeza que deseja excluir o convite?'
                                      .hardcoded,
                              defaultActionText: 'Sim'.hardcoded,
                              cancelActionText: 'Não'.hardcoded,
                              onOkPressed: () => context
                                  .read<ServiceProvidersCubit>()
                                  .deleteInvitation(
                                    invitationId: correspondingInvitation.id,
                                    serviceProviderCompanyId: company.id,
                                  ),
                            );
                          },
                        ),
                    ],
                  ),
                  if (!hasPending && !hasAccepted && hasEmail)
                    BlocSelector<
                      ServiceProvidersCubit,
                      ServiceProvidersState,
                      bool
                    >(
                      selector: (state) => state.status == StateStatus.saving,
                      builder: (context, isLoading) {
                        return Row(
                          mainAxisAlignment: .end,
                          children: [
                            BaseTextButton(
                              isLoading: isLoading,
                              permission: const ActionPermission.resource(
                                resource: ResourceType.serviceProviders,
                                action: PermissionAction.update,
                              ),
                              text: 'Convidar por e-mail'.hardcoded,
                              onPressed: () {
                                showAlertDialog(
                                  context: context,
                                  title: 'Atenção'.hardcoded,
                                  contentText:
                                      'Deseja realmente reenviar o convite para esse usuário?'
                                          .hardcoded,
                                  defaultActionText: 'Sim'.hardcoded,
                                  cancelActionText: 'Não'.hardcoded,
                                  onOkPressed: () => context
                                      .read<ServiceProvidersCubit>()
                                      .sendInvitation(
                                        serviceProviderCompanyId: company.id,
                                        email: company.contactEmail!,
                                      ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                ],
              );
            }),
          ],
        );
      },
    );
  }
}
