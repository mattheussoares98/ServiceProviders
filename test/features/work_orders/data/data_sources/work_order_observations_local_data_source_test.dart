import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late WorkOrderObservationsLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = WorkOrderObservationsLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertDependencies({
    required String companyId,
    required String userId,
    required String locationId,
    required String areaId,
    required String assetId,
    required String workOrderId,
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

    // 2. UserProfile (Author)
    await database
        .into(database.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            id: userId,
            companyId: companyId,
            name: faker.person.name(),
            email: faker.internet.email(),
            isActive: const Value(true),
          ),
        );

    // 3. Location
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

    // 4. Area
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

    // 5. Asset
    await database
        .into(database.assets)
        .insert(
          AssetsCompanion.insert(
            id: assetId,
            companyId: companyId,
            areaId: areaId,
            name: faker.company.name(),
          ),
        );

    // 6. WorkOrder
    await database
        .into(database.workOrders)
        .insert(
          WorkOrdersCompanion.insert(
            id: workOrderId,
            companyId: companyId,
            locationId: locationId,
            createdById: userId,
            title: faker.job.title(),
            description: Value(faker.lorem.sentence()),
            assetId: Value(assetId),
            status: const Value('opened'),
            type: const Value('corrective'),
            priority: const Value('medium'),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  group('WorkOrderObservationsLocalDataSourceImpl', () {
    final tEntity = EntityFactory.makeWorkOrderObservationEntity();
    final tModel = WorkOrderObservationModel.fromEntity(tEntity);

    const locationId = 'location-id';
    const areaId = 'area-id';
    const assetId = 'asset-id';

    test(
      'saveObservation & getObservations should save and retrieve observation from Drift DB',
      () async {
        await insertDependencies(
          companyId: tModel.companyId,
          userId: tModel.authorId!,
          locationId: locationId,
          areaId: areaId,
          assetId: assetId,
          workOrderId: tModel.workOrderId,
        );

        final saveResult = await dataSource.saveObservation(tModel);
        expect(saveResult, isA<SuccessState<bool>>());

        final getResult = await dataSource.getObservations(tModel.workOrderId);
        expect(getResult, isA<SuccessState<List<WorkOrderObservationModel>>>());
        final list =
            (getResult as SuccessState<List<WorkOrderObservationModel>>).data!;
        expect(list.length, 1);
        expect(list.first.id, tModel.id);
        expect(list.first.content, tModel.content);
      },
    );

    test(
      'saveObservations should insert multiple observations into Drift DB',
      () async {
        await insertDependencies(
          companyId: tModel.companyId,
          userId: tModel.authorId!,
          locationId: locationId,
          areaId: areaId,
          assetId: assetId,
          workOrderId: tModel.workOrderId,
        );

        final tModel2 = WorkOrderObservationModel.fromEntity(
          EntityFactory.makeWorkOrderObservationEntity().copyWith(
            companyId: tModel.companyId,
            workOrderId: tModel.workOrderId,
            authorId: tModel.authorId,
          ),
        );

        final saveBatchResult = await dataSource.saveObservations([
          tModel,
          tModel2,
        ]);
        expect(saveBatchResult, isA<SuccessState<bool>>());

        final getResult = await dataSource.getObservations(tModel.workOrderId);
        final list =
            (getResult as SuccessState<List<WorkOrderObservationModel>>).data!;
        expect(list.length, 2);
      },
    );

    test(
      'deleteObservation should soft-delete observation in Drift DB',
      () async {
        await insertDependencies(
          companyId: tModel.companyId,
          userId: tModel.authorId!,
          locationId: locationId,
          areaId: areaId,
          assetId: assetId,
          workOrderId: tModel.workOrderId,
        );

        await dataSource.saveObservation(tModel);

        final deleteResult = await dataSource.deleteObservation(tModel.id);
        expect(deleteResult, isA<SuccessState<bool>>());

        final getResult = await dataSource.getObservations(tModel.workOrderId);
        final list =
            (getResult as SuccessState<List<WorkOrderObservationModel>>).data!;
        expect(list.isEmpty, true);
      },
    );
  });
}
