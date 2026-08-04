import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/widgets/open_drawer_icon_button.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
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
    return BaseScaffold(
      onRefresh: () => context.read<SectorsCubit>().loadSectors(),
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
            onPressed: () =>
                context.read<SectorsCubit>().navigateToCreateUpdateSector(),
            platformIcon: const PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: BaseStateView<SectorsCubit, SectorsState, List<SectorEntity>>(
        dataSelector: (state) => state.sectors,
        onRetry: () => context.read<SectorsCubit>().loadSectors(),
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
                child: BaseListTile(
                  platformIcon: const PlatformIcon(
                    materialIcon: Icons.domain,
                    cupertinoIcon: CupertinoIcons.building_2_fill,
                  ),
                  title: sector.name,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BaseIconButton(
                        permission: const ActionPermission.resource(
                          resource: ResourceType.sectors,
                          action: PermissionAction.update,
                        ),
                        onPressed: () => context
                            .read<SectorsCubit>()
                            .navigateToCreateUpdateSector(sector: sector),
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
                            .deleteSector(sector.id),
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
