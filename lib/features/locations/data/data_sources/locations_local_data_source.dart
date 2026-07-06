import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';

abstract interface class LocationsLocalDataSource {
  FutureList<LocationModel> getLocations(String companyId);
  FutureBool saveLocation(LocationModel location);
  FutureBool deleteLocation(String id);
  FutureBool saveLocations(List<LocationModel> locations);

  FutureList<AreaModel> getAreas(String companyId);
  FutureBool saveArea(AreaModel area);
  FutureBool deleteArea(String id);
  FutureBool saveAreas(List<AreaModel> areas);
}

@LazySingleton(as: LocationsLocalDataSource)
final class LocationsLocalDataSourceImpl implements LocationsLocalDataSource {
  LocationsLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureList<LocationModel> getLocations(String companyId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.locations)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map(
            (row) => LocationModel(
              id: row.id,
              companyId: row.companyId,
              name: row.name,
              address: row.address,
              city: row.city,
              state: row.state,
              isActive: row.isActive,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
              deletedAt: row.deletedAt,
              complement: row.complement,
              number: row.number,
              neighborhood: row.neighborhood,
              postalCode: row.postalCode,
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveLocation(LocationModel location) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.locations)
          .insertOnConflictUpdate(
            LocationsCompanion(
              id: Value(location.id),
              companyId: Value(location.companyId),
              name: Value(location.name),
              address: Value(location.address),
              city: Value(location.city),
              state: Value(location.state),
              isActive: Value(location.isActive),
              createdAt: Value(location.createdAt),
              updatedAt: Value(location.updatedAt),
              deletedAt: Value(location.deletedAt),
              complement: Value(location.complement),
              number: Value(location.number),
              neighborhood: Value(location.neighborhood),
              postalCode: Value(location.postalCode),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveLocations(List<LocationModel> locations) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.locations,
          locations
              .map(
                (location) => LocationsCompanion(
                  id: Value(location.id),
                  companyId: Value(location.companyId),
                  name: Value(location.name),
                  address: Value(location.address),
                  city: Value(location.city),
                  state: Value(location.state),
                  isActive: Value(location.isActive),
                  createdAt: Value(location.createdAt),
                  updatedAt: Value(location.updatedAt),
                  deletedAt: Value(location.deletedAt),
                  complement: Value(location.complement),
                  number: Value(location.number),
                  neighborhood: Value(location.neighborhood),
                  postalCode: Value(location.postalCode),
                ),
              )
              .toList(),
        );
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteLocation(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.locations)
        ..where((t) => t.id.equals(id));
      await query.write(LocationsCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }

  @override
  FutureList<AreaModel> getAreas(String companyId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.areas)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map(
            (row) => AreaModel(
              id: row.id,
              locationId: row.locationId,
              companyId: row.companyId,
              name: row.name,
              floor: row.floor,
              description: row.description,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
              deletedAt: row.deletedAt,
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveArea(AreaModel area) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.areas)
          .insertOnConflictUpdate(
            AreasCompanion(
              id: Value(area.id),
              locationId: Value(area.locationId),
              companyId: Value(area.companyId),
              name: Value(area.name),
              floor: Value(area.floor),
              description: Value(area.description),
              createdAt: Value(area.createdAt),
              updatedAt: Value(area.updatedAt),
              deletedAt: Value(area.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteArea(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.areas)
        ..where((t) => t.id.equals(id));
      await query.write(AreasCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveAreas(List<AreaModel> areas) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.areas,
          areas
              .map(
                (area) => AreasCompanion(
                  id: Value(area.id),
                  locationId: Value(area.locationId),
                  companyId: Value(area.companyId),
                  name: Value(area.name),
                  floor: Value(area.floor),
                  description: Value(area.description),
                  createdAt: Value(area.createdAt),
                  updatedAt: Value(area.updatedAt),
                  deletedAt: Value(area.deletedAt),
                ),
              )
              .toList(),
        );
      });
      return const SuccessState(data: true);
    });
  }
}
