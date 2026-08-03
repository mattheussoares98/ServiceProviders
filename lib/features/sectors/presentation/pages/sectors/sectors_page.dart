import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

@RoutePage()
class SectorsPage extends StatelessWidget {
  const SectorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final companyId = context.read<SessionCubit>().state.user.companyId;

    return BaseScaffold(
      onRefresh: () => context.read<SectorsCubit>().loadSectors(companyId),
      isScrollable: false,
      appBar: BaseAppBar(
        title: 'Setores'.hardcoded,
        leading: const OpenDrawerIconButton(),
        actions: [
          BaseIconButton(
            permission: const ActionPermission.resource(
              resource: ResourceType.sectors,
              action: PermissionAction.create,
            ),
            onPressed: () async {
              final result = await context.router.push(
                CreateUpdateSectorRoute(),
              );
              if (result == true && context.mounted) {
                unawaited(context.read<SectorsCubit>().loadSectors(companyId));
              }
            },
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: BaseStateView<SectorsCubit, SectorsState, List<SectorEntity>>(
        dataSelector: (state) => state.sectors,
        onRetry: () => context.read<SectorsCubit>().loadSectors(companyId),
        builder: (context, sectors) {
          if (sectors.isEmpty) {
            return Center(
              child: BaseText.bodyMedium('Nenhum setor cadastrado'.hardcoded),
            );
          }

          return ResponsiveListFlow(
            itemCount: sectors.length,
            itemBuilder: (context, index) {
              final sector = sectors[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.domain)),
                  title: BaseText.titleMedium(sector.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BaseIconButton(
                        permission: const ActionPermission.resource(
                          resource: ResourceType.sectors,
                          action: PermissionAction.update,
                        ),
                        onPressed: () async {
                          final result = await context.router.push(
                            CreateUpdateSectorRoute(sector: sector),
                          );
                          if (result == true && context.mounted) {
                            unawaited(
                              context.read<SectorsCubit>().loadSectors(
                                companyId,
                              ),
                            );
                          }
                        },
                        platformIcon: const PlatformIcon(
                          materialIcon: Icons.edit_outlined,
                          cupertinoIcon: CupertinoIcons.pencil,
                        ),
                      ),
                      BaseIconButton(
                        permission: const ActionPermission.resource(
                          resource: ResourceType.sectors,
                          action: PermissionAction.delete,
                        ),
                        onPressed: () => context
                            .read<SectorsCubit>()
                            .deleteSector(sector.id, companyId),
                        platformIcon: const PlatformIcon(
                          materialIcon: Icons.delete_outline,
                          cupertinoIcon: CupertinoIcons.trash,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
