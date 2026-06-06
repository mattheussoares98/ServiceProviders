import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:clean_architecture/features/locations/data/models/responses/area_response_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/location_response_model.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late LocationsLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = LocationsLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertTestCompany(String companyId) async {
    await database.into(database.companies).insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );
  }

  final tLocationEntity = EntityFactory.makeLocationEntity();
  final tLocationModel = LocationResponseModel.fromEntity(tLocationEntity);

  final tAreaEntity = EntityFactory.makeAreaEntity(
    locationId: tLocationEntity.id,
    companyId: tLocationEntity.companyId,
  );
  final tAreaModel = AreaResponseModel.fromEntity(tAreaEntity);

  group('LocationsLocalDataSourceImpl', () {
    group('Locations', () {
      test('should save a location and successfully retrieve it', () async {
        // Arrange
        await insertTestCompany(tLocationModel.companyId);

        // Act: Save
        final saveResult = await dataSource.saveLocation(tLocationModel);

        // Assert Save
        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        // Act: Get locations
        final getResult = await dataSource.getLocations(tLocationModel.companyId);

        // Assert Get
        expect(getResult, isA<SuccessState<List<LocationResponseModel>>>());
        expect(getResult.data, hasLength(1));
        final resultModel = getResult.data!.first;
        expect(resultModel.id, tLocationModel.id);
        expect(resultModel.companyId, tLocationModel.companyId);
        expect(resultModel.name, tLocationModel.name);
        expect(resultModel.address, tLocationModel.address);
        expect(resultModel.city, tLocationModel.city);
        expect(resultModel.state, tLocationModel.state);
        expect(resultModel.isActive, tLocationModel.isActive);
      });

      test(
          'should soft-delete a location and verify it is not returned in getLocations',
          () async {
        // Arrange
        await insertTestCompany(tLocationModel.companyId);
        await dataSource.saveLocation(tLocationModel);

        // Act: Delete
        final deleteResult = await dataSource.deleteLocation(tLocationModel.id);

        // Assert Delete
        expect(deleteResult, isA<SuccessState<bool>>());
        expect(deleteResult.data, isTrue);

        // Act: Get
        final getResult = await dataSource.getLocations(tLocationModel.companyId);

        // Assert Get: Should be empty
        expect(getResult, isA<SuccessState<List<LocationResponseModel>>>());
        expect(getResult.data, isEmpty);
      });
    });

    group('Areas', () {
      test('should save an area and successfully retrieve it', () async {
        // Arrange: Foreign keys
        await insertTestCompany(tLocationModel.companyId);
        await dataSource.saveLocation(tLocationModel);

        // Act: Save Area
        final saveResult = await dataSource.saveArea(tAreaModel);

        // Assert Save
        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        // Act: Get Areas
        final getResult = await dataSource.getAreasByLocation(tLocationModel.id);

        // Assert Get
        expect(getResult, isA<SuccessState<List<AreaResponseModel>>>());
        expect(getResult.data, hasLength(1));
        final resultModel = getResult.data!.first;
        expect(resultModel.id, tAreaModel.id);
        expect(resultModel.locationId, tAreaModel.locationId);
        expect(resultModel.companyId, tAreaModel.companyId);
        expect(resultModel.name, tAreaModel.name);
        expect(resultModel.floor, tAreaModel.floor);
        expect(resultModel.description, tAreaModel.description);
      });

      test(
          'should soft-delete an area and verify it is not returned in getAreasByLocation',
          () async {
        // Arrange
        await insertTestCompany(tLocationModel.companyId);
        await dataSource.saveLocation(tLocationModel);
        await dataSource.saveArea(tAreaModel);

        // Act: Delete
        final deleteResult = await dataSource.deleteArea(tAreaModel.id);

        // Assert Delete
        expect(deleteResult, isA<SuccessState<bool>>());
        expect(deleteResult.data, isTrue);

        // Act: Get
        final getResult = await dataSource.getAreasByLocation(tLocationModel.id);

        // Assert Get: Should be empty
        expect(getResult, isA<SuccessState<List<AreaResponseModel>>>());
        expect(getResult.data, isEmpty);
      });
    });
  });
}
