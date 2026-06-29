import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/invite_user/invite_user_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InviteButton extends StatelessWidget {
  const InviteButton({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.selectedGroup,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final ValueNotifier<PermissionGroupEntity?> selectedGroup;

  @override
  Widget build(BuildContext context) {
    final permissionGroups = context.select(
      (UsersCubit cubit) => cubit.state.permissionGroups,
    );
    return BlocBuilder<InviteUserCubit, InviteUserState>(
      builder: (context, state) {
        return PrimaryButton(
          text: 'Convidar'.hardcoded,
          isLoading: state.status == StateStatus.loading,
          onTap: permissionGroups.isEmpty
              ? null
              : () async {
                  if (!formKey.currentState!.validate() ||
                      selectedGroup.value == null) {
                    return;
                  }

                  await context.read<InviteUserCubit>().invite(
                    email: emailController.text.trim(),
                    groupId: selectedGroup.value!.id,
                  );
                },
        );
      },
    );
  }
}
