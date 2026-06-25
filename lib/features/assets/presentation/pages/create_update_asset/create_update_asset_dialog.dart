import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/assets/presentation/pages/create_update_asset/area_dropdown.dart';
import 'package:clean_architecture/features/assets/presentation/pages/create_update_asset/asset_name_field.dart';
import 'package:clean_architecture/features/assets/presentation/pages/create_update_asset/category_dropdown.dart';
import 'package:clean_architecture/features/assets/presentation/pages/create_update_asset/criticality_dropdown.dart';
import 'package:clean_architecture/features/assets/presentation/pages/create_update_asset/location_dropdown.dart';
import 'package:clean_architecture/features/assets/presentation/pages/create_update_asset/parent_asset_dropdown.dart';
import 'package:clean_architecture/features/assets/presentation/pages/create_update_asset/status_dropdown.dart';
import 'package:clean_architecture/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/session/session_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CreateAssetDialog extends HookWidget {
  const CreateAssetDialog({super.key, this.asset});

  final AssetEntity? asset;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    observeLoading([context.read<AssetsCubit>()]);

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
    } else if ((locationsError?.isNotEmpty ?? false) ||
        (categoriesError?.isNotEmpty ?? false) ||
        (assetsError?.isNotEmpty ?? false)) {
      return Center(
        child: Column(
          children: [
            BaseText.error(
              '${locationsError ?? ''}\n${categoriesError ?? ''}\n${assetsError ?? ''}',
            ),
            gapH8,
            PrimaryButton(
              onTap: () {
                if (locationsError?.isNotEmpty ?? false) {
                  context.read<LocationsCubit>().loadLocationsAndAreas();
                }
                if (categoriesError?.isNotEmpty ?? false) {
                  // context.read<CategoriesCubit>().;
                  //TODO load they here
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

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;
      if (selectedAreaId.value == null) return;

      final companyId = context.read<SessionCubit>().state.user.companyId;

      final updated = await context.read<AssetsCubit>().saveAsset(
        id: asset?.id,
        companyId: companyId,
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
