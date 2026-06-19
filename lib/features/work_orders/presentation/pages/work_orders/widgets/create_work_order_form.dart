import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/date_time_extension.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/get_areas_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/get_locations_use_case.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_users_use_case.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_type.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/session/session_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/validators/form_validators.dart';
import 'package:clean_architecture/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

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

    final locations = useState<List<LocationEntity>?>(null);
    final areas = useState<List<AreaEntity>?>(null);
    final assets = useState<List<AssetEntity>?>(null);
    final users = useState<List<UserProfileEntity>?>(null);

    final isLoadingData = useState<bool>(true);
    final errorMessage = useState<String?>(null);

    final selectedLocationId = useState<String?>(null);
    final selectedAssetId = useState<String?>(null);
    final selectedAssignedToId = useState<String?>(null);
    final selectedPriority = useState<Priority>(Priority.medium);
    final selectedType = useState<WorkOrderType>(WorkOrderType.corrective);
    final selectedScheduledDate = useState<DateTime?>(null);

    useEffect(() {
      Future<void> loadFormData() async {
        try {
          final companyId = context.read<SessionCubit>().state.user.companyId;
          if (companyId.isEmpty) {
            errorMessage.value = 'Erro: Usuário sem ID de empresa'.hardcoded;
            isLoadingData.value = false;
            return;
          }

          final results = await Future.wait([
            GetIt.I<GetLocationsUseCase>().call(companyId),
            GetIt.I<GetAreasUseCase>().call(companyId),
            GetIt.I<GetAssetsUseCase>().call(companyId),
            GetIt.I<GetUsersUseCase>().call(companyId),
          ]);

          final locsResult = results[0];
          final areasResult = results[1];
          final assetsResult = results[2];
          final usersResult = results[3];

          if (locsResult is SuccessState<List<LocationEntity>> &&
              areasResult is SuccessState<List<AreaEntity>> &&
              assetsResult is SuccessState<List<AssetEntity>> &&
              usersResult is SuccessState<List<UserProfileEntity>>) {
            locations.value = locsResult.data ?? [];
            areas.value = areasResult.data ?? [];
            assets.value = assetsResult.data ?? [];
            users.value = usersResult.data ?? [];
          } else {
            errorMessage.value =
                'Erro ao carregar dados do formulário'.hardcoded;
          }
        } catch (_) {
          errorMessage.value = 'Erro ao carregar dados do formulário'.hardcoded;
        } finally {
          isLoadingData.value = false;
        }
      }

      loadFormData();
      return null;
    }, []);

    if (isLoadingData.value) {
      return const LoadingCircle();
    }

    if (errorMessage.value != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: BaseText.error(errorMessage.value!),
        ),
      );
    }

    final locationDropdownItems =
        locations.value?.map((loc) {
          return DropdownMenuItem<String>(
            value: loc.id,
            child: BaseText(loc.name),
          );
        }).toList() ??
        [];

    final areaIdsForSelectedLocation = selectedLocationId.value != null
        ? areas.value
                  ?.where((area) => area.locationId == selectedLocationId.value)
                  .map((area) => area.id)
                  .toSet() ??
              <String>{}
        : <String>{};

    final filteredAssets =
        assets.value
            ?.where(
              (asset) => areaIdsForSelectedLocation.contains(asset.areaId),
            )
            .toList() ??
        [];

    final assetDropdownItems = [
      DropdownMenuItem<String>(value: '', child: BaseText('Nenhum'.hardcoded)),
      ...filteredAssets.map((asset) {
        return DropdownMenuItem<String>(
          value: asset.id,
          child: BaseText(asset.name),
        );
      }),
    ];

    final userDropdownItems = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(value: '', child: BaseText('Nenhum'.hardcoded)),
      ...users.value?.map((user) {
            return DropdownMenuItem<String>(
              value: user.id,
              child: BaseText(user.name),
            );
          }).toList() ??
          [],
    ];

    Future<void> pickScheduledDate() async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: selectedScheduledDate.value ?? now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
      );
      if (date == null) return;

      if (!context.mounted) return;

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedScheduledDate.value ?? now),
      );
      if (time == null) {
        selectedScheduledDate.value = DateTime(date.year, date.month, date.day);
        return;
      }

      selectedScheduledDate.value = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

    void submit() {
      if (formKey.currentState?.validate() != true) return;

      final sessionUser = context.read<SessionCubit>().state.user;
      final now = DateTime.now();

      final workOrder = WorkOrderEntity(
        id: const Uuid().v4(),
        companyId: sessionUser.companyId,
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
        createdAt: now,
        updatedAt: now,
      );

      Navigator.of(context).pop();
      context.read<WorkOrdersCubit>().createWorkOrder(workOrder);
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
                'Criar Ordem de Serviço'.hardcoded,
                textAlign: TextAlign.center,
              ),
              gapH16,
              BaseTextFormField(
                labelText: 'Título *'.hardcoded,
                hintText: 'Ex: Reparo no Ar Condicionado'.hardcoded,
                controller: titleController,
                focusNode: titleFocusNode,
                validator: FormValidators.compose([NonEmptyValidator()]),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => descFocusNode.requestFocus(),
              ),
              gapH16,
              BaseTextFormField(
                labelText: 'Descrição (Opcional)'.hardcoded,
                hintText: 'Ex: O equipamento do Bloco B não liga'.hardcoded,
                controller: descController,
                focusNode: descFocusNode,
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              gapH16,
              BaseDropDown<String>(
                key: const ValueKey('Location'),
                label: 'Local *'.hardcoded,
                selectedItem: selectedLocationId.value,
                validator: (val) =>
                    val == null ? 'Selecione um local'.hardcoded : null,
                items: locationDropdownItems,
                onChanged: (val) {
                  selectedLocationId.value = val;
                  selectedAssetId.value = null;
                },
              ),
              gapH16,
              BaseDropDown<String>(
                key: const ValueKey('Asset'),
                label: 'Equipamento (Opcional)'.hardcoded,
                selectedItem: selectedAssetId.value,
                hint: selectedLocationId.value == null
                    ? BaseText('Selecione primeiro o local'.hardcoded)
                    : (filteredAssets.isEmpty
                          ? BaseText('Sem equipamentos cadastrados'.hardcoded)
                          : BaseText('Selecione o equipamento'.hardcoded)),
                items: selectedLocationId.value == null
                    ? []
                    : assetDropdownItems,
                onChanged: selectedLocationId.value == null
                    ? null
                    : (val) => selectedAssetId.value = val,
              ),
              gapH16,
              BaseDropDown<String>(
                key: const ValueKey('AssignedTo'),
                label: 'Responsável (Opcional)'.hardcoded,
                selectedItem: selectedAssignedToId.value,
                items: userDropdownItems,
                onChanged: (val) => selectedAssignedToId.value = val,
              ),
              gapH16,
              Row(
                children: [
                  Expanded(
                    child: BaseDropDown<WorkOrderType>(
                      key: const ValueKey('Type'),
                      label: 'Tipo *'.hardcoded,
                      selectedItem: selectedType.value,
                      items: WorkOrderType.values.map((t) {
                        final String labelText;
                        switch (t) {
                          case WorkOrderType.corrective:
                            labelText = 'Corretiva'.hardcoded;
                          case WorkOrderType.preventive:
                            labelText = 'Preventiva'.hardcoded;
                          case WorkOrderType.inspection:
                            labelText = 'Inspeção'.hardcoded;
                        }
                        return DropdownMenuItem<WorkOrderType>(
                          value: t,
                          child: BaseText(labelText),
                        );
                      }).toList(),
                      onChanged: (val) {
                        selectedType.value = val;
                      },
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: BaseDropDown<Priority>(
                      key: const ValueKey('Priority'),
                      label: 'Prioridade *'.hardcoded,
                      selectedItem: selectedPriority.value,
                      items: Priority.values.map((p) {
                        return DropdownMenuItem<Priority>(
                          value: p,
                          child: BaseText(p.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        selectedPriority.value = val;
                      },
                    ),
                  ),
                ],
              ),
              gapH16,
              Row(
                children: [
                  Expanded(
                    child: BaseTextFormField(
                      labelText: 'Duração (Minutos, Opcional)'.hardcoded,
                      hintText: 'Ex: 60'.hardcoded,
                      controller: durationController,
                      focusNode: durationFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => submit(),
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BaseText('Data Programada'.hardcoded),
                        gapH4,
                        InkWell(
                          onTap: pickScheduledDate,
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Sizes.p8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).disabledColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(Sizes.p8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: BaseText(
                                    selectedScheduledDate.value == null
                                        ? 'Selecionar'.hardcoded
                                        : selectedScheduledDate.value!
                                              .formattedBrazilianDate(
                                                includeTime: true,
                                              ),
                                  ),
                                ),
                                if (selectedScheduledDate.value != null)
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () =>
                                        selectedScheduledDate.value = null,
                                  )
                                else
                                  const Icon(Icons.calendar_today, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                    onTap: submit,
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
