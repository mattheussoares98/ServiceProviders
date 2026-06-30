import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/user_invitation_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_state_view.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        //TODO test this page
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

            final isDeleting = context.select<UsersCubit, bool>(
              (cubit) => cubit.state.deletingInvitationIds.contains(invite.id),
            );

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
                          BaseText.title(
                            invite.name.isEmpty ? invite.email : invite.name,
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
                    if (isDeleting)
                      const Padding(
                        padding: EdgeInsets.all(Sizes.p8),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: () async {
                          final confirmed = await showAlertDialog(
                            context: context,
                            title: 'Revogar Convite'.hardcoded,
                            contentText:
                                'Tem certeza que deseja revogar o convite para ${invite.email}?'
                                    .hardcoded,
                            cancelActionText: 'Cancelar'.hardcoded,
                            defaultActionText: 'Revogar'.hardcoded,
                          );

                          if (confirmed == true && context.mounted) {
                            await context.read<UsersCubit>().revokeInvitation(
                              invite.id,
                            );
                          }
                        },
                        icon: const PlatformIcon(
                          materialIcon: Icons.delete_outline,
                          cupertinoIcon: CupertinoIcons.delete,
                        ),
                        color: Colors.red,
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
