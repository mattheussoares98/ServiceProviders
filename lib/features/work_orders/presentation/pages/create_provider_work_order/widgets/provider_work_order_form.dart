part of '../create_provider_work_order_page.dart';

class _ProviderWorkOrderForm extends HookWidget {
  const _ProviderWorkOrderForm();

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final workOrderId = useMemoized(() => const Uuid().v4());
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();

    final companies = context
        .select<WorkOrdersCubit, List<ServiceProviderCompanyEntity>>(
          (cubit) => cubit.state.providerCompanies,
        );

    final selectedCompany = useState<ServiceProviderCompanyEntity?>(
      companies.length == 1 ? companies.first : null,
    );
    final selectedLocationId = useState<String?>(null);
    final selectedAreaId = useState<String?>(null);
    final selectedType = useState(WorkOrderType.corrective);
    final selectedPriority = useState(Priority.medium);
    final selectedScheduledDate = useState<DateTime?>(null);

    useEffect(() {
      if (selectedCompany.value == null && companies.length == 1) {
        selectedCompany.value = companies.first;
      }
      return null;
    }, [companies]);

    // The registry belongs to the contracting company, so it can only be read
    // once the provider company — and with it the tenant — is known.
    useEffect(() {
      final company = selectedCompany.value;
      selectedLocationId.value = null;
      selectedAreaId.value = null;
      if (company != null) {
        context.read<LocationsCubit>().loadProviderRegistry(company.companyId);
      }
      return null;
    }, [selectedCompany.value?.id]);

    observeLoading([
      ObservedLoadingTarget(
        context.read<WorkOrdersCubit>(),
        statuses: {StateStatus.saving},
      ),
    ]);

    return Form(
      key: formKey,
      child: Column(
        children: [
          gapH8,
          _ProviderCompanyDropdown(
            companies: companies,
            selected: selectedCompany.value,
            onChanged: (company) => selectedCompany.value = company,
          ),
          gapH8,
          _ProviderLocationDropdown(
            selectedId: selectedLocationId.value,
            onChanged: (id) {
              selectedLocationId.value = id;
              selectedAreaId.value = null;
            },
          ),
          gapH8,
          _ProviderAreaDropdown(
            locationId: selectedLocationId.value,
            selectedId: selectedAreaId.value,
            onChanged: (id) => selectedAreaId.value = id,
          ),
          gapH8,
          _ProviderTitleField(controller: titleController),
          gapH8,
          _ProviderDescriptionField(controller: descriptionController),
          gapH8,
          _ProviderTypeDropdown(
            selected: selectedType.value,
            onChanged: (type) => selectedType.value = type,
          ),
          gapH8,
          _ProviderPriorityDropdown(
            selected: selectedPriority.value,
            onChanged: (priority) => selectedPriority.value = priority,
          ),
          gapH8,
          _ProviderScheduledDate(
            scheduledDate: selectedScheduledDate.value,
            onChanged: (date) => selectedScheduledDate.value = date,
          ),
          gapH24,
          _ProviderSaveButton(
            formKey: formKey,
            workOrderId: workOrderId,
            company: selectedCompany.value,
            locationId: selectedLocationId.value,
            areaId: selectedAreaId.value,
            titleController: titleController,
            descriptionController: descriptionController,
            type: selectedType.value,
            priority: selectedPriority.value,
            scheduledDate: selectedScheduledDate.value,
          ),
          gapH24,
        ],
      ),
    );
  }
}
