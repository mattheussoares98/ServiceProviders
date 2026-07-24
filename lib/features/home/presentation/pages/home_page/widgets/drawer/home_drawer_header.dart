import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

/// The premium header component of the HomeDrawer, styled with linear gradients.
class HomeDrawerHeader extends StatelessWidget {
  const HomeDrawerHeader({super.key});

  void _showImageSourcePicker(BuildContext context) {
    showModalPage<void>(
      Padding(
        padding: const EdgeInsets.fromLTRB(
          Sizes.p24,
          Sizes.p8,
          Sizes.p24,
          Sizes.p24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BaseText.title('Alterar foto de perfil'.hardcoded),
            ),
            const SizedBox(height: Sizes.p16),
            BaseListTile(
              padding: EdgeInsets.zero,
              platformIcon: const PlatformIcon(
                materialIcon: Icons.camera_alt_outlined,
                cupertinoIcon: CupertinoIcons.camera,
              ),
              title: 'Tirar foto'.hardcoded,
              onTap: () {
                Navigator.pop(context);
                context.read<HomeCubit>().changeAvatar(
                  AttachmentSource.cameraPhoto,
                );
              },
            ),
            const Divider(height: 1),
            BaseListTile(
              padding: EdgeInsets.zero,
              platformIcon: const PlatformIcon(
                materialIcon: Icons.photo_library_outlined,
                cupertinoIcon: CupertinoIcons.photo,
              ),
              title: 'Escolher da galeria'.hardcoded,
              onTap: () {
                Navigator.pop(context);
                context.read<HomeCubit>().changeAvatar(
                  AttachmentSource.gallery,
                );
              },
            ),
          ],
        ),
      ),
      context,
      useDraggable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Stack(
              children: [
                BlocSelector<CompanyCubit, CompanyState, String?>(
                  selector: (state) => state.company?.logoUrl,
                  builder: (context, imageUrl) {
                    return BaseImageWidget(
                      source: BaseImageSource.network(imageUrl),
                      width: constraints.maxWidth,
                      enableFullScreenOnTap: true,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(Sizes.p8),
                        bottomRight: Radius.circular(Sizes.p8),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(Sizes.p12),
                        child:
                            BlocSelector<
                              SessionCubit,
                              SessionState,
                              UserProfileEntity
                            >(
                              selector: (state) => state.user,
                              builder: (context, user) {
                                final avatarUrl = user.avatarUrl;
                                return CircleAvatar(
                                  radius: Sizes.p48,
                                  backgroundColor:
                                      context.theme.colorScheme.onPrimary,
                                  child:
                                      avatarUrl != null && avatarUrl.isNotEmpty
                                      ? ClipOval(
                                          child: BaseImageWidget(
                                            source: BaseImageSource.network(
                                              avatarUrl,
                                            ),
                                            width: Sizes.p80,
                                            height: Sizes.p80,
                                            enableFullScreenOnTap: true,
                                          ),
                                        )
                                      : PlatformIcon(
                                          materialIcon: Icons.person,
                                          cupertinoIcon: CupertinoIcons.person,
                                          size: 35,
                                          color:
                                              context.theme.colorScheme.primary,
                                        ),
                                );
                              },
                            ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: BaseIconButton(
                          onPressed: () => _showImageSourcePicker(context),
                          platformIcon: const PlatformIcon(
                            materialIcon: Icons.add_a_photo,
                            cupertinoIcon: CupertinoIcons.photo_camera_solid,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
