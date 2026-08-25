import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:uuid/uuid.dart';

part 'locations_state.dart';

@injectable
class LocationsCubit extends BaseCubit<LocationsState> {
  LocationsCubit({required LocationsCubitUseCases useCases})
    : _useCases = useCases,
      super(const LocationsState.initial()) {
    _initRealtime();
  }

  final LocationsCubitUseCases _useCases;
  StreamSubscription<RealtimeEvent<LocationEntity>>? _locationsSubscription;
  StreamSubscription<RealtimeEvent<AreaEntity>>? _areasSubscription;

  void _initRealtime() {
    final companyId = _useCases.getActiveCompanyId();
    _locationsSubscription = _useCases
        .watchLocationsRealtime(companyId: companyId)
        .listen(_handleLocationRealtimeEvent);
    _areasSubscription = _useCases
        .watchAreasRealtime(companyId: companyId)
        .listen(_handleAreaRealtimeEvent);
  }

  void _handleLocationRealtimeEvent(RealtimeEvent<LocationEntity> event) {
    if (isClosed) return;

    final currentLocations = List<LocationEntity>.from(state.locations);

    switch (event.eventType) {
      case RealtimeEventType.insert:
        if (event.entity != null) {
          final index = currentLocations.indexWhere((l) => l.id == event.id);
          if (index == -1) {
            currentLocations.insert(0, event.entity!);
          } else {
            currentLocations[index] = event.entity!;
          }
          emit(state.copyWith(locations: currentLocations));
        }
      case RealtimeEventType.update:
        if (event.entity != null) {
          final index = currentLocations.indexWhere((l) => l.id == event.id);
          if (index != -1) {
            currentLocations[index] = event.entity!;
          } else {
            currentLocations.add(event.entity!);
          }
          emit(state.copyWith(locations: currentLocations));
        }
      case RealtimeEventType.delete:
        final index = currentLocations.indexWhere((l) => l.id == event.id);
        if (index != -1) {
          currentLocations.removeAt(index);
          emit(state.copyWith(locations: currentLocations));
        }
    }
  }

  void _handleAreaRealtimeEvent(RealtimeEvent<AreaEntity> event) {
    if (isClosed) return;

    final currentAreas = List<AreaEntity>.from(state.allAreas);

    switch (event.eventType) {
      case RealtimeEventType.insert:
        if (event.entity != null) {
          final index = currentAreas.indexWhere((a) => a.id == event.id);
          if (index == -1) {
            currentAreas.insert(0, event.entity!);
          } else {
            currentAreas[index] = event.entity!;
          }
          _rebuildAreasState(currentAreas);
        }
      case RealtimeEventType.update:
        if (event.entity != null) {
          final index = currentAreas.indexWhere((a) => a.id == event.id);
          if (index != -1) {
            currentAreas[index] = event.entity!;
          } else {
            currentAreas.add(event.entity!);
          }
          _rebuildAreasState(currentAreas);
        }
      case RealtimeEventType.delete:
        final index = currentAreas.indexWhere((a) => a.id == event.id);
        if (index != -1) {
          currentAreas.removeAt(index);
          _rebuildAreasState(currentAreas);
        }
    }
  }

  void _rebuildAreasState(List<AreaEntity> areas) {
    final Map<String, List<AreaEntity>> areasByLocation = {};
    for (final area in areas) {
      areasByLocation.putIfAbsent(area.locationId, () => []).add(area);
    }
    emit(
      state.copyWith(
        allAreas: areas,
        areasByLocation: areasByLocation,
      ),
    );
  }

  Future<void> loadLocationsAndAreas({bool showLoading = true}) async {
    final targetCompanyId = _useCases.getActiveCompanyId();

    emit(state.copyWith(status: showLoading ? StateStatus.loading : null));

    final locationsResult = await _useCases.getLocations(targetCompanyId);
    final areasResult = await _useCases.getAreas(targetCompanyId);

    if (isClosed) return;

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

  /// Provider mode counterpart of [loadLocationsAndAreas]. The provider has no
  /// company of its own to scope by, so only the locations and areas referenced
  /// by its own work orders are fetched — enough for the details page labels.
  /// Silent on failure: these are optional labels, not the page's subject.
  Future<void> loadLocationsAndAreasByIds({
    required List<String> locationIds,
    required List<String> areaIds,
  }) async {
    if (locationIds.isEmpty && areaIds.isEmpty) return;

    final locationsResult = await _useCases.getLocationsByIds(locationIds);
    final areasResult = await _useCases.getAreasByIds(areaIds);

    if (isClosed) return;

    if (locationsResult is! SuccessState<List<LocationEntity>> ||
        areasResult is! SuccessState<List<AreaEntity>>) {
      return;
    }

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
  }

  /// Every location and area of one contracting company, for the provider
  /// create form. Unlike [loadLocationsAndAreas] the rows are never cached
  /// locally: they belong to another tenant.
  Future<void> loadProviderRegistry(String companyId) async {
    emit(state.copyWith(status: StateStatus.loading));

    final locationsResult = await _useCases.getProviderLocations(companyId);
    final areasResult = await _useCases.getProviderAreas(companyId);

    if (isClosed) return;

    if (locationsResult is! SuccessState<List<LocationEntity>> ||
        areasResult is! SuccessState<List<AreaEntity>>) {
      final failure = locationsResult is FailureState
          ? locationsResult
          : areasResult;
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: failure.message,
        ),
      );
      showDataStateToast(failure);
      return;
    }

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
  }

  Future<void> loadAreas() async {
    final companyId = _useCases.getActiveCompanyId();
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
    final companyId = _useCases.getActiveCompanyId.call();
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
      deletedAt: null,
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
          errorMessage: dataState.message,
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
          errorMessage: dataState.message,
        ),
      );
      showDataStateToast(dataState);
    }
    if (isClosed) return;
  }

  Future<bool> saveArea({
    required String? id,
    required String locationId,
    required String name,
    String? floor,
    String? description,
    DateTime? createdAt,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));
    final companyId = _useCases.getActiveCompanyId.call();
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
      deletedAt: null,
    );

    final dataState = isUpdate
        ? await _useCases.updateArea(area)
        : await _useCases.createArea(area);

    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      await loadAreas();
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: dataState.message,
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
      await loadAreas();
      if (isClosed) return false;
      emit(state.copyWith(status: StateStatus.loaded));

      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.deletingError,
          errorMessage: dataState.message,
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<void> navigateToCreateUpdateArea({
    required String locationId,
    AreaEntity? area,
  }) async {
    await pushRoute(
      CreateUpdateAreaRoute(
        locationId: locationId,
        companyId: _useCases.getActiveCompanyId.call(),
        area: area,
      ),
    );
  }

  Future<void> navigateToCreateUpdateLocation({
    LocationEntity? existingLocation,
  }) async {
    await pushRoute(
      CreateUpdateLocationRoute(existingLocation: existingLocation),
    );
  }

  void popRoute() {
    popRouteAdaptively();
  }

  @override
  Future<void> close() {
    _locationsSubscription?.cancel();
    _areasSubscription?.cancel();
    return super.close();
  }
}
