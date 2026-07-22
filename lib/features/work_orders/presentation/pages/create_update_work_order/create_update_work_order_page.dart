import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/widgets/attachments.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/assets_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/create_service_provider_company_dialog.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/create_sla_policy_dialog.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/description_field.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/duration_field.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/location_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/priority_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/programmed_data.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/responsible_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/service_provider_company_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/service_provider_profile_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/sla_policy_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/title_field.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/try_again_button.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/work_order_status_dropdown.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/create_update_work_order/widgets/work_order_type_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';
import 'package:uuid/uuid.dart';

@RoutePage()
class CreateUpdateWorkOrderPage extends HookWidget {
  const CreateUpdateWorkOrderPage({super.key, this.workOrderId});
  final String? workOrderId;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final currentWorkOrderId = useMemoized(
      () => workOrderId ?? const Uuid().v4(),
    );

    observeLoading(
      [context.read<WorkOrdersCubit>()],
      statuses: {StateStatus.saving, StateStatus.deleting},
    );

    return Builder(
      builder: (context) {
        final sessionUser = context.read<SessionCubit>().state.user;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  GetIt.I<AttachmentsCubit>()..init(currentWorkOrderId),
            ),
            BlocProvider(
              create: (context) =>
                  GetIt.I<ServiceProvidersCubit>()
                    ..loadCompanies(sessionUser.companyId),
            ),
            BlocProvider(
              create: (context) =>
                  GetIt.I<SlaPoliciesCubit>()..loadSlaPolicies(),
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

    final initialTitle = workOrder?.title ?? '';
    final initialDescription = workOrder?.description ?? '';
    final initialDuration = workOrder?.estimatedDuration?.toString() ?? '';
    final initialLocationId = workOrder?.locationId;
    final initialAssetId = workOrder?.assetId;
    final initialAssignedToId = workOrder?.assignedToId;
    final initialPriority = workOrder?.priority ?? Priority.medium;
    final initialType = workOrder?.type ?? WorkOrderType.corrective;
    final initialStatus = workOrder?.status ?? WorkOrderStatus.open;
    final initialScheduledDate = workOrder?.scheduledDate;
    final initialServiceProviderCompanyId = workOrder?.serviceProviderCompanyId;
    final initialProviderProfileId = workOrder?.providerProfileId;
    final initialSlaPolicyId = workOrder?.slaPolicyId;

    final titleController = useTextEditingController(text: initialTitle);
    final descController = useTextEditingController(text: initialDescription);
    final durationController = useTextEditingController(text: initialDuration);
    final selectedLocationId = useState<String?>(initialLocationId);
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

    final titleFocusNode = useFocusNode();
    final descFocusNode = useFocusNode();
    final durationFocusNode = useFocusNode();

    useEffect(() {
      if (initialServiceProviderCompanyId != null) {
        context.read<ServiceProvidersCubit>().selectCompany(
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

    void onCompanyChanged(String? val) {
      selectedServiceProviderCompanyId.value = val;
      selectedProviderProfileId.value = null;
      context.read<ServiceProvidersCubit>().selectCompany(val);
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
        attachmentsCubit: context.read<AttachmentsCubit>(),
        serviceProviderCompanyId: selectedServiceProviderCompanyId.value,
        providerProfileId: selectedProviderProfileId.value,
        slaPolicyId: selectedSlaPolicyId.value,
      );
      if (succeeds && context.mounted) {
        Navigator.of(context).pop(true);
      } else {
        if (context.mounted) {
          unawaited(context.read<AttachmentsCubit>().init(workOrderId));
        }
      }
    }

    final items = [
      TitleField(
        titleController: titleController,
        titleFocusNode: titleFocusNode,
        descFocusNode: descFocusNode,
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: DescriptionField(
          descController: descController,
          descFocusNode: descFocusNode,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: ResponsibleDropdown(
          onChanged: (val) => selectedAssignedToId.value = val,
          responsibleId: selectedAssignedToId.value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ServiceProviderCompanyDropdown(
                selectedCompanyId: selectedServiceProviderCompanyId.value,
                onChanged: onCompanyChanged,
              ),
            ),
            gapW8,
            BaseIconButton(
              onPressed: () async {
                final result = await CreateServiceProviderCompanyDialog.show(
                  context,
                );
                //TODO should save in the CreateServiceProviderCompanyDialog to avoid losing the data then it throws
                if (result != null && context.mounted) {
                  final sessionUser = context.read<SessionCubit>().state.user;
                  final company = result.copyWith(
                    companyId: sessionUser.companyId,
                  );
                  final cubit = context.read<ServiceProvidersCubit>();
                  final success = await cubit.saveCompany(company);
                  if (success && context.mounted) {
                    final newCompany = cubit.state.companies.firstWhereOrNull(
                      (c) => c.name == company.name,
                    );
                    if (newCompany != null) {
                      onCompanyChanged(newCompany.id);
                    }
                  }
                }
              },
              platformIcon: const PlatformIcon(
                materialIcon: Icons.add,
                cupertinoIcon: CupertinoIcons.add,
              ),
              permission: const ActionPermission(
                resource: ResourceType.serviceProviders,
                action: PermissionAction.create,
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: ServiceProviderProfileDropdown(
          selectedProfileId: selectedProviderProfileId.value,
          onChanged: (val) => selectedProviderProfileId.value = val,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: Row(
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
      ),
      if (workOrder != null) ...[
        Padding(
          padding: const EdgeInsets.only(top: Sizes.p8),
          child: WorkOrderStatusDropdown(
            onChanged: (v) => selectedStatus.value = v,
            selectedStatus: selectedStatus.value,
          ),
        ),
      ],
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: LocationDropdown(
          selectedId: selectedLocationId.value,
          onChanged: (val) {
            selectedLocationId.value = val;
            selectedAssetId.value = null;
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: AssetsDropdown(
          selectedAssetId: selectedAssetId.value,
          selectedLocationId: selectedLocationId.value,
          onChanged: (val) => selectedAssetId.value = val,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SlaPolicyDropdown(
                selectedSlaPolicyId: selectedSlaPolicyId.value,
                onChanged: (val) => selectedSlaPolicyId.value = val,
              ),
            ),
            gapW8,
            BaseIconButton(
              onPressed: () async {
                final result = await CreateSlaPolicyDialog.show(context);
                //TODO should save in the CreateSlaPolicyDialog to avoid losing the data then it throws
                if (result != null && context.mounted) {
                  final cubit = context.read<SlaPoliciesCubit>();
                  final success = await cubit.saveSlaPolicy(
                    name: result.name,
                    targetHours: result.targetHours,
                    appliesTo: result.appliesTo,
                  );
                  if (success && context.mounted) {
                    final newPolicy = cubit.state.slaPolicies.firstWhereOrNull(
                      (p) => p.name == result.name,
                    );
                    if (newPolicy != null) {
                      selectedSlaPolicyId.value = newPolicy.id;
                    }
                  }
                }
              },
              platformIcon: const PlatformIcon(
                materialIcon: Icons.add,
                cupertinoIcon: CupertinoIcons.add,
              ),
            ),
          ],
        ),
      ),
      IntrinsicHeight(
        child: SizedBox(
          height: Sizes.p80,
          child: Row(
            crossAxisAlignment: .stretch,
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
          BaseIconButton(
            onPressed: onSubmit,
            platformIcon: const PlatformIcon(
              materialIcon: Icons.save,
              cupertinoIcon: CupertinoIcons.check_mark,
            ),
          ),
        ],
      ),
      body: Form(
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
            Attachments(workOrderId: workOrderId, isEditing: true),
          ],
        ),
      ),
    );
  }
}
