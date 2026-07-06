import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:uuid/uuid.dart';

part 'locations_state.dart';

@injectable
class LocationsCubit extends BaseCubit<LocationsState> {
  LocationsCubit({required LocationsCubitUseCases useCases})
    : _useCases = useCases,
      super(const LocationsState.initial());

  final LocationsCubitUseCases _useCases;

  Future<void> loadLocationsAndAreas({bool showLoading = true}) async {
    final user = _useCases.getSessionUser();
    if (user.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(state.copyWith(status: StateStatus.loadingError, locations: []));
      return;
    }

    emit(state.copyWith(status: showLoading ? StateStatus.loading : null));

    final results = await Future.wait([
      _useCases.getLocations(user.companyId),
      _useCases.getAreas(user.companyId),
    ]);

    if (isClosed) return;

    final locationsResult = results[0];
    final areasResult = results[1];

    if (locationsResult is SuccessState<List<LocationEntity>> &&
        areasResult is SuccessState<List<AreaEntity>>) {
      final areas = areasResult.data ?? [];
      final Map<String, List<AreaEntity>> areasByLocation = {};
      for (final area in areas) {
        areasByLocation.putIfAbsent(area.locationId, () => []).add(area);
      }
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          locations: locationsResult.data,
          areasByLocation: areasByLocation,
          allAreas: areas,
          annulErrorMessage: true,
        ),
      );
    } else {
      final errorMessage = locationsResult is FailureState
          ? locationsResult.message
          : areasResult.message;
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: errorMessage,
        ),
      );
      //* Already showing the error direct in the UI
      // if (locationsResult is FailureState) {
      //   showDataStateToast(locationsResult);
      // } else {
      //   showDataStateToast(areasResult);
      // }
    }
  }

  Future<void> loadAreas(String companyId) async {
    final dataState = await _useCases.getAreas(companyId);
    if (isClosed) return;

    if (dataState is SuccessState<List<AreaEntity>>) {
      final areas = dataState.data ?? [];
      final Map<String, List<AreaEntity>> areasByLocation = {};
      for (final area in areas) {
        areasByLocation.putIfAbsent(area.locationId, () => []).add(area);
      }
      emit(state.copyWith(areasByLocation: areasByLocation, allAreas: areas));
    } else {
      showDataStateToast(dataState);
    }
  }

  Future<bool> saveLocation({
    required String? id,
    required String companyId,
    required String name,
    String? postalCode,
    String? address,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? addressState,
    DateTime? createdAt,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final isUpdate = id != null;
    final now = DateTime.now();

    final location = LocationEntity(
      id: id ?? const Uuid().v4(),
      companyId: companyId,
      name: name.trim(),
      postalCode: postalCode?.trimToNull(),
      address: address?.trimToNull(),
      number: number?.trimToNull(),
      complement: complement?.trimToNull(),
      neighborhood: neighborhood?.trimToNull(),
      city: city?.trimToNull(),
      state: addressState?.trimToNull(),
      isActive: true,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );

    final dataState = isUpdate
        ? await _useCases.updateLocation(location)
        : await _useCases.createLocation(location);

    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      await loadLocationsAndAreas(showLoading: false);
      if (isClosed) return false;
      emit(state.copyWith(status: StateStatus.loaded));
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<void> deleteLocation(String id) async {
    emit(state.copyWith(status: StateStatus.deleting));
    final dataState = await _useCases.deleteLocation(id);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      await loadLocationsAndAreas(showLoading: false);
      if (isClosed) return;
      emit(state.copyWith(status: StateStatus.loaded));
    } else {
      emit(
        state.copyWith(
          status: StateStatus.deletingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
    }
    if (isClosed) return;
  }

  Future<bool> saveArea({
    required String? id,
    required String locationId,
    required String companyId,
    required String name,
    String? floor,
    String? description,
    DateTime? createdAt,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final isUpdate = id != null;
    final now = DateTime.now();

    final area = AreaEntity(
      id: id ?? const Uuid().v4(),
      locationId: locationId,
      companyId: companyId,
      name: name.trim(),
      floor: floor?.trimToNull(),
      description: description?.trimToNull(),
      createdAt: createdAt ?? now,
      updatedAt: now,
    );

    final dataState = isUpdate
        ? await _useCases.updateArea(area)
        : await _useCases.createArea(area);

    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      final user = _useCases.getSessionUser();
      await loadAreas(user.companyId);
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<bool> deleteArea(String id, String locationId) async {
    emit(state.copyWith(status: StateStatus.deleting));
    final dataState = await _useCases.deleteArea(id);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      final user = _useCases.getSessionUser();
      await loadAreas(user.companyId);
      if (isClosed) return false;
      emit(state.copyWith(status: StateStatus.loaded));

      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.deletingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }
}
