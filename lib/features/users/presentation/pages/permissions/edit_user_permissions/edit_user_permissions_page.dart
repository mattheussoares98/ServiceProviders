import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/permissions/permissions_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/edit_user_permissions/widgets/admin_advice.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/edit_user_permissions/widgets/delete_user_button.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/edit_user_permissions/widgets/permissions_items.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/edit_user_permissions/widgets/selected_group_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

@RoutePage()
class EditUserPermissionsPage extends HookWidget {
  const EditUserPermissionsPage({super.key, required this.user});

  final UserProfileEntity user;

  @override
  Widget build(BuildContext context) {
    observeRunning([
      ObservedLoadingTarget(
        context.read<UsersCubit>(),
        sections: const {
          UsersSections.updateUser,
          UsersSections.deleteUser,
          UsersSections.saveGroup,
          UsersSections.deleteGroup,
          UsersSections.revokeInvitation,
        },
      ),
    ]);
    return BlocProvider(
      create: (context) => GetIt.I<PermissionsCubit>()..initUser(user),
      child: _Body(user: user),
    );
  }
}

class _Body extends HookWidget {
  const _Body({required this.user});
  final UserProfileEntity user;

  @override
  Widget build(BuildContext context) {
    observeRunning([
      ObservedLoadingTarget(
        context.read<PermissionsCubit>(),
        sections: const {PermissionsSections.save},
      ),
    ]);
    return BlocSelector<PermissionsCubit, PermissionsState, (bool, bool)>(
      selector: (state) => (
        state.isAdmin,
        state.sections[PermissionsSections.save] == SectionStatus.running,
      ),
      builder: (context, value) {
        Future<void> onSave() async {
          final cubit = context.read<PermissionsCubit>();
          final success = await cubit.saveUserPermissions(
            context.read<UsersCubit>(),
          );
          if (success && context.mounted) {
            cubit.popRoute();
          }
        }

        final isAdmin = value.$1;
        final isSaving = value.$2;

        return BaseScaffold(
          isScrollable: false,
          appBar: BaseAppBar(
            title: 'Alterando usuário'.hardcoded,
            actions: [
              BaseIconButton(
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.save,
                  cupertinoIcon: CupertinoIcons.check_mark,
                ),
                padding: const EdgeInsets.only(right: Sizes.p12),
                onPressed: isSaving ? null : onSave,
                isLoading: isSaving,
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: BaseText.titleMedium(user.name)),
              gapSliverH4,
              SliverToBoxAdapter(
                child: BaseText(user.email, color: context.theme.hintColor),
              ),
              gapSliverH16,
              const SliverToBoxAdapter(child: SelectedGroupDropdown()),
              gapSliverH16,
              if (isAdmin) ...[
                const SliverToBoxAdapter(child: AdminAdvice()),
                gapSliverH16,
              ],
              const PermissionsItems(),
              gapSliverH16,
              SliverToBoxAdapter(child: DeleteUserButton(user: user)),
              gapSliverH16,
            ],
          ),
        );
      },
    );
  }
}
