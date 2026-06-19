import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/data/data_sources/assets_local_data_source.dart';
import 'package:clean_architecture/features/assets/data/models/responses/asset_model.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late AssetsLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = AssetsLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertDependencies({
    required String companyId,
    required String locationId,
    required String areaId,
    required String categoryId,
  }) async {
    // 1. Company
    await database
        .into(database.companies)
        .insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );

    // 2. Location
    await database
        .into(database.locations)
        .insert(
          LocationsCompanion.insert(
            id: locationId,
            companyId: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );

    // 3. Area
    await database
        .into(database.areas)
        .insert(
          AreasCompanion.insert(
            id: areaId,
            locationId: locationId,
            companyId: companyId,
            name: faker.company.name(),
          ),
        );

    // 4. Category
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            companyId: companyId,
            name: faker.company.name(),
          ),
        );
  }

  final tAssetEntity = EntityFactory.makeAssetEntity();
  final tAssetModel = AssetModel.fromEntity(tAssetEntity);
  final tLocationId = faker.guid.guid();

  group('AssetsLocalDataSourceImpl', () {
    test(
      'should save an asset and successfully retrieve it by companyId and by id',
      () async {
        // Arrange
        await insertDependencies(
          companyId: tAssetModel.companyId,
          locationId: tLocationId,
          areaId: tAssetModel.areaId,
          categoryId: tAssetModel.categoryId ?? faker.guid.guid(),
        );

        // Act: Save
        final saveResult = await dataSource.saveAsset(tAssetModel);

        // Assert Save
        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        // Act: Get Assets by companyId
        final getListResult = await dataSource.getAssets(tAssetModel.companyId);

        // Assert Get List
        expect(getListResult, isA<SuccessState<List<AssetModel>>>());
        expect(getListResult.data, hasLength(1));
        final resultModel = getListResult.data!.first;
        expect(resultModel.id, tAssetModel.id);
        expect(resultModel.companyId, tAssetModel.companyId);
        expect(resultModel.areaId, tAssetModel.areaId);
        expect(resultModel.categoryId, tAssetModel.categoryId);
        expect(resultModel.name, tAssetModel.name);
        expect(resultModel.code, tAssetModel.code);
        expect(resultModel.manufacturer, tAssetModel.manufacturer);
        expect(resultModel.model, tAssetModel.model);
        expect(resultModel.serialNumber, tAssetModel.serialNumber);
        expect(resultModel.status, tAssetModel.status);
        expect(resultModel.criticality, tAssetModel.criticality);
        expect(resultModel.notes, tAssetModel.notes);

        // Act: Get Asset by id
        final getSingleResult = await dataSource.getAssetById(tAssetModel.id);

        // Assert Get Single
        expect(getSingleResult, isA<SuccessState<AssetModel>>());
        expect(getSingleResult.data!.id, tAssetModel.id);
      },
    );

    test(
      'should return FailureState when getting a non-existent asset by id',
      () async {
        // Act
        final result = await dataSource.getAssetById(faker.guid.guid());

        // Assert
        expect(result, isA<FailureState<AssetModel>>());
        expect(result.message, 'Equipamento não encontrado'.hardcoded);
      },
    );

    test(
      'should soft-delete an asset and verify it is not returned in queries',
      () async {
        // Arrange
        await insertDependencies(
          companyId: tAssetModel.companyId,
          locationId: tLocationId,
          areaId: tAssetModel.areaId,
          categoryId: tAssetModel.categoryId ?? faker.guid.guid(),
        );
        await dataSource.saveAsset(tAssetModel);

        // Act: Delete
        final deleteResult = await dataSource.deleteAsset(tAssetModel.id);

        // Assert Delete
        expect(deleteResult, isA<SuccessState<bool>>());
        expect(deleteResult.data, isTrue);

        // Act: Get list
        final getListResult = await dataSource.getAssets(tAssetModel.companyId);
        expect(getListResult, isA<SuccessState<List<AssetModel>>>());
        expect(getListResult.data, isEmpty);

        // Act: Get single
        final getSingleResult = await dataSource.getAssetById(tAssetModel.id);
        expect(getSingleResult, isA<FailureState<AssetModel>>());
      },
    );

    test(
      'should not return asset in getAssets/getAssetById when its parent area is soft-deleted',
      () async {
        // Arrange
        await insertDependencies(
          companyId: tAssetModel.companyId,
          locationId: tLocationId,
          areaId: tAssetModel.areaId,
          categoryId: tAssetModel.categoryId ?? faker.guid.guid(),
        );
        await dataSource.saveAsset(tAssetModel);

        // Soft-delete the area
        await database
            .update(database.areas)
            .write(AreasCompanion(deletedAt: Value(DateTime.now())));

        // Act
        final getListResult = await dataSource.getAssets(tAssetModel.companyId);
        final getSingleResult = await dataSource.getAssetById(tAssetModel.id);

        // Assert
        expect(getListResult, isA<SuccessState<List<AssetModel>>>());
        expect(getListResult.data, isEmpty);
        expect(getSingleResult, isA<FailureState<AssetModel>>());
      },
    );

    test(
      'should not return asset in getAssets/getAssetById when its parent location is soft-deleted',
      () async {
        // Arrange
        await insertDependencies(
          companyId: tAssetModel.companyId,
          locationId: tLocationId,
          areaId: tAssetModel.areaId,
          categoryId: tAssetModel.categoryId ?? faker.guid.guid(),
        );
        await dataSource.saveAsset(tAssetModel);

        // Soft-delete the location
        await database
            .update(database.locations)
            .write(LocationsCompanion(deletedAt: Value(DateTime.now())));

        // Act
        final getListResult = await dataSource.getAssets(tAssetModel.companyId);
        final getSingleResult = await dataSource.getAssetById(tAssetModel.id);

        // Assert
        expect(getListResult, isA<SuccessState<List<AssetModel>>>());
        expect(getListResult.data, isEmpty);
        expect(getSingleResult, isA<FailureState<AssetModel>>());
      },
    );
  });
}
