import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_type.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/assets_dropdown.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/description_field.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/duration_field.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/location_dropdown.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/priority_dropdown.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/programmed_data.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/responsible_dropdown.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/title_field.dart';
import 'package:clean_architecture/features/work_orders/presentation/pages/work_orders/widgets/work_order_type_dropdown.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/session/session_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CreateWorkOrderForm extends HookWidget {
  const CreateWorkOrderForm({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final titleController = useTextEditingController();
    final descController = useTextEditingController();
    final durationController = useTextEditingController();

    final titleFocusNode = useFocusNode();
    final descFocusNode = useFocusNode();
    final durationFocusNode = useFocusNode();

    final selectedLocationId = useState<String?>(null);
    final selectedAssetId = useState<String?>(null);
    final selectedAssignedToId = useState<String?>(null);
    final selectedPriority = useState<Priority>(Priority.medium);
    final selectedType = useState<WorkOrderType>(WorkOrderType.corrective);
    final selectedScheduledDate = useState<DateTime?>(null);

    final (assetsError, assetsLoading) = context.select(
      (AssetsCubit cubit) =>
          (cubit.state.errorMessage, cubit.state.status == StateStatus.loading),
    );
    final (locationsError, locationsLoading) = context.select(
      (LocationsCubit cubit) =>
          (cubit.state.errorMessage, cubit.state.status == StateStatus.loading),
    );
    final (usersError, usersLoading) = context.select(
      (UsersCubit cubit) =>
          (cubit.state.errorMessage, cubit.state.status == StateStatus.loading),
    );

    final isLoading = assetsLoading || locationsLoading || usersLoading;
    final hasError =
        assetsError?.isNotEmpty == true ||
        locationsError?.isNotEmpty == true ||
        usersError?.isNotEmpty == true;

    if (isLoading) {
      return const LoadingCircle();
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Column(
            children: [
              BaseText.error(
                '${assetsError ?? ''}\n${locationsError ?? ''}\n${usersError ?? ''}',
              ),
              gapH32,
              PrimaryButton(
                onTap: () async {
                  await Future.wait([
                    if (assetsError?.isNotEmpty == true)
                      context.read<AssetsCubit>().loadAssets(),
                    if (locationsError?.isNotEmpty == true)
                      context.read<LocationsCubit>().loadLocationsAndAreas(),
                    // if (usersError?.isNotEmpty == true)
                    // context.read<UsersCubit>().loadUsers(),//TODO fix
                  ]);
                },
                text: 'Tentar novamente'.hardcoded,
              ),
            ],
          ),
        ),
      );
    }
    void onSubmit() {
      if (formKey.currentState?.validate() != true) return;

      final sessionUser = context.read<SessionCubit>().state.user;

      Navigator.of(context).pop();
      context.read<WorkOrdersCubit>().saveWorkOrder(
        id: null,
        locationId: selectedLocationId.value!,
        assetId: selectedAssetId.value == '' ? null : selectedAssetId.value,
        assignedToId: selectedAssignedToId.value == ''
            ? null
            : selectedAssignedToId.value,
        createdById: sessionUser.id,
        title: titleController.text.trim(),
        description: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
        priority: selectedPriority.value,
        status: WorkOrderStatus.open,
        type: selectedType.value,
        scheduledDate: selectedScheduledDate.value,
        estimatedDuration: int.tryParse(durationController.text.trim()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(Sizes.p16),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BaseText.titleMedium(
                'Criar ordem de serviço'.hardcoded,
                textAlign: TextAlign.center,
              ),
              gapH16,
              TitleField(
                titleController: titleController,
                titleFocusNode: titleFocusNode,
                descFocusNode: descFocusNode,
              ),
              gapH16,
              DescriptionField(
                descController: descController,
                descFocusNode: descFocusNode,
              ),
              gapH16,
              LocationDropdown(
                selectedId: selectedLocationId.value,
                onChanged: (val) {
                  selectedLocationId.value = val;
                  selectedAssetId.value = null;
                },
              ),
              gapH16,
              AssetsDropdown(
                selectedAssetId: selectedAssetId.value,
                selectedLocationId: selectedLocationId.value,
                onChanged: (val) => selectedAssetId.value = val,
              ),
              gapH16,
              ResponsibleDropdown(
                onChanged: (val) => selectedAssignedToId.value = val,
                responsibleId: selectedAssignedToId.value,
              ),
              gapH16,
              Row(
                children: [
                  Expanded(
                    child: WorkOrderTypeDropdown(
                      onChanged: (v) => selectedType.value = v,
                      selectedType: selectedType.value,
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: PriorityDropdown(
                      onChanged: (v) => selectedPriority.value = v,
                      selectedPriority: selectedPriority.value,
                    ),
                  ),
                ],
              ),
              gapH16,
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DurationField(
                        durationController: durationController,
                        durationFocusNode: durationFocusNode,
                        onSubmit: onSubmit,
                      ),
                    ),
                    gapW16,
                    Expanded(
                      child: ProgrammedData(
                        selectedScheduledDate: selectedScheduledDate.value,
                        onChanged: (v) => selectedScheduledDate.value = v,
                      ),
                    ),
                  ],
                ),
              ),
              gapH24,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BaseTextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Cancelar'.hardcoded,
                  ),
                  gapW64,
                  PrimaryButton(
                    onTap: onSubmit,
                    width: Sizes.p120,
                    text: 'Criar'.hardcoded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
