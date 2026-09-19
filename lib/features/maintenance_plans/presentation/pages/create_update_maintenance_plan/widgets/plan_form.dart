import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/interval_unit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/cubits/maintenance_plans/maintenance_plans_cubit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/pages/create_update_maintenance_plan/widgets/plan_assignment_selectors.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/pages/create_update_maintenance_plan/widgets/plan_location_selectors.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/pages/create_update_maintenance_plan/widgets/plan_schedule_selectors.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/pages/create_update_maintenance_plan/widgets/plan_text_fields.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:uuid/uuid.dart';

class PlanForm extends HookWidget {
  const PlanForm({super.key, this.maintenancePlan});
  final MaintenancePlanEntity? maintenancePlan;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final titleCtrl = useTextEditingController(text: maintenancePlan?.title);
    final descCtrl = useTextEditingController(
      text: maintenancePlan?.description,
    );
    final priceCtrl = useTextEditingController(
      text: maintenancePlan?.price?.toString() ?? '',
    );
    final priceFocusNode = useFocusNode();
    final intervalValCtrl = useTextEditingController(
      text: (maintenancePlan?.intervalValue ?? 1).toString(),
    );
    final intervalValFocusNode = useFocusNode();
    final leadTimeCtrl = useTextEditingController(
      text: (maintenancePlan?.leadTimeDays ?? 2).toString(),
    );
    final leadTimeFocusNode = useFocusNode();
    final durationCtrl = useTextEditingController(
      text: (maintenancePlan?.durationDays ?? 1).toString(),
    );
    final durationFocusNode = useFocusNode();
    final intervalUnit = useState(
      maintenancePlan?.intervalUnit ?? IntervalUnit.months,
    );
    final priority = useState(maintenancePlan?.priority ?? Priority.medium);
    final locationId = useState(maintenancePlan?.locationId);
    final areaId = useState(maintenancePlan?.areaId);
    final assetId = useState(maintenancePlan?.assetId);
    final checklistId = useState(maintenancePlan?.checklistTemplateId);
    final assignedToId = useState(maintenancePlan?.assignedToId);
    final spCompanyId = useState(maintenancePlan?.serviceProviderCompanyId);
    final isActive = useState(maintenancePlan?.isActive ?? true);
    final cubit = context.read<MaintenancePlansCubit>();

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;
      final session = context.read<SessionCubit>().state.user;
      final now = DateTime.now().toUtc();
      final plan = MaintenancePlanEntity(
        id: maintenancePlan?.id ?? const Uuid().v4(),
        companyId: maintenancePlan?.companyId ?? session.companyId,
        locationId: locationId.value,
        areaId: areaId.value,
        assetId: assetId.value,
        checklistTemplateId: checklistId.value,
        assignedToId: assignedToId.value,
        serviceProviderCompanyId: spCompanyId.value,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        priority: priority.value,
        price: double.tryParse(priceCtrl.text.trim().replaceAll(',', '.')),
        currency: maintenancePlan?.currency ?? 'BRL',
        intervalValue: int.tryParse(intervalValCtrl.text.trim()) ?? 1,
        intervalUnit: intervalUnit.value,
        leadTimeDays: int.tryParse(leadTimeCtrl.text.trim()) ?? 0,
        durationDays: int.tryParse(durationCtrl.text.trim()) ?? 1,
        dayOfWeek: maintenancePlan?.dayOfWeek,
        dayOfMonth: maintenancePlan?.dayOfMonth,
        monthOfYear: maintenancePlan?.monthOfYear,
        isActive: isActive.value,
        lastGeneratedAt: maintenancePlan?.lastGeneratedAt,
        lastGeneratedWorkOrderId: maintenancePlan?.lastGeneratedWorkOrderId,
        lastError: maintenancePlan?.lastError,
        nextDueDate: maintenancePlan?.nextDueDate,
        createdAt: maintenancePlan?.createdAt ?? now,
        updatedAt: now,
        deletedAt: null,
      );
      final succeeds = await cubit.saveMaintenancePlan(plan);
      if (succeeds && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlanTextFields(
            titleController: titleCtrl,
            descController: descCtrl,
            priceController: priceCtrl,
            priceFocusNode: priceFocusNode,
          ),
          gapH24,
          PlanLocationSelectors(
            selectedLocationId: locationId.value,
            selectedAreaId: areaId.value,
            selectedAssetId: assetId.value,
            onLocationChanged: (val) => locationId.value = val,
            onAreaChanged: (val) => areaId.value = val,
            onAssetChanged: (val) => assetId.value = val,
          ),
          gapH24,
          PlanAssignmentSelectors(
            selectedPriority: priority.value,
            selectedChecklistTemplateId: checklistId.value,
            selectedAssignedToId: assignedToId.value,
            selectedServiceProviderCompanyId: spCompanyId.value,
            onPriorityChanged: (val) => priority.value = val ?? Priority.medium,
            onChecklistChanged: (val) => checklistId.value = val,
            onAssignedToChanged: (val) => assignedToId.value = val,
            onServiceProviderCompanyChanged: (val) => spCompanyId.value = val,
          ),
          gapH24,
          PlanScheduleSelectors(
            intervalValueController: intervalValCtrl,
            intervalValFocusNode: intervalValFocusNode,
            leadTimeDaysController: leadTimeCtrl,
            leadTimeFocusNode: leadTimeFocusNode,
            durationDaysController: durationCtrl,
            durationFocusNode: durationFocusNode,
            selectedIntervalUnit: intervalUnit.value,
            isActive: isActive.value,
            onIntervalUnitChanged: (val) =>
                intervalUnit.value = val ?? IntervalUnit.months,
            onIsActiveChanged: (val) => isActive.value = val,
          ),
          gapH32,
          BaseButton(
            onTap: submit,
            text: maintenancePlan != null
                ? 'Atualizar plano'.hardcoded
                : 'Salvar plano'.hardcoded,
          ),
          gapH24,
        ],
      ),
    );
  }
}
