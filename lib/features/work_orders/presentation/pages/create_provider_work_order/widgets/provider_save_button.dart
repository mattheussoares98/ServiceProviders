part of '../create_provider_work_order_page.dart';

class _ProviderSaveButton extends StatelessWidget {
  const _ProviderSaveButton({
    required this.formKey,
    required this.workOrderId,
    required this.company,
    required this.locationId,
    required this.areaId,
    required this.titleController,
    required this.descriptionController,
    required this.type,
    required this.priority,
    required this.scheduledDate,
  });

  final GlobalKey<FormState> formKey;
  final String workOrderId;
  final ServiceProviderCompanyEntity? company;
  final String? locationId;
  final String? areaId;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final WorkOrderType type;
  final Priority priority;
  final DateTime? scheduledDate;

  Future<void> _save(BuildContext context) async {
    if (formKey.currentState?.validate() != true) return;

    final description = descriptionController.text.trim();
    final succeeds = await context
        .read<WorkOrdersCubit>()
        .createProviderWorkOrder(
          id: workOrderId,
          serviceProviderCompanyId: company?.id,
          locationId: locationId!,
          areaId: areaId,
          title: titleController.text.trim(),
          description: description.isEmpty ? null : description,
          priority: priority,
          type: type,
          scheduledDate: scheduledDate,
        );

    if (succeeds && context.mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseButton(
      text: 'Abrir ordem de serviço'.hardcoded,
      onTap: () => _save(context),
    );
  }
}
