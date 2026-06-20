import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/assets/presentation/pages/assets/widgets/asset_card.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/shared_ui/cubits/session/session_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:clean_architecture/shared_ui/utils/validators/form_validators.dart';
import 'package:clean_architecture/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uuid/uuid.dart';

class CreateAssetDialog extends HookWidget {
  const CreateAssetDialog({
    super.key,
    required this.locations,
    required this.areas,
    required this.categories,
    required this.allAssets,
  });

  final List<LocationEntity> locations;
  final List<AreaEntity> areas;
  final List<CategoryEntity> categories;
  final List<AssetEntity> allAssets;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final nameController = useTextEditingController();
    final codeController = useTextEditingController();
    final manufacturerController = useTextEditingController();
    final modelController = useTextEditingController();
    final serialNumberController = useTextEditingController();
    final notesController = useTextEditingController();

    final selectedLocationId = useState<String?>(null);
    final selectedAreaId = useState<String?>(null);
    final selectedCategoryId = useState<String?>(null);
    final selectedParentAssetId = useState<String?>(null);
    final selectedStatus = useState<AssetStatus>(AssetStatus.active);
    final selectedCriticality = useState<AssetCriticality>(
      AssetCriticality.medium,
    );

    final nameFocusNode = useFocusNode();
    final codeFocusNode = useFocusNode();
    final manufacturerFocusNode = useFocusNode();
    final modelFocusNode = useFocusNode();
    final serialNumberFocusNode = useFocusNode();
    final notesFocusNode = useFocusNode();

    void submit() {
      if (formKey.currentState?.validate() != true) return;
      if (selectedAreaId.value == null) return;

      final companyId = context.read<SessionCubit>().state.user.companyId;
      final now = DateTime.now();

      final asset = AssetEntity(
        id: const Uuid().v4(),
        companyId: companyId,
        areaId: selectedAreaId.value!,
        categoryId: selectedCategoryId.value == ''
            ? null
            : selectedCategoryId.value,
        parentAssetId: selectedParentAssetId.value == ''
            ? null
            : selectedParentAssetId.value,
        name: nameController.text.trim(),
        code: codeController.text.trim().isEmpty
            ? null
            : codeController.text.trim(),
        manufacturer: manufacturerController.text.trim().isEmpty
            ? null
            : manufacturerController.text.trim(),
        model: modelController.text.trim().isEmpty
            ? null
            : modelController.text.trim(),
        serialNumber: serialNumberController.text.trim().isEmpty
            ? null
            : serialNumberController.text.trim(),
        status: selectedStatus.value,
        criticality: selectedCriticality.value,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      Navigator.of(context).pop();
      context.read<AssetsCubit>().createAsset(asset);
    }

    final locationDropdownItems = locations.map((loc) {
      return DropdownMenuItem<String>(value: loc.id, child: BaseText(loc.name));
    }).toList();

    final filteredAreas = selectedLocationId.value != null
        ? areas
              .where((area) => area.locationId == selectedLocationId.value)
              .toList()
        : <AreaEntity>[];

    final areaDropdownItems = filteredAreas.map((area) {
      return DropdownMenuItem<String>(
        value: area.id,
        child: BaseText(area.name),
      );
    }).toList();

    final categoryDropdownItems = [
      DropdownMenuItem<String>(value: '', child: BaseText('Nenhuma'.hardcoded)),
      ...categories.map((c) {
        return DropdownMenuItem<String>(value: c.id, child: BaseText(c.name));
      }),
    ];

    final parentDropdownItems = [
      DropdownMenuItem<String>(value: '', child: BaseText('Nenhum'.hardcoded)),
      ...allAssets.map((a) {
        return DropdownMenuItem<String>(value: a.id, child: BaseText(a.name));
      }),
    ];

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
                'Criar novo equipamento'.hardcoded,
                textAlign: TextAlign.center,
              ),
              gapH16,
              BaseTextFormField(
                labelText: 'Nome do equipamento *'.hardcoded,
                hintText: 'Ex: Ar condicionado'.hardcoded,
                controller: nameController,
                focusNode: nameFocusNode,
                validator: FormValidators.compose([NonEmptyValidator()]),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => codeFocusNode.requestFocus(),
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
                  selectedAreaId.value = null;
                },
                showLabelAtTopLeft:
                    selectedLocationId.value?.isNotEmpty ?? false,
              ),
              gapH16,
              BaseDropDown<String>(
                key: const ValueKey('Area'),
                label: 'Área *'.hardcoded,
                selectedItem: selectedAreaId.value,
                hint: selectedLocationId.value == null
                    ? BaseText('Selecione primeiro o local'.hardcoded)
                    : (filteredAreas.isEmpty
                          ? BaseText('Sem áreas cadastradas'.hardcoded)
                          : BaseText('Selecione a área'.hardcoded)),
                validator: (val) =>
                    val == null ? 'Selecione uma área'.hardcoded : null,
                items: areaDropdownItems,
                onChanged: (val) => selectedAreaId.value = val,
                showLabelAtTopLeft: selectedAreaId.value?.isNotEmpty ?? false,
              ),
              gapH16,
              BaseDropDown<String>(
                key: const ValueKey('Category'),
                label: 'Categoria (opcional)'.hardcoded,
                selectedItem: selectedCategoryId.value,
                items: categoryDropdownItems,
                onChanged: (val) => selectedCategoryId.value = val,
                showLabelAtTopLeft:
                    selectedCategoryId.value?.isNotEmpty ?? false,
              ),
              gapH16,
              BaseDropDown<String>(
                key: const ValueKey('ParentAsset'),
                label: 'Equipamento pai (opcional)'.hardcoded,
                selectedItem: selectedParentAssetId.value,
                items: parentDropdownItems,
                onChanged: (val) => selectedParentAssetId.value = val,
                showLabelAtTopLeft:
                    selectedParentAssetId.value?.isNotEmpty ?? false,
              ),
              gapH16,
              Row(
                children: [
                  Expanded(
                    child: BaseDropDown<AssetStatus>(
                      key: const ValueKey('Status'),
                      label: 'Status *'.hardcoded,
                      selectedItem: selectedStatus.value,
                      items: AssetStatus.values.map((s) {
                        return DropdownMenuItem<AssetStatus>(
                          value: s,
                          child: BaseText(s.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        selectedStatus.value = val;
                      },
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: BaseDropDown<AssetCriticality>(
                      key: const ValueKey('Criticality'),
                      label: 'Criticidade *'.hardcoded,
                      selectedItem: selectedCriticality.value,
                      items: AssetCriticality.values.map((c) {
                        return DropdownMenuItem<AssetCriticality>(
                          value: c,
                          child: BaseText(c.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        selectedCriticality.value = val;
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
                      labelText: 'Código (opcional)'.hardcoded,
                      hintText: 'Ex: AC-001'.hardcoded,
                      controller: codeController,
                      focusNode: codeFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          manufacturerFocusNode.requestFocus(),
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: BaseTextFormField(
                      labelText: 'Fabricante (opcional)'.hardcoded,
                      hintText: 'Ex: Carrier'.hardcoded,
                      controller: manufacturerController,
                      focusNode: manufacturerFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => modelFocusNode.requestFocus(),
                    ),
                  ),
                ],
              ),
              gapH16,
              Row(
                children: [
                  Expanded(
                    child: BaseTextFormField(
                      labelText: 'Modelo (opcional)'.hardcoded,
                      hintText: 'Ex: Split 12k'.hardcoded,
                      controller: modelController,
                      focusNode: modelFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          serialNumberFocusNode.requestFocus(),
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: BaseTextFormField(
                      labelText: 'Nº série (opcional)'.hardcoded,
                      hintText: 'Ex: 12345678X'.hardcoded,
                      controller: serialNumberController,
                      focusNode: serialNumberFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => notesFocusNode.requestFocus(),
                    ),
                  ),
                ],
              ),
              gapH16,
              BaseTextFormField(
                labelText: 'Observações (opcional)'.hardcoded,
                hintText: 'Ex: Aparelho com vazamento'.hardcoded,
                controller: notesController,
                focusNode: notesFocusNode,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => submit(),
              ),
              gapH16,
              Container(
                padding: const EdgeInsets.all(Sizes.p16),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(Sizes.p8),
                  border: Border.all(color: AppColors.dashedBorder),
                ),
                child: Column(
                  children: [
                    const PlatformIcon(
                      materialIcon: Icons.camera_alt,
                      cupertinoIcon: CupertinoIcons.camera,
                      color: AppColors.fade,
                    ),
                    gapH8,
                    BaseText.caption(
                      'TODO: Tirar foto do equipamento (câmera indisponível)'
                          .hardcoded,
                      color: AppColors.fade,
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
