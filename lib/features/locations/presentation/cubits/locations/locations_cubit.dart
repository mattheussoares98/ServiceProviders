import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/realtime_list_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/address_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:uuid/uuid.dart';

part 'locations_state.dart';

enum LocationsSections implements SectionKey {
  saveLocation,
  deleteLocation,
  saveArea,
  deleteArea,
  loadAddressByCep,
}

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

    final updatedLocations = state.locations.applyRealtimeEvent(
      event: event,
      idSelector: (l) => l.id,
      isDeleted: (l) => l.deletedAt != null,
    );
    emit(state.copyWith(locations: updatedLocations));
  }

  void _handleAreaRealtimeEvent(RealtimeEvent<AreaEntity> event) {
    if (isClosed) return;

    final updatedAreas = state.allAreas.applyRealtimeEvent(
      event: event,
      idSelector: (a) => a.id,
      isDeleted: (a) => a.deletedAt != null,
    );
    _rebuildAreasState(updatedAreas);
  }

  void _rebuildAreasState(List<AreaEntity> areas) {
    final Map<String, List<AreaEntity>> areasByLocation = {};
    for (final area in areas) {
      areasByLocation.putIfAbsent(area.locationId, () => []).add(area);
    }
    emit(state.copyWith(allAreas: areas, areasByLocation: areasByLocation));
  }

  Future<void> loadLocationsAndAreas({bool showLoading = true}) async {
    final targetCompanyId = _useCases.getActiveCompanyId();

    if (showLoading) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    }

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
          locations: locationsResult.data,
          areasByLocation: areasByLocation,
          allAreas: areas,
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
    } else {
      final errorMessage = locationsResult is FailureState
          ? locationsResult.message
          : areasResult.message;
      emit(
        state.copyWith(
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: errorMessage,
          ),
        ),
      );
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
        locations: locationsResult.data,
        areasByLocation: areasByLocation,
        allAreas: areas,
        sections: withSection(BaseSections.load, SectionStatus.success),
      ),
    );
  }

  /// Every location and area of one contracting company, for the provider
  /// create form. Unlike [loadLocationsAndAreas] the rows are never cached
  /// locally: they belong to another tenant.
  Future<void> loadProviderRegistry(String companyId) async {
    emit(
      state.copyWith(
        sections: withSection(BaseSections.load, SectionStatus.running),
      ),
    );

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
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: failure.message,
          ),
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
        locations: locationsResult.data,
        areasByLocation: areasByLocation,
        allAreas: areas,
        sections: withSection(BaseSections.load, SectionStatus.success),
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
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      final message = 'Nome do local não pode ser vazio'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.saveLocation,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }

    emit(
      state.copyWith(
        sections: withSection(
          LocationsSections.saveLocation,
          SectionStatus.running,
        ),
      ),
    );
    final companyId = _useCases.getActiveCompanyId.call();
    final isUpdate = id != null;
    final now = DateTime.now();

    final location = LocationEntity(
      id: id ?? const Uuid().v4(),
      companyId: companyId,
      name: trimmedName,
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
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.saveLocation,
            SectionStatus.success,
          ),
        ),
      );
      await loadLocationsAndAreas(showLoading: false);
      return true;
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.saveLocation,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<void> deleteLocation(String id) async {
    final hasLinkedAreas =
        (state.areasByLocation[id]?.isNotEmpty ?? false) ||
        state.allAreas.any((a) => a.locationId == id);
    if (hasLinkedAreas) {
      final message =
          'Não é possível excluir um local com áreas vinculadas'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.deleteLocation,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
      return;
    }

    emit(
      state.copyWith(
        sections: withSection(
          LocationsSections.deleteLocation,
          SectionStatus.running,
        ),
      ),
    );
    final dataState = await _useCases.deleteLocation(id);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      final updatedLocations = state.locations
          .where((l) => l.id != id)
          .toList();
      emit(
        state.copyWith(
          locations: updatedLocations,
          sections: withSection(
            LocationsSections.deleteLocation,
            SectionStatus.success,
          ),
        ),
      );
      await loadLocationsAndAreas(showLoading: false);
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.deleteLocation,
            SectionStatus.error,
          ),
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
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      final message = 'Nome da área não pode ser vazio'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.saveArea,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }

    if (state.locations.isNotEmpty &&
        !state.locations.any((l) => l.id == locationId)) {
      final message = 'Local selecionado não existe'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.saveArea,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }

    emit(
      state.copyWith(
        sections: withSection(
          LocationsSections.saveArea,
          SectionStatus.running,
        ),
      ),
    );
    final companyId = _useCases.getActiveCompanyId.call();
    final isUpdate = id != null;
    final now = DateTime.now();

    final area = AreaEntity(
      id: id ?? const Uuid().v4(),
      locationId: locationId,
      companyId: companyId,
      name: trimmedName,
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
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.saveArea,
            SectionStatus.success,
          ),
        ),
      );
      await loadAreas();
      return true;
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.saveArea,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<bool> deleteArea(String id, String locationId) async {
    emit(
      state.copyWith(
        sections: withSection(
          LocationsSections.deleteArea,
          SectionStatus.running,
        ),
      ),
    );
    final dataState = await _useCases.deleteArea(id);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      final updatedAreas = state.allAreas.where((a) => a.id != id).toList();
      _rebuildAreasState(updatedAreas);
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.deleteArea,
            SectionStatus.success,
          ),
        ),
      );
      await loadAreas();
      return true;
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.deleteArea,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<AddressEntity?> getAddressByCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length != 8) return null;

    emit(
      state.copyWith(
        sections: withSection(
          LocationsSections.loadAddressByCep,
          SectionStatus.running,
        ),
      ),
    );

    final dataState = await _useCases.getAddressByCep(cleanCep);

    if (dataState is SuccessState<AddressEntity>) {
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.loadAddressByCep,
            SectionStatus.success,
          ),
        ),
      );
      return dataState.data;
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            LocationsSections.loadAddressByCep,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
      return null;
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
