import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/permissions/permissions_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/features/users/presentation/pages/permissions/edit_user_permissions/widgets/admin_advice.dart';
import 'package:clean_architecture/features/users/presentation/pages/permissions/edit_user_permissions/widgets/permissions_items.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class EditUserPermissionsPage extends StatelessWidget {
  const EditUserPermissionsPage({super.key, required this.user});

  final UserProfileEntity user;

  @override
  Widget build(BuildContext context) {
    Future<void> onSave() async {
      final success = await context
          .read<PermissionsCubit>()
          .saveUserPermissions(context.read<UsersCubit>());
      if (success && context.mounted) {
        context.router.pop();
      }
    }

    return BlocProvider(
      create: (context) => GetIt.I<PermissionsCubit>()..initUser(user),
      child: BlocSelector<PermissionsCubit, PermissionsState, (bool, bool)>(
        selector: (state) =>
            (state.isAdmin, state.status == StateStatus.saving),
        builder: (context, value) {
          final isAdmin = value.$1;
          final isSaving = value.$2;

          return BaseScaffold(
            isScrollable: false,
            appBar: BaseAppBar(
              title: 'Permissões do Usuário'.hardcoded,
              actions: [
                if (!isAdmin)
                  BaseTextButton(
                    platformIcon: const PlatformIcon(
                      materialIcon: Icons.save,
                      cupertinoIcon: CupertinoIcons.check_mark,
                    ),
                    padding: const EdgeInsets.only(right: Sizes.p12),
                    onPressed: isSaving ? null : onSave,
                    isLoading: isSaving,
                    text: 'Salvar'.hardcoded,
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
                if (isAdmin) ...[
                  const SliverToBoxAdapter(child: AdminAdvice()),
                  gapSliverH16,
                ],
                const PermissionsItems(),
              ],
            ),
          );
        },
      ),
    );
  }
}
