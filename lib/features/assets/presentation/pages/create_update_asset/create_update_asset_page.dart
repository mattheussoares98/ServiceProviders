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
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

@RoutePage()
class CreateUpdateAssetPage extends HookWidget {
  const CreateUpdateAssetPage({super.key, this.asset});

  final AssetEntity? asset;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    observeLoading([
      ObservedLoadingTarget(
        context.read<AssetsCubit>(),
        statuses: {StateStatus.saving, StateStatus.deleting},
      ),
    ]);

    //* the same for locations and areas
    final (loadingLocations, locationsError) = context
        .select<LocationsCubit, (bool, String?)>((cubit) {
          return (
            cubit.state.status == StateStatus.loading,
            cubit.state.errorMessage,
          );
        });
    final (loadingCategories, categoriesError) = context
        .select<CategoriesCubit, (bool, String?)>((cubit) {
          return (
            cubit.state.status == StateStatus.loading,
            cubit.state.errorMessage,
          );
        });
    final (loadingAssets, assetsError) = context
        .select<AssetsCubit, (bool, String?)>((cubit) {
          return (
            cubit.state.status == StateStatus.loading,
            cubit.state.errorMessage,
          );
        });

    if (loadingCategories || loadingLocations || loadingAssets) {
      return const Center(child: LoadingCircle());
    }
    final hasError =
        (locationsError?.isNotEmpty ?? false) ||
        (categoriesError?.isNotEmpty ?? false) ||
        (assetsError?.isNotEmpty ?? false);

    Widget? errorWidget;
    if (hasError) {
      errorWidget = Center(
        child: Column(
          children: [
            BaseText.error(
              [?locationsError, ?categoriesError, ?assetsError].join('\n'),
            ),
            gapH8,
            BaseButton(
              onTap: () {
                if (locationsError?.isNotEmpty ?? false) {
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
      (cubit) => cubit.state.allAreas
          .firstWhereOrNull((e) => e.id == asset?.areaId)
          ?.locationId,
    );

    final selectedLocationId = useState<String?>(locationId);
    final selectedAreaId = useState<String?>(asset?.areaId);
    final selectedCategoryId = useState<String?>(asset?.categoryId);
    final selectedParentAssetId = useState<String?>(asset?.parentAssetId);
    final selectedStatus = useState<AssetStatus>(
      asset?.status ?? AssetStatus.active,
    );
    final selectedCriticality = useState<AssetCriticality>(
      asset?.criticality ?? AssetCriticality.medium,
    );

    final nameFocusNode = useFocusNode();
    final codeFocusNode = useFocusNode();
    final manufacturerFocusNode = useFocusNode();
    final modelFocusNode = useFocusNode();
    final serialNumberFocusNode = useFocusNode();
    final notesFocusNode = useFocusNode();

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;
      if (selectedAreaId.value == null) return;

      final updated = await context.read<AssetsCubit>().saveAsset(
        id: asset?.id,
        areaId: selectedAreaId.value!,
        categoryId: selectedCategoryId.value,
        parentAssetId: selectedParentAssetId.value,
        name: nameController.text,
        code: codeController.text,
        manufacturer: manufacturerController.text,
        model: modelController.text,
        serialNumber: serialNumberController.text,
        status: selectedStatus.value,
        criticality: selectedCriticality.value,
        notes: notesController.text,
        createdAt: asset?.createdAt,
      );

      if (updated && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return BaseScaffold(
      appBar: BaseAppBar(
        title: asset == null
            ? 'Criando equipamento'.hardcoded
            : 'Editando equipamento'.hardcoded,
        actions: [DeleteAssetButton(assetId: asset?.id)],
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
                  gapH16,
                  LocationDropdown(
                    selectedLocationId: selectedLocationId.value,
                    onChangeArea: (val) => selectedAreaId.value = val,
                    onChangeLocation: (val) => selectedLocationId.value = val,
                  ),
                  gapH16,
                  AreaDropdown(
                    selectedLocationId: selectedLocationId.value,
                    selectedAreaId: selectedAreaId.value,
                    onChanged: (value) => selectedAreaId.value = value,
                  ),
                  gapH16,
                  CategoryDropdown(
                    selectedCategoryId: selectedCategoryId.value,
                    onChanged: (value) => selectedCategoryId.value = value,
                  ),
                  gapH16,
                  ParentAssetDropdown(
                    onChanged: (value) => selectedParentAssetId.value = value,
                    selectedParentAssetId: selectedParentAssetId.value,
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
                          hintText: 'Ex: 12345678X'.hardcoded,
                          controller: serialNumberController,
                          focusNode: serialNumberFocusNode,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              notesFocusNode.requestFocus(),
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
