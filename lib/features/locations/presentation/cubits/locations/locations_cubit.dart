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

  Future<void> loadLocationsAndAreas({bool showLoading = true}) async {
    final user = _useCases.getSessionUser();
    if (user.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(state.copyWith(status: StateStatus.error, locations: []));
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
          annulErrorMessage: true,
        ),
      );
    } else {
      final errorMessage = locationsResult is FailureState
          ? locationsResult.message
          : areasResult.message;
      emit(
        state.copyWith(status: StateStatus.error, errorMessage: errorMessage),
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
      emit(state.copyWith(areasByLocation: areasByLocation));
    } else {
      showDataStateToast(dataState);
    }
  }

  Future<bool> createLocation(LocationEntity location) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.createLocation(location);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      await loadLocationsAndAreas();
      return true;
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<bool> updateLocation(LocationEntity location) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.updateLocation(location);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      await loadLocationsAndAreas();
      return true;
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<void> deleteLocation(String id) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.deleteLocation(id);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      await loadLocationsAndAreas();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }

  Future<bool> createArea(AreaEntity area) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.createArea(area);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      final user = _useCases.getSessionUser();
      await loadAreas(user.companyId);
      return true;
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<bool> updateArea(AreaEntity area) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.updateArea(area);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      final user = _useCases.getSessionUser();
      await loadAreas(user.companyId);
      return true;
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<void> deleteArea(String id, String locationId) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.deleteArea(id);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      final user = _useCases.getSessionUser();
      await loadAreas(user.companyId);
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }
}
