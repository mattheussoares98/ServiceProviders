import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachments.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/get_new_date.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/number_validator.dart';
import 'package:uuid/uuid.dart';

part './widgets/area_dropdown.dart';
part './widgets/assets_dropdown.dart';
part './widgets/description_field.dart';
part './widgets/duration_field.dart';
part './widgets/location_dropdown.dart';
part './widgets/priority_dropdown.dart';
part './widgets/programmed_data.dart';
part './widgets/responsible_dropdown.dart';
part './widgets/service_provider_company_dropdown.dart';
part './widgets/service_provider_profile_dropdown.dart';
part './widgets/sla_policy_dropdown.dart';
part './widgets/title_field.dart';
part './widgets/try_again_button.dart';
part './widgets/work_order_status_dropdown.dart';
part './widgets/work_order_type_dropdown.dart';

@RoutePage()
class CreateUpdateWorkOrderPage extends HookWidget {
  const CreateUpdateWorkOrderPage({
    super.key,
    this.workOrderId,
    this.attachmentsCubit,
  });
  final String? workOrderId;
  final AttachmentsCubit? attachmentsCubit;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final currentWorkOrderId = useMemoized(
      () => workOrderId ?? const Uuid().v4(),
    );

    observeLoading([
      ObservedLoadingTarget(
        context.read<WorkOrdersCubit>(),
        statuses: {StateStatus.saving, StateStatus.deleting},
      ),
    ]);

    return Builder(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            if (attachmentsCubit != null)
              BlocProvider.value(value: attachmentsCubit!)
            else
              BlocProvider(
                create: (context) =>
                    GetIt.I<AttachmentsCubit>(param1: currentWorkOrderId),
              ),
          ],
          child:
              BlocSelector<WorkOrdersCubit, WorkOrdersState, WorkOrderEntity?>(
                selector: (state) => state.workOrders.firstWhereOrNull(
                  (e) => e.id == currentWorkOrderId,
                ),
                builder: (context, workOrder) {
                  return _CreateUpdatePage(
                    workOrder: workOrder,
                    formKey: formKey,
                    workOrderId: currentWorkOrderId,
                  );
                },
              ),
        );
      },
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
    final selectedModeName = GetIt.I<GetSelectedModeUseCase>().call();
    final isProviderMode = AppMode.fromName(selectedModeName) == AppMode.provider;
    final isEditing = workOrder != null;

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
    final (providersError, providersLoading) = context.select(
      (ServiceProvidersCubit cubit) =>
          (cubit.state.errorMessage, cubit.state.status == StateStatus.loading),
    );
    final isLoading = isProviderMode
        ? providersLoading
        : (assetsLoading ||
            locationsLoading ||
            usersLoading ||
            providersLoading);
    final hasError = isProviderMode
        ? providersError?.isNotEmpty == true
        : (assetsError?.isNotEmpty == true ||
            locationsError?.isNotEmpty == true ||
            usersError?.isNotEmpty == true ||
            providersError?.isNotEmpty == true);

    final initialTitle = workOrder?.title ?? '';
    final initialDescription = workOrder?.description ?? '';
    final initialDuration = workOrder?.estimatedDuration?.toString() ?? '';
    final initialLocationId = workOrder?.locationId;
    final initialAreaId = workOrder?.areaId;
    final initialAssetId = workOrder?.assetId;
    final initialAssignedToId = workOrder?.assignedToId;
    final initialPriority = workOrder?.priority ?? Priority.medium;
    final initialType = workOrder?.type ?? WorkOrderType.corrective;
    final initialStatus = workOrder?.status ?? WorkOrderStatus.open;
    final initialScheduledDate = workOrder?.scheduledDate;
    final initialServiceProviderCompanyId = workOrder?.serviceProviderCompanyId;
    final initialProviderProfileId = workOrder?.providerProfileId;
    final initialSlaPolicyId = workOrder?.slaPolicyId;

    final isProviderCreator =
        isEditing &&
        (workOrder?.openedBy == AppMode.provider ||
            workOrder?.createdByProviderProfileId != null);
    final canEditCoreFields = !isProviderMode || isProviderCreator;
    final canAssignInternalResponsible = !isProviderMode;
    final canChangeProviderCompany = !isProviderMode;
    final canEditSlaPolicy = !isProviderMode;

    final titleController = useTextEditingController(text: initialTitle);
    final descController = useTextEditingController(text: initialDescription);
    final durationController = useTextEditingController(text: initialDuration);
    final descFocusNode = useFocusNode();
    final selectedLocationId = useState<String?>(initialLocationId);
    final selectedAreaId = useState<String?>(initialAreaId);
    final selectedAssetId = useState<String?>(initialAssetId);
    final selectedAssignedToId = useState<String?>(initialAssignedToId);
    final selectedPriority = useState<Priority>(initialPriority);
    final selectedType = useState<WorkOrderType>(initialType);
    final selectedStatus = useState<WorkOrderStatus>(initialStatus);
    final selectedScheduledDate = useState<DateTime?>(initialScheduledDate);
    final selectedServiceProviderCompanyId = useState<String?>(
      initialServiceProviderCompanyId,
    );
    final selectedProviderProfileId = useState<String?>(
      initialProviderProfileId,
    );
    final selectedSlaPolicyId = useState<String?>(initialSlaPolicyId);

    useEffect(() {
      if (initialServiceProviderCompanyId != null) {
        context.read<ServiceProvidersCubit>().ensureProfilesLoaded(
          initialServiceProviderCompanyId,
        );
      }
      return null;
    }, [initialServiceProviderCompanyId]);

    bool getHasChanges() {
      final attachmentsState = context.read<AttachmentsCubit>().state;
      final hasAttachmentChanges =
          attachmentsState.pendingDeletions.isNotEmpty ||
          attachmentsState.attachments.any(
            (e) => e.uploadStatus == UploadStatus.pending,
          );

      if (hasAttachmentChanges) return true;

      final hasChanges =
          titleController.text.trim() != initialTitle ||
          descController.text.trim() != initialDescription ||
          durationController.text.trim() != initialDuration ||
          selectedLocationId.value != initialLocationId ||
          selectedAreaId.value != initialAreaId ||
          (selectedAssetId.value == '' ? null : selectedAssetId.value) !=
              initialAssetId ||
          (selectedAssignedToId.value == ''
                  ? null
                  : selectedAssignedToId.value) !=
              initialAssignedToId ||
          selectedPriority.value != initialPriority ||
          selectedType.value != initialType ||
          selectedStatus.value != initialStatus ||
          selectedScheduledDate.value != initialScheduledDate ||
          selectedServiceProviderCompanyId.value !=
              initialServiceProviderCompanyId ||
          selectedProviderProfileId.value != initialProviderProfileId ||
          selectedSlaPolicyId.value != initialSlaPolicyId;

      return hasChanges;
    }

    Future<void> onSubmit() async {
      if (formKey.currentState?.validate() != true) return;
      if (!getHasChanges()) {
        Navigator.of(context).pop();
        return;
      }

      final pressedOk = await showAlertDialog(
        context: context,
        title: 'Salvar alterações?'.hardcoded,
        defaultActionText: 'Sim'.hardcoded,
        cancelActionText: 'Não'.hardcoded,
      );

      if (pressedOk != true || !context.mounted) return;

      final sessionUser = context.read<SessionCubit>().state.user;

      final succeeds = await context.read<WorkOrdersCubit>().saveWorkOrder(
        id: workOrderId,
        isEditing: workOrder != null,
        locationId: selectedLocationId.value!,
        areaId: selectedAreaId.value,
        assetId: selectedAssetId.value == '' ? null : selectedAssetId.value,
        assignedToId: selectedAssignedToId.value == ''
            ? null
            : selectedAssignedToId.value,
        createdById: workOrder != null
            ? workOrder?.createdById
            : sessionUser.id,
        createdByProviderProfileId: workOrder?.createdByProviderProfileId,
        openedBy: workOrder?.openedBy ?? (isProviderMode ? AppMode.provider : AppMode.internal),
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
        attachmentsCubit: context.read<AttachmentsCubit>(),
        serviceProviderCompanyId: selectedServiceProviderCompanyId.value,
        providerProfileId: selectedProviderProfileId.value,
        slaPolicyId: selectedSlaPolicyId.value,
      );
      if (succeeds && context.mounted) {
        Navigator.of(context).pop(true);
      } else {
        if (context.mounted) {
          unawaited(context.read<AttachmentsCubit>().refreshAttachments());
        }
      }
    }

    final items = [
      _TitleField(
        controller: titleController,
        enabled: canEditCoreFields,
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: _DescriptionField(
          controller: descController,
          enabled: canEditCoreFields,
        ),
      ),
      if (canAssignInternalResponsible)
        Padding(
          padding: const EdgeInsets.only(top: Sizes.p8),
          child: _ResponsibleDropdown(
            selectedId: selectedAssignedToId.value,
            onChanged: (val) => selectedAssignedToId.value = val,
          ),
        ),
      _ServiceProviderCompanyDropdown(
        //* handling the padding in the widget
        selectedCompanyId: selectedServiceProviderCompanyId.value,
        onChanged: canChangeProviderCompany
            ? (val) {
                selectedServiceProviderCompanyId.value = val;
                selectedProviderProfileId.value = null;
              }
            : null,
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: _ServiceProviderProfileDropdown(
          companyId: selectedServiceProviderCompanyId.value,
          selectedProfileId: selectedProviderProfileId.value,
          onChanged: (val) => selectedProviderProfileId.value = val,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: Row(
          children: [
            Expanded(
              child: _WorkOrderTypeDropdown(
                selectedType: selectedType.value,
                onChanged: canEditCoreFields
                    ? (v) => selectedType.value = v
                    : null,
              ),
            ),
            gapW16,
            Expanded(
              child: _PriorityDropdown(
                selectedPriority: selectedPriority.value,
                onChanged: canEditCoreFields
                    ? (v) => selectedPriority.value = v
                    : null,
              ),
            ),
          ],
        ),
      ),
      if (workOrder != null && !isProviderMode) ...[
        Padding(
          padding: const EdgeInsets.only(top: Sizes.p8),
          child: _WorkOrderStatusDropdown(
            selectedStatus: selectedStatus.value,
            onChanged: (v) => selectedStatus.value = v,
          ),
        ),
      ],
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: _LocationDropdown(
          selectedId: selectedLocationId.value,
          onChanged: canEditCoreFields
              ? (val) {
                  selectedLocationId.value = val;
                  selectedAreaId.value = null;
                  selectedAssetId.value = null;
                }
              : null,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: _AreaDropdown(
          selectedAreaId: selectedAreaId.value,
          selectedLocationId: selectedLocationId.value,
          onChanged: canEditCoreFields
              ? (val) {
                  selectedAreaId.value = val;
                  selectedAssetId.value = null;
                }
              : null,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: _AssetsDropdown(
          selectedAssetId: selectedAssetId.value,
          selectedLocationId: selectedLocationId.value,
          selectedAreaId: selectedAreaId.value,
          applyAssociatedAreaId: (val) {
            if (canEditCoreFields) {
              selectedAreaId.value = val;
            }
          },
          onChanged: canEditCoreFields
              ? (val) {
                  selectedAssetId.value = val;
                }
              : null,
        ),
      ),
      if (canEditSlaPolicy)
        Padding(
          padding: const EdgeInsets.only(top: Sizes.p8),
          child: _SlaPolicyDropdown(
            selectedSlaPolicyId: selectedSlaPolicyId.value,
            onChanged: (val) {
              selectedSlaPolicyId.value = val;
              durationController.clear();
            },
          ),
        ),
      IntrinsicHeight(
        child: SizedBox(
          height: Sizes.p80,
          child: Row(
            crossAxisAlignment: .stretch,
            children: [
              Expanded(
                child: _DurationField(
                  controller: durationController,
                  descFocusNode: descFocusNode,
                  onSubmit: (canEditCoreFields &&
                          selectedSlaPolicyId.value == null)
                      ? onSubmit
                      : null,
                  enabled: canEditCoreFields &&
                      selectedSlaPolicyId.value == null,
                ),
              ),
              gapW16,
              Expanded(
                child: _ProgrammedData(
                  enabled: canEditCoreFields,
                  scheduledDate: selectedScheduledDate.value,
                  onChanged: canEditCoreFields
                      ? (v) => selectedScheduledDate.value = v
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return BaseScaffold(
      isScrollable: false,
      onPopInvokedWithResult: () async {
        if (!getHasChanges()) {
          Navigator.of(context).pop();
          return;
        }
        final discard = await showAlertDialog(
          context: context,
          title: 'Descartar alterações?'.hardcoded,
          contentText:
              'Você tem alterações não salvas. Tem certeza que deseja descartar e sair?'
                  .hardcoded,
          cancelActionText: 'Continuar editando'.hardcoded,
          defaultActionText: 'Descartar'.hardcoded,
        );
        if (discard == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      appBar: BaseAppBar(
        title: workOrder == null
            ? 'Criando ordem de serviço'.hardcoded
            : 'Editando ordem de serviço'.hardcoded,
        actions: [
          if (!isLoading && !hasError)
            BaseIconButton(
              onPressed: onSubmit,
              platformIcon: const PlatformIcon(
                materialIcon: Icons.save,
                cupertinoIcon: CupertinoIcons.check_mark,
              ),
            ),
        ],
      ),
      body: isLoading
          ? const LoadingCircle()
          : hasError
          ? _TryAgainButton(
              assetsError: assetsError,
              locationsError: locationsError,
              usersError: usersError,
              providersError: providersError,
            )
          : Form(
              key: formKey,
              child: CustomScrollView(
                slivers: [
                  ResponsiveListFlow(
                    isSliver: true,
                    maxItemWidth: ScreenType.phone.maxWidth,
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return item;
                    },
                  ),
                  Attachments(
                    isEditing: true,
                    workOrderCompanyId: workOrder?.companyId,
                  ),
                ],
              ),
            ),
    );
  }
}
