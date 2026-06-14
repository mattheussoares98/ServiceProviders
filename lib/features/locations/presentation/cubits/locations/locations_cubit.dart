import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit_use_cases.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'locations_state.dart';

@injectable
class LocationsCubit extends BaseCubit<LocationsState> {
  LocationsCubit({required LocationsCubitUseCases useCases})
    : _useCases = useCases,
      super(const LocationsState.initial());

  final LocationsCubitUseCases _useCases;

  Future<void> loadLocations() async {
    final user = _useCases.getSessionUser();
    if (user.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(state.copyWith(status: StateStatus.error, locations: []));
      return;
    }

    emit(state.copyWith(status: StateStatus.loading));

    final dataState = await _useCases.getLocations(user.companyId);
    if (isClosed) return;

    if (dataState is SuccessState<List<LocationEntity>>) {
      emit(
        state.copyWith(status: StateStatus.loaded, locations: dataState.data),
      );
    } else {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: dataState.message,
        ),
      );
      showDataStateToast(dataState);
    }
  }

  //TODO delete this method and create a new one that return all areas to avoid so many requests
  Future<void> loadAreasForLocation(String locationId) async {
    final dataState = await _useCases.getAreasByLocation(locationId);
    if (isClosed) return;

    if (dataState is SuccessState<List<AreaEntity>>) {
      final updatedAreas = Map<String, List<AreaEntity>>.from(
        state.areasByLocation,
      );
      updatedAreas[locationId] = dataState.data!;
      emit(state.copyWith(areasByLocation: updatedAreas));
    } else {
      showDataStateToast(dataState);
    }
  }

  Future<void> createLocation(LocationEntity location) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.createLocation(location);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Local criado com sucesso'.hardcoded);
      await loadLocations();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }

  Future<void> updateLocation(LocationEntity location) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.updateLocation(location);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Local atualizado com sucesso'.hardcoded);
      await loadLocations();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }

  Future<void> deleteLocation(String id) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.deleteLocation(id);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Local excluído com sucesso'.hardcoded);
      await loadLocations();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }

  Future<void> createArea(AreaEntity area) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.createArea(area);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Área criada com sucesso'.hardcoded);
      emit(state.copyWith(status: StateStatus.loaded));
      await loadAreasForLocation(area.locationId);
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }

  Future<void> updateArea(AreaEntity area) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.updateArea(area);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Área atualizada com sucesso'.hardcoded);
      emit(state.copyWith(status: StateStatus.loaded));
      await loadAreasForLocation(area.locationId);
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }

  Future<void> deleteArea(String id, String locationId) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.deleteArea(id);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Área excluída com sucesso'.hardcoded);
      emit(state.copyWith(status: StateStatus.loaded));
      await loadAreasForLocation(locationId);
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }
}
