import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteUserButton extends StatelessWidget {
  const DeleteUserButton({super.key, required this.user});
  final UserProfileEntity user;

  @override
  Widget build(BuildContext context) {
    return BaseTextButton(
      onPressed: () async {
        final delete = await showAlertDialog(
          context: context,
          title: 'Atenção!'.hardcoded,
          contentText: 'Deseja realmente excluir o usuário?'.hardcoded,
          defaultActionText: 'Sim'.hardcoded,
          cancelActionText: 'Não'.hardcoded,
        );

        if (delete == true && context.mounted) {
          final succeeds = await context.read<UsersCubit>().deleteUserProfile(
            user.id,
          );

          if (succeeds && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      text: 'Excluir usuário'.hardcoded,
      color: Colors.red,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.delete,
        cupertinoIcon: CupertinoIcons.delete,
        color: Colors.red,
      ),
    );
  }
}
