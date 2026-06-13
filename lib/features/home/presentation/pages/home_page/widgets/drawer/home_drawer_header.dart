import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_image_widget.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The premium header component of the HomeDrawer, styled with linear gradients.
class HomeDrawerHeader extends StatelessWidget {
  const HomeDrawerHeader({super.key});

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
                        child: CircleAvatar(
                          radius: Sizes.p48,
                          backgroundColor: context.theme.colorScheme.onPrimary,
                          child: PlatformIcon(
                            materialIcon: Icons.person,
                            cupertinoIcon: CupertinoIcons.person,
                            size: 35,
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: BaseIconButton(
                          onPressed: () {
                            //TODO add option to change the image
                          },
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
