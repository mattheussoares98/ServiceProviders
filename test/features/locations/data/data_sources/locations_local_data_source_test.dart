import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';

import '../../../../../testing/mocks/factories/asset_factory.dart';

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
    await database
        .into(database.companies)
        .insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );
  }

  final tLocationEntity = AssetFactory.makeLocationEntity();
  final tLocationModel = LocationModel.fromEntity(tLocationEntity);

  final tAreaEntity = AssetFactory.makeAreaEntity().copyWith(
    locationId: tLocationEntity.id,
    companyId: tLocationEntity.companyId,
  );
  final tAreaModel = AreaModel.fromEntity(tAreaEntity);

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
        final getResult = await dataSource.getLocations(
          tLocationModel.companyId,
        );

        // Assert Get
        expect(getResult, isA<SuccessState<List<LocationModel>>>());
        expect(getResult.data, hasLength(1));
        expect(getResult.data!.first, equals(tLocationModel));
      });

      test(
        'should save a list of locations and successfully retrieve true',
        () async {
          // Arrange
          final locations = [
            LocationModel.fromEntity(
              AssetFactory.makeLocationEntity().copyWith(
                companyId: tLocationModel.companyId,
              ),
            ),
            LocationModel.fromEntity(
              AssetFactory.makeLocationEntity().copyWith(
                companyId: tLocationModel.companyId,
              ),
            ),
            LocationModel.fromEntity(
              AssetFactory.makeLocationEntity().copyWith(
                companyId: tLocationModel.companyId,
              ),
            ),
          ];

          await insertTestCompany(tLocationModel.companyId);

          // Act: Save
          final saveResult = await dataSource.saveLocations(locations);

          // Assert Save
          expect(saveResult, isA<SuccessState<bool>>());
          expect(saveResult.data, isTrue);

          // Act: Get locations
          final getResult = await dataSource.getLocations(
            tLocationModel.companyId,
          );

          // Assert Get
          expect(getResult, isA<SuccessState<List<LocationModel>>>());
          expect(getResult.data, hasLength(locations.length));
          expect(getResult.data, contains(locations[0]));
          expect(getResult.data, contains(locations[1]));
          expect(getResult.data, contains(locations[2]));
        },
      );

      test(
        'should soft-delete a location and verify it is not returned in getLocations',
        () async {
          // Arrange
          await insertTestCompany(tLocationModel.companyId);
          await dataSource.saveLocation(tLocationModel);

          // Act: Delete
          final deleteResult = await dataSource.deleteLocation(
            tLocationModel.id,
          );

          // Assert Delete
          expect(deleteResult, isA<SuccessState<bool>>());
          expect(deleteResult.data, isTrue);

          // Act: Get
          final getResult = await dataSource.getLocations(
            tLocationModel.companyId,
          );

          // Assert Get: Should be empty
          expect(getResult, isA<SuccessState<List<LocationModel>>>());
          expect(getResult.data, isEmpty);
        },
      );
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
        final getResult = await dataSource.getAreas(tLocationModel.companyId);

        // Assert Get
        expect(getResult, isA<SuccessState<List<AreaModel>>>());
        expect(getResult.data, hasLength(1));
        expect(getResult.data!.first, equals(tAreaModel));
      });

      test(
        'should soft-delete an area and verify it is not returned in getAreas',
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
          final getResult = await dataSource.getAreas(tLocationModel.companyId);

          // Assert Get: Should be empty
          expect(getResult, isA<SuccessState<List<AreaModel>>>());
          expect(getResult.data, isEmpty);
        },
      );

      test(
        'should save a list of areas and successfully retrieve them',
        () async {
          final areas = [
            AreaModel.fromEntity(
              AssetFactory.makeAreaEntity().copyWith(
                locationId: tLocationEntity.id,
                companyId: tLocationEntity.companyId,
              ),
            ),
            AreaModel.fromEntity(
              AssetFactory.makeAreaEntity().copyWith(
                locationId: tLocationEntity.id,
                companyId: tLocationEntity.companyId,
              ),
            ),
            AreaModel.fromEntity(
              AssetFactory.makeAreaEntity().copyWith(
                locationId: tLocationEntity.id,
                companyId: tLocationEntity.companyId,
              ),
            ),
          ];

          await insertTestCompany(tLocationModel.companyId);
          await dataSource.saveLocation(tLocationModel);

          final saveResult = await dataSource.saveAreas(areas);

          expect(saveResult, isA<SuccessState<bool>>());
          expect(saveResult.data, isTrue);

          final getResult = await dataSource.getAreas(tLocationModel.companyId);

          expect(getResult, isA<SuccessState<List<AreaModel>>>());
          expect(getResult.data, hasLength(areas.length));
          expect(getResult.data, contains(areas[0]));
          expect(getResult.data, contains(areas[1]));
          expect(getResult.data, contains(areas[2]));
        },
      );
    });
  });
}
