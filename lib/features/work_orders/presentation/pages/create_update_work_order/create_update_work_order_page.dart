import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachments.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/assets_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/delete_work_order_icon_button.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/description_field.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/duration_field.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/location_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/priority_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/programmed_data.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/responsible_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/title_field.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/try_again_button.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/work_order_status_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/work_order_type_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:uuid/uuid.dart';

@RoutePage()
class CreateUpdateWorkOrderPage extends HookWidget {
  const CreateUpdateWorkOrderPage({super.key, this.workOrder});

  final WorkOrderEntity? workOrder;

  @override
  Widget build(BuildContext context) {
    final workOrderId = useMemoized(() => workOrder?.id ?? const Uuid().v4());
    final formKey = useMemoized(GlobalKey<FormState>.new);

    observeLoading(
      [context.read<WorkOrdersCubit>()],
      statuses: {StateStatus.saving, StateStatus.deleting},
    );

    return BlocProvider<AttachmentsCubit>(
      create: (context) => GetIt.I<AttachmentsCubit>()..init(workOrderId),
      child: _CreateUpdatePage(
        workOrder: workOrder,
        formKey: formKey,
        workOrderId: workOrderId,
      ),
    );
  }
}

class _CreateUpdatePage extends HookWidget {
  const _CreateUpdatePage({
    required this.workOrder,
    required this.formKey,
    required this.workOrderId,
  });

  final WorkOrderEntity? workOrder;
  final GlobalKey<FormState> formKey;
  final String workOrderId;

  @override
  Widget build(BuildContext context) {
    final selectedScheduledDate = useState<DateTime?>(workOrder?.scheduledDate);

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
    } else if (hasError) {
      return TryAgainButton(
        assetsError: assetsError,
        locationsError: locationsError,
        usersError: usersError,
      );
    }

    final titleController = useTextEditingController(text: workOrder?.title);
    final descController = useTextEditingController(
      text: workOrder?.description,
    );
    final durationController = useTextEditingController(
      text: workOrder?.estimatedDuration?.toString() ?? '',
    );

    final titleFocusNode = useFocusNode();
    final descFocusNode = useFocusNode();
    final durationFocusNode = useFocusNode();

    final selectedLocationId = useState<String?>(workOrder?.locationId);
    final selectedAssetId = useState<String?>(workOrder?.assetId);
    final selectedAssignedToId = useState<String?>(workOrder?.assignedToId);
    final selectedPriority = useState<Priority>(
      workOrder?.priority ?? Priority.medium,
    );
    final selectedType = useState<WorkOrderType>(
      workOrder?.type ?? WorkOrderType.corrective,
    );
    final selectedStatus = useState<WorkOrderStatus>(
      workOrder?.status ?? WorkOrderStatus.open,
    );
    Future<void> onSubmit() async {
      if (formKey.currentState?.validate() != true) return;

      final sessionUser = context.read<SessionCubit>().state.user;

      final succeeds = await context.read<WorkOrdersCubit>().saveWorkOrder(
        id: workOrderId,
        locationId: selectedLocationId.value!,
        assetId: selectedAssetId.value == '' ? null : selectedAssetId.value,
        assignedToId: selectedAssignedToId.value == ''
            ? null
            : selectedAssignedToId.value,
        createdById: workOrder?.createdById ?? sessionUser.id,
        title: titleController.text.trim(),
        description: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
        priority: selectedPriority.value,
        status: selectedStatus.value,
        type: selectedType.value,
        scheduledDate: selectedScheduledDate.value,
        estimatedDuration: int.tryParse(durationController.text.trim()),
        createdAt: workOrder?.createdAt,
        actualDuration: workOrder?.actualDuration,
        completedAt: workOrder?.completedAt,
        laborCost: workOrder?.laborCost,
        maintenancePlanId: workOrder?.maintenancePlanId,
        notes: workOrder?.notes,
        partsCost: workOrder?.partsCost,
        startedAt: workOrder?.startedAt,
        totalCost: workOrder?.totalCost,
      );
      if (succeeds && context.mounted) Navigator.of(context).pop();
    }

    return BaseScaffold(
      appBar: BaseAppBar(
        title: workOrder == null
            ? 'Criando ordem de serviço'.hardcoded
            : 'Editando ordem de serviço'.hardcoded,
        actions: [DeleteWorkOrderIconButton(id: workOrder?.id)],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              if (workOrder != null) ...[
                WorkOrderStatusDropdown(
                  onChanged: (v) => selectedStatus.value = v,
                  selectedStatus: selectedStatus.value,
                ),
                gapH16,
              ],
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
              gapH16,
              const Attachments(),
              gapH24,
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Flexible(
                    child: BaseTextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      text: 'Cancelar'.hardcoded,
                      color: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: PrimaryButton(
                      onTap: onSubmit,
                      width: Sizes.p120,
                      text: 'Salvar'.hardcoded,
                    ),
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
