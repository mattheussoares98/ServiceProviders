import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';

abstract interface class LocationsRepository {
  // Locations
  FutureList<LocationEntity> getLocations(String companyId);
  FutureBool createLocation(LocationEntity location);
  FutureBool updateLocation(LocationEntity location);
  FutureBool deleteLocation(String id);

  // Areas
  FutureList<AreaEntity> getAreas(String companyId);
  FutureBool createArea(AreaEntity area);
  FutureBool updateArea(AreaEntity area);
  FutureBool deleteArea(String id);
}