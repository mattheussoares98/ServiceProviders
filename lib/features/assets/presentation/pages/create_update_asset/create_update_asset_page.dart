import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/area_dropdown.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/asset_name_field.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/category_dropdown.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/criticality_dropdown.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/delete_asset_button.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/location_dropdown.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/parent_asset_dropdown.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/status_dropdown.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/toast_util.dart';

part 'widgets/customer_dropdown.dart';

@RoutePage()
class CreateUpdateAssetPage extends HookWidget {
  const CreateUpdateAssetPage({super.key, this.asset});

  final AssetEntity? asset;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    observeRunning([
      ObservedLoadingTarget(
        context.read<AssetsCubit>(),
        sections: {AssetsSections.save},
      ),
    ]);

    final workType = context.select<CompanyCubit, WorkType>(
      (cubit) => cubit.state.company?.workType ?? WorkType.internalOnly,
    );
    final showLocations = workType.supportsOwnLocations;
    final showCustomers = workType.supportsCustomers;

    //* the same for locations and areas
    final (loadingLocations, locationsError) = context
        .select<LocationsCubit, (bool, String?)>((cubit) {
          final section = cubit.state.section(BaseSections.load);
          return (section.isRunning, section.errorMessage);
        });
    final (loadingCategories, categoriesError) = context
        .select<CategoriesCubit, (bool, String?)>((cubit) {
          final section = cubit.state.section(BaseSections.load);
          return (section.isRunning, section.errorMessage);
        });
    final (loadingAssets, assetsError) = context
        .select<AssetsCubit, (bool, String?)>((cubit) {
          final section = cubit.state.section(BaseSections.load);
          return (section.isRunning, section.errorMessage);
        });

    if (loadingCategories ||
        (showLocations && loadingLocations) ||
        loadingAssets) {
      return const Center(child: LoadingCircle());
    }
    final hasError =
        (showLocations && (locationsError?.isNotEmpty ?? false)) ||
        (categoriesError?.isNotEmpty ?? false) ||
        (assetsError?.isNotEmpty ?? false);

    Widget? errorWidget;
    if (hasError) {
      errorWidget = Center(
        child: Column(
          children: [
            BaseText.error(
              [
                if (showLocations) ?locationsError,
                ?categoriesError,
                ?assetsError,
              ].join('\n'),
            ),
            gapH8,
            BaseButton(
              onTap: () {
                if (showLocations && (locationsError?.isNotEmpty ?? false)) {
                  context.read<LocationsCubit>().loadLocationsAndAreas();
                }
                if (categoriesError?.isNotEmpty ?? false) {
                  context.read<CategoriesCubit>().loadCategories();
                }
                if (assetsError?.isNotEmpty ?? false) {
                  context.read<AssetsCubit>().loadAssets();
                }
              },
              text: 'Tentar novamente'.hardcoded,
            ),
          ],
        ),
      );
    }

    final nameController = useTextEditingController(text: asset?.name);
    final codeController = useTextEditingController(text: asset?.code);
    final manufacturerController = useTextEditingController(
      text: asset?.manufacturer,
    );
    final modelController = useTextEditingController(text: asset?.model);
    final serialNumberController = useTextEditingController(
      text: asset?.serialNumber,
    );
    final notesController = useTextEditingController(text: asset?.notes);

    final locationId = context.select<LocationsCubit, String?>(
      (cubit) =>
          asset?.locationId ??
          cubit.state.allAreas
              .firstWhereOrNull((e) => e.id == asset?.areaId)
              ?.locationId,
    );

    final selectedLocationId = useState<String?>(locationId);
    final selectedAreaId = useState<String?>(asset?.areaId);
    final selectedCustomerId = useState<String?>(asset?.customerId);

    final selectedCategoryId = useState<String?>(asset?.categoryId);
    final selectedParentAssetId = useState<String?>(asset?.parentAssetId);
    final selectedStatus = useState<AssetStatus>(
      asset?.status ?? AssetStatus.active,
    );
    final selectedCriticality = useState<AssetCriticality>(
      asset?.criticality ?? AssetCriticality.medium,
    );

    final isGenericAsset =
        workType.isServiceProviderOnly && selectedCustomerId.value == null;
    final canEditUnitIdentifiers = !isGenericAsset;

    final nameFocusNode = useFocusNode();
    final codeFocusNode = useFocusNode();
    final manufacturerFocusNode = useFocusNode();
    final modelFocusNode = useFocusNode();
    final serialNumberFocusNode = useFocusNode();
    final notesFocusNode = useFocusNode();

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;
      final requireLocation =
          workType.requiresLocation ||
          (workType.isHybrid && selectedCustomerId.value == null);
      if (requireLocation && selectedLocationId.value == null) {
        ToastUtil.showError('Selecione um local para o equipamento'.hardcoded);
        return;
      }

      final updated = await context.read<AssetsCubit>().saveAsset(
        id: (asset?.id.isNotEmpty ?? false) ? asset?.id : null,
        locationId: showLocations ? selectedLocationId.value : null,
        areaId: showLocations ? selectedAreaId.value : null,
        customerId: showCustomers ? selectedCustomerId.value : null,
        categoryId: selectedCategoryId.value,
        parentAssetId: selectedParentAssetId.value,
        name: nameController.text,
        code: isGenericAsset ? null : codeController.text,
        manufacturer: manufacturerController.text,
        model: modelController.text,
        serialNumber: isGenericAsset ? null : serialNumberController.text,
        status: selectedStatus.value,
        criticality: selectedCriticality.value,
        notes: notesController.text,
        createdAt: asset?.createdAt,
      );

      if (updated && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    final isEditing = asset?.id.isNotEmpty ?? false;

    return BaseScaffold(
      appBar: BaseAppBar(
        title: isEditing
            ? 'Editando equipamento'.hardcoded
            : 'Criando equipamento'.hardcoded,
        actions: [if (isEditing) DeleteAssetButton(assetId: asset?.id)],
      ),
      body:
          errorWidget ??
          Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AssetNameField(
                    nameController: nameController,
                    nameFocusNode: nameFocusNode,
                    codeFocusNode: codeFocusNode,
                  ),
                  if (showLocations) ...[
                    gapH16,
                    LocationDropdown(
                      selectedLocationId: selectedLocationId.value,
                      onChangeArea: (val) => selectedAreaId.value = val,
                      onChangeLocation: (val) => selectedLocationId.value = val,
                      isRequired:
                          workType.isInternalOnly ||
                          (workType.isHybrid &&
                              selectedCustomerId.value == null),
                    ),
                    gapH16,
                    AreaDropdown(
                      selectedLocationId: selectedLocationId.value,
                      selectedAreaId: selectedAreaId.value,
                      onChanged: (value) => selectedAreaId.value = value,
                    ),
                  ],
                  if (showCustomers) ...[
                    gapH16,
                    _CustomerDropdown(
                      selectedId: selectedCustomerId.value,
                      onChanged: (val) {
                        selectedCustomerId.value = val;
                        if (val == null) {
                          codeController.clear();
                          serialNumberController.clear();
                        }
                      },
                    ),
                  ],

                  gapH16,
                  CategoryDropdown(
                    selectedCategoryId: selectedCategoryId.value,
                    onChanged: (value) => selectedCategoryId.value = value,
                  ),
                  gapH16,
                  ParentAssetDropdown(
                    onChanged: (value) => selectedParentAssetId.value = value,
                    selectedParentAssetId: selectedParentAssetId.value,
                    selectedLocationId: selectedLocationId.value,
                    selectedAreaId: selectedAreaId.value,
                    currentAssetId: asset?.id,
                  ),
                  gapH16,
                  Row(
                    children: [
                      Expanded(
                        child: StatusDropdown(
                          selectedStatus: selectedStatus.value,
                          onChanged: (val) => selectedStatus.value = val,
                        ),
                      ),
                      gapW16,
                      Expanded(
                        child: CriticalityDropdown(
                          selectedCriticality: selectedCriticality.value,
                          onChanged: (val) => selectedCriticality.value = val,
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
                          hintText: canEditUnitIdentifiers
                              ? 'Ex: AC-001'.hardcoded
                              : 'Requer cliente'.hardcoded,
                          controller: codeController,
                          focusNode: codeFocusNode,
                          enabled: canEditUnitIdentifiers,
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
                          onFieldSubmitted: (_) =>
                              modelFocusNode.requestFocus(),
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
                          hintText: canEditUnitIdentifiers
                              ? 'Ex: 12345678X'.hardcoded
                              : 'Requer cliente'.hardcoded,
                          controller: serialNumberController,
                          focusNode: serialNumberFocusNode,
                          enabled: canEditUnitIdentifiers,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              notesFocusNode.requestFocus(),
                        ),
                      ),
                    ],
                  ),
                  if (isGenericAsset) ...[
                    gapH8,
                    BaseText.caption(
                      'Código e número de série requerem um cliente vinculado'
                          .hardcoded,
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ],
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
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Flexible(
                        child: BaseButton.text(
                          onPressed: () => Navigator.of(context).pop(),
                          text: 'Cancelar'.hardcoded,
                          color: Colors.red,
                        ),
                      ),
                      Expanded(
                        child: BaseButton(
                          onTap: submit,
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
