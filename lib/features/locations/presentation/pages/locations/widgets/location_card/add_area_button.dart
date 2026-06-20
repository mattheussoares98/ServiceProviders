import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/create_area/create_area_dialog.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddAreaButton extends StatelessWidget {
  const AddAreaButton({super.key, required this.location});
  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    return BaseTextButton(
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<LocationsCubit>(),
            child: CreateAreaDialog(
              locationId: location.id,
              companyId: location.companyId,
            ),
          ),
        );
      },
      platformIcon: const PlatformIcon(
        materialIcon: Icons.add,
        cupertinoIcon: CupertinoIcons.add,
      ),
      text: 'Adicionar área'.hardcoded,
    );
  }
}
