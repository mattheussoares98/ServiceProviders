import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class InvitationsPage extends StatelessWidget {
  const InvitationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseStateView<UsersCubit, UsersState, List<UserInvitationEntity>>(
      dataSelector: (state) => state.invitations,
      onRetry: () => context.read<UsersCubit>().loadAll(emitLoading: false),
      builder: (context, invitations) {
        if (invitations.isEmpty) {
          return Center(child: BaseText('Nenhum convite pendente'.hardcoded));
        }

        return ListView.builder(
          itemCount: invitations.length,
          padding: const EdgeInsets.all(Sizes.p16),
          itemBuilder: (context, index) {
            final invite = invitations[index];
            final groupName =
                context
                    .read<UsersCubit>()
                    .state
                    .permissionGroups
                    .firstWhereOrNull((e) => e.id == invite.permissionGroupId)
                    ?.name ??
                'Sem grupo'.hardcoded;

            final formattedDate = invite.invitedAt
                .toLocal()
                .toString()
                .split(' ')[0]
                .split('-')
                .reversed
                .join('/');

            return Card(
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(Sizes.p12),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: Sizes.p8),
                      child: PlatformIcon(
                        materialIcon: Icons.mail_outline,
                        cupertinoIcon: CupertinoIcons.mail,
                      ),
                    ),
                    gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: BaseText.title(
                                  invite.name.isEmpty
                                      ? invite.email
                                      : invite.name,
                                ),
                              ),
                              if (invite.isExpired) ...[
                                gapW8,
                                Chip(
                                  label: BaseText.caption(
                                    'Expirado'.hardcoded,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.orange.shade700,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ],
                          ),
                          gapH4,
                          BaseText(invite.email),
                          gapH4,
                          BaseText.caption(
                            'Grupo: $groupName • Enviado em: $formattedDate'
                                .hardcoded,
                          ),
                        ],
                      ),
                    ),
                    // Resend button (only for expired invites)
                    if (invite.isExpired)
                      BlocSelector<UsersCubit, UsersState, bool>(
                        selector: (state) =>
                            state.resendingInvitationIds.contains(invite.id),
                        builder: (context, resending) {
                          if (resending) {
                            return const Padding(
                              padding: EdgeInsets.all(Sizes.p8),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          return BaseIconButton(
                            permission: const ActionPermission.resource(
                              resourceType: ResourceType.users,
                              permissionAction: PermissionAction.create,
                            ),
                            onPressed: () async {
                              final confirmed = await showAlertDialog(
                                context: context,
                                title: 'Reenviar convite'.hardcoded,
                                contentText:
                                    'Deseja reenviar o convite para ${invite.email}?'
                                        .hardcoded,
                                cancelActionText: 'Não'.hardcoded,
                                defaultActionText: 'Reenviar'.hardcoded,
                              );
                              if (confirmed == true && context.mounted) {
                                await context
                                    .read<UsersCubit>()
                                    .resendInvitation(invite);
                              }
                            },
                            platformIcon: const PlatformIcon(
                              materialIcon: Icons.refresh,
                              cupertinoIcon: CupertinoIcons.arrow_clockwise,
                              color: Colors.orange,
                            ),
                          );
                        },
                      ),
                    // Delete button
                    BlocSelector<UsersCubit, UsersState, bool>(
                      selector: (state) =>
                          state.deletingInvitationIds.contains(invite.id),
                      builder: (context, deleting) {
                        if (deleting) {
                          return const Padding(
                            padding: EdgeInsets.all(Sizes.p8),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }
                        return BaseIconButton(
                          permission: const ActionPermission.resource(
                            resourceType: ResourceType.users,
                            permissionAction: PermissionAction.delete,
                          ),
                          onPressed: () async {
                            final confirmed = await showAlertDialog(
                              context: context,
                              title: 'Cancelar convite'.hardcoded,
                              contentText:
                                  'Tem certeza que deseja cancelar o convite para ${invite.email}?'
                                      .hardcoded,
                              cancelActionText: 'Não'.hardcoded,
                              defaultActionText: 'Sim'.hardcoded,
                            );

                            if (confirmed == true && context.mounted) {
                              await context.read<UsersCubit>().revokeInvitation(
                                invite.id,
                              );
                            }
                          },
                          platformIcon: const PlatformIcon(
                            materialIcon: Icons.delete_outline,
                            cupertinoIcon: CupertinoIcons.delete,
                            color: Colors.red,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
