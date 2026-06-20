import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteLocationButton extends StatelessWidget {
  const DeleteLocationButton({super.key, required this.location});
  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      onPressed: () {
        showAlertDialog(
          context: context,
          title: 'Excluir local?'.hardcoded,
          onOkPressed: () =>
              context.read<LocationsCubit>().deleteLocation(location.id),
          contentText: 'Tem certeza que deseja excluir o local?'.hardcoded,
          defaultActionText: 'Sim'.hardcoded,
          cancelActionText: 'Cancelar'.hardcoded,
        );
      },
      platformIcon: const PlatformIcon(
        cupertinoIcon: CupertinoIcons.trash,
        materialIcon: Icons.delete_outline,
        color: Colors.red,
      ),
    );
  }
}
