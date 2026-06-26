import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      observeScreenChanges: true,
      onRefresh: () =>
          context.read<UsersCubit>().loadPermissionGroups(emitLoading: false),
      appBar: BaseAppBar(title: 'Permissões'.hardcoded),
      body: const _PermissionsBody(),
    );
  }
}

class _PermissionsBody extends StatelessWidget {
  const _PermissionsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state.status == StateStatus.loading &&
            state.permissionGroups.isEmpty) {
          return const Center(child: LoadingCircle());
        }

        if (state.status == StateStatus.error &&
            state.permissionGroups.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.p16),
              child: BaseText.bodyLarge(
                state.errorMessage?.isNotEmpty ?? false
                    ? state.errorMessage!
                    : 'Erro ao carregar grupos de permissão'.hardcoded,
                color: context.colorScheme.error,
              ),
            ),
          );
        }

        final groups = state.permissionGroups;
        if (groups.isEmpty) {
          return Center(
            child: BaseText.bodyLarge(
              'Nenhum grupo de permissão encontrado'.hardcoded,
            ),
          );
        }

        return ListView.builder(
          shrinkWrap:
              true, //TODO remove it and check if need to improve this page
          padding: const EdgeInsets.all(Sizes.p8),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: Sizes.p4,
                horizontal: Sizes.p8,
              ),
              child: BaseListTile(
                title: group.name,
                subtitle: group.isDefault
                    ? 'Grupo padrão'.hardcoded
                    : '${group.permissions.length} recursos configurados'
                          .hardcoded,
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.security,
                  cupertinoIcon: CupertinoIcons.shield,
                ),
                onTap: () {},
              ),
            );
          },
        );
      },
    );
  }
}
