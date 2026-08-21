import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';

abstract interface class LocationsRepository {
  // Locations
  FutureList<LocationEntity> getLocations(String companyId);
  FutureList<LocationEntity> getLocationsByIds(List<String> ids);
  FutureList<LocationEntity> getProviderLocations(String companyId);
  FutureBool createLocation(LocationEntity location);
  FutureBool updateLocation(LocationEntity location);
  FutureBool deleteLocation(String id);

  // Areas
  FutureList<AreaEntity> getAreas(String companyId);
  FutureList<AreaEntity> getAreasByIds(List<String> ids);
  FutureList<AreaEntity> getProviderAreas(String companyId);
  FutureBool createArea(AreaEntity area);
  FutureBool updateArea(AreaEntity area);
  FutureBool deleteArea(String id);
}
