import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_image_widget.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
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
                  bottom: Sizes.p12,
                  left: Sizes.p12,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: context.theme.colorScheme.onPrimary,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: context.theme.colorScheme.primary,
                    ),
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
