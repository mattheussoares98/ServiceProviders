import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late WorkOrdersLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = WorkOrdersLocalDataSourceImpl(database: database);
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

    // 2. UserProfile
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
  }

  group('WorkOrdersLocalDataSourceImpl - Work Orders', () {
    final tWorkOrderEntity = EntityFactory.makeWorkOrderEntity().copyWith(
      attachments: const [],
    );
    final tWorkOrderModel = WorkOrderResponseModel.fromEntity(tWorkOrderEntity);

    test(
      'should save a work order and successfully retrieve it by companyId and by id',
      () async {
        // Arrange
        await insertDependencies(
          companyId: tWorkOrderModel.companyId,
          userId: tWorkOrderModel.createdById,
          locationId: tWorkOrderModel.locationId,
          areaId: faker.guid.guid(),
          assetId: tWorkOrderModel.assetId!,
        );

        // Seed assigned user too
        await database
            .into(database.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: tWorkOrderModel.assignedToId!,
                companyId: tWorkOrderModel.companyId,
                name: faker.person.name(),
                email: faker.internet.email(),
                isActive: const Value(true),
              ),
            );

        // Act: Save
        final saveResult = await dataSource.saveWorkOrder(tWorkOrderModel);

        // Assert Save
        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        // Act: Get Work Orders
        final getListResult = await dataSource.getWorkOrders(
          tWorkOrderModel.companyId,
        );

        // Assert Get List
        expect(
          getListResult,
          isA<SuccessState<List<WorkOrderResponseModel>>>(),
        );
        expect(getListResult.data, hasLength(1));
        expect(getListResult.data!.first, equals(tWorkOrderModel));

        // Act: Get single by id
        final getSingleResult = await dataSource.getWorkOrderById(
          tWorkOrderModel.id,
        );

        // Assert Get Single
        expect(getSingleResult, isA<SuccessState<WorkOrderResponseModel>>());
        expect(getSingleResult.data, equals(tWorkOrderModel));
      },
    );

    test(
      'should return FailureState when getting a non-existent work order',
      () async {
        // Act
        final result = await dataSource.getWorkOrderById(faker.guid.guid());

        // Assert
        expect(result, isA<FailureState<WorkOrderResponseModel>>());
        expect(result.message, 'Work order not found');
      },
    );

    test(
      'should soft-delete a work order and verify it is not returned in active queries',
      () async {
        // Arrange
        await insertDependencies(
          companyId: tWorkOrderModel.companyId,
          userId: tWorkOrderModel.createdById,
          locationId: tWorkOrderModel.locationId,
          areaId: faker.guid.guid(),
          assetId: tWorkOrderModel.assetId!,
        );
        await dataSource.saveWorkOrder(tWorkOrderModel);

        // Act: Delete
        final deleteResult = await dataSource.deleteWorkOrder(
          tWorkOrderModel.id,
        );

        // Assert Delete
        expect(deleteResult, isA<SuccessState<bool>>());
        expect(deleteResult.data, isTrue);

        // Act: Get list
        final getListResult = await dataSource.getWorkOrders(
          tWorkOrderModel.companyId,
        );
        expect(
          getListResult,
          isA<SuccessState<List<WorkOrderResponseModel>>>(),
        );
        expect(getListResult.data, isEmpty);

        // Act: Get single
        final getSingleResult = await dataSource.getWorkOrderById(
          tWorkOrderModel.id,
        );
        expect(getSingleResult, isA<FailureState<WorkOrderResponseModel>>());
      },
    );

    test(
      'should not return work order in getWorkOrders/getWorkOrderById when its location is soft-deleted',
      () async {
        // Arrange
        await insertDependencies(
          companyId: tWorkOrderModel.companyId,
          userId: tWorkOrderModel.createdById,
          locationId: tWorkOrderModel.locationId,
          areaId: faker.guid.guid(),
          assetId: tWorkOrderModel.assetId!,
        );
        await dataSource.saveWorkOrder(tWorkOrderModel);

        // Soft-delete the location
        await database
            .update(database.locations)
            .write(LocationsCompanion(deletedAt: Value(DateTime.now())));

        // Act
        final getListResult = await dataSource.getWorkOrders(
          tWorkOrderModel.companyId,
        );
        final getSingleResult = await dataSource.getWorkOrderById(
          tWorkOrderModel.id,
        );

        // Assert
        expect(
          getListResult,
          isA<SuccessState<List<WorkOrderResponseModel>>>(),
        );
        expect(getListResult.data, isEmpty);
        expect(getSingleResult, isA<FailureState<WorkOrderResponseModel>>());
      },
    );

    test(
      'should correctly apply all filters and pagination (limit/offset) on getWorkOrders',
      () async {
        final baseEntity = EntityFactory.makeWorkOrderEntity().copyWith(
          attachments: const [],
          status: WorkOrderStatus.open,
          priority: Priority.high,
          type: WorkOrderType.preventive,
          title: 'Manutenção de teste',
          scheduledDate: DateTime(2026, 7, 15),
        );
        final modelMatch = WorkOrderResponseModel.fromEntity(baseEntity);

        await insertDependencies(
          companyId: modelMatch.companyId,
          userId: modelMatch.createdById,
          locationId: modelMatch.locationId,
          areaId: faker.guid.guid(),
          assetId: modelMatch.assetId!,
        );

        // Seed assigned user too
        await database
            .into(database.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: modelMatch.assignedToId!,
                companyId: modelMatch.companyId,
                name: faker.person.name(),
                email: faker.internet.email(),
                isActive: const Value(true),
              ),
            );

        final modelNonMatch = WorkOrderResponseModel.fromEntity(
          baseEntity.copyWith(
            id: faker.guid.guid(),
            title: 'Outro titulo',
            status: WorkOrderStatus.completed,
          ),
        );

        await dataSource.saveWorkOrder(modelMatch);
        await dataSource.saveWorkOrder(modelNonMatch);

        final filter = WorkOrderFilter(
          statuses: const [WorkOrderStatus.open],
          priorities: const [Priority.high],
          type: WorkOrderType.preventive,
          assignedToId: modelMatch.assignedToId,
          scheduledDateFrom: DateTime(2026, 7, 14),
          scheduledDateTo: DateTime(2026, 7, 16),
          searchText: 'teste',
        );

        // Verify filter works
        final filterResult = await dataSource.getWorkOrders(
          modelMatch.companyId,
          filter: filter,
        );

        expect(filterResult.data, hasLength(1));
        expect(filterResult.data!.first.id, modelMatch.id);

        // Verify pagination (limit / offset)
        final pagedResult1 = await dataSource.getWorkOrders(
          modelMatch.companyId,
          pageSize: 1,
        );
        expect(pagedResult1.data, hasLength(1));

        final pagedResult2 = await dataSource.getWorkOrders(
          modelMatch.companyId,
          pageSize: 1,
          offset: 1,
        );
        expect(pagedResult2.data, hasLength(1));
        expect(pagedResult2.data!.first.id, isNot(pagedResult1.data!.first.id));
      },
    );
  });

  group('WorkOrdersLocalDataSourceImpl - Tasks', () {
    final tTaskEntity = EntityFactory.makeTaskEntity();
    final tTaskModel = TaskResponseModel.fromEntity(tTaskEntity);
    final tWorkOrderEntity = EntityFactory.makeWorkOrderEntity().copyWith(
      id: tTaskModel.workOrderId,
      attachments: const [],
    );
    final tWorkOrderModel = WorkOrderResponseModel.fromEntity(tWorkOrderEntity);

    test(
      'should save a task, retrieve active tasks by workOrderId, and soft delete it',
      () async {
        // Arrange
        await insertDependencies(
          companyId: tTaskModel.companyId,
          userId: tWorkOrderModel.createdById,
          locationId: tWorkOrderModel.locationId,
          areaId: faker.guid.guid(),
          assetId: tWorkOrderModel.assetId!,
        );
        await dataSource.saveWorkOrder(tWorkOrderModel);

        // Act: Save Task
        final saveResult = await dataSource.saveTask(tTaskModel);
        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        // Act: Get Tasks
        final getListResult = await dataSource.getTasksByWorkOrder(
          tTaskModel.workOrderId,
        );
        expect(getListResult, isA<SuccessState<List<TaskResponseModel>>>());
        expect(getListResult.data, hasLength(1));
        expect(getListResult.data!.first, equals(tTaskModel));

        // Act: Delete Task
        final deleteResult = await dataSource.deleteTask(tTaskModel.id);
        expect(deleteResult, isA<SuccessState<bool>>());
        expect(deleteResult.data, isTrue);

        // Act: Get Tasks again
        final getListResult2 = await dataSource.getTasksByWorkOrder(
          tTaskModel.workOrderId,
        );
        expect(getListResult2.data, isEmpty);
      },
    );
  });

  group('WorkOrdersLocalDataSourceImpl - Change Requests', () {
    final tChangeEntity = EntityFactory.makeWorkOrderChangeRequestEntity();
    final tChangeModel = WorkOrderChangeRequestResponseModel.fromEntity(
      tChangeEntity,
    );
    final tWorkOrderEntity = EntityFactory.makeWorkOrderEntity().copyWith(
      id: tChangeModel.workOrderId,
      attachments: const [],
    );
    final tWorkOrderModel = WorkOrderResponseModel.fromEntity(tWorkOrderEntity);

    test(
      'should save a change request, retrieve active requests, and review it',
      () async {
        // Arrange
        await insertDependencies(
          companyId: tChangeModel.companyId,
          userId: tChangeModel.requestedById,
          locationId: tWorkOrderModel.locationId,
          areaId: faker.guid.guid(),
          assetId: tWorkOrderModel.assetId!,
        );
        await dataSource.saveWorkOrder(tWorkOrderModel);

        // Act: Save Change Request
        final saveResult = await dataSource.saveChangeRequest(tChangeModel);
        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        // Act: Get Change Requests
        final getListResult = await dataSource.getChangeRequests(
          tChangeModel.companyId,
        );
        expect(
          getListResult,
          isA<SuccessState<List<WorkOrderChangeRequestResponseModel>>>(),
        );
        expect(getListResult.data, hasLength(1));
        expect(getListResult.data!.first, equals(tChangeModel));

        // Act: Review Change Request
        final tReviewerId = faker.guid.guid();
        // Seed reviewer
        await database
            .into(database.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: tReviewerId,
                companyId: tChangeModel.companyId,
                name: faker.person.name(),
                email: faker.internet.email(),
                isActive: const Value(true),
              ),
            );

        final reviewResult = await dataSource.reviewChangeRequest(
          id: tChangeModel.id,
          status: 'approved',
          rejectionReason: 'Looks good',
          reviewedById: tReviewerId,
        );
        expect(reviewResult, isA<SuccessState<bool>>());
        expect(reviewResult.data, isTrue);

        // Act: Verify updated status
        final getListResult2 = await dataSource.getChangeRequests(
          tChangeModel.companyId,
        );
        final updatedReq = getListResult2.data!.first;
        expect(updatedReq.status.code, 'approved');
        expect(updatedReq.reviewedById, tReviewerId);
        expect(updatedReq.rejectionReason, 'Looks good');
      },
    );
  });

  group('WorkOrdersLocalDataSourceImpl - History', () {
    final tHistoryEntity = EntityFactory.makeWorkOrderHistoryEntity();
    final tHistoryModel = WorkOrderHistoryResponseModel.fromEntity(
      tHistoryEntity,
    );
    final tWorkOrderEntity = EntityFactory.makeWorkOrderEntity().copyWith(
      id: tHistoryModel.workOrderId,
      attachments: const [],
    );
    final tWorkOrderModel = WorkOrderResponseModel.fromEntity(tWorkOrderEntity);

    test('should save and retrieve work order history logs', () async {
      // Arrange
      await insertDependencies(
        companyId: tHistoryModel.companyId,
        userId: tHistoryModel.userId,
        locationId: tWorkOrderModel.locationId,
        areaId: faker.guid.guid(),
        assetId: tWorkOrderModel.assetId!,
      );
      await dataSource.saveWorkOrder(tWorkOrderModel);

      // Act: Save History
      final saveResult = await dataSource.saveWorkOrderHistory(tHistoryModel);
      expect(saveResult, isA<SuccessState<bool>>());
      expect(saveResult.data, isTrue);

      // Act: Get History
      final getListResult = await dataSource.getWorkOrderHistory(
        tHistoryModel.workOrderId,
      );
      expect(
        getListResult,
        isA<SuccessState<List<WorkOrderHistoryResponseModel>>>(),
      );
      expect(getListResult.data, hasLength(1));
      expect(getListResult.data!.first, equals(tHistoryModel));
    });
  });
}
