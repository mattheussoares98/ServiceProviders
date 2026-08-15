import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_reason_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late PauseLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = PauseLocalDataSourceImpl(database: database);
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

  group('PauseLocalDataSourceImpl', () {
    final tReasonEntity = EntityFactory.makePauseReasonEntity();
    final tReasonModel = PauseReasonModel.fromEntity(tReasonEntity);

    final tRequestEntity = EntityFactory.makePauseRequestEntity();
    final tRequestModel = PauseRequestModel.fromEntity(tRequestEntity);

    final userId = tRequestModel.requestedById ?? 'user-id';
    const locationId = 'location-id';
    const areaId = 'area-id';
    const assetId = 'asset-id';

    group('savePauseReason', () {
      test(
        'should save PauseReason successfully when company exists',
        () async {
          await database
              .into(database.companies)
              .insert(
                CompaniesCompanion.insert(
                  id: tReasonModel.companyId,
                  name: faker.company.name(),
                  isActive: const Value(true),
                ),
              );

          final result = await dataSource.savePauseReason(tReasonModel);

          expect(result, isA<SuccessState<bool>>());
          expect((result as SuccessState<bool>).data, true);
        },
      );
    });

    group('getPauseReasons', () {
      test('should return list of saved pause reasons for a company', () async {
        await database
            .into(database.companies)
            .insert(
              CompaniesCompanion.insert(
                id: tReasonModel.companyId,
                name: faker.company.name(),
                isActive: const Value(true),
              ),
            );
        await dataSource.savePauseReason(tReasonModel);

        final result = await dataSource.getPauseReasons(tReasonModel.companyId);

        expect(result, isA<SuccessState<List<PauseReasonModel>>>());
        final list = (result as SuccessState<List<PauseReasonModel>>).data!;
        expect(list.length, 1);
        expect(list.first.id, tReasonModel.id);
      });
    });

    group('savePauseRequest', () {
      test('should save PauseRequest successfully', () async {
        await insertDependencies(
          companyId: tRequestModel.companyId,
          userId: userId,
          locationId: locationId,
          areaId: areaId,
          assetId: assetId,
          workOrderId: tRequestModel.workOrderId,
        );

        final result = await dataSource.savePauseRequest(tRequestModel);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
      });
    });

    group('getPauseRequests', () {
      test('should return list of pause requests for a work order', () async {
        await insertDependencies(
          companyId: tRequestModel.companyId,
          userId: userId,
          locationId: locationId,
          areaId: areaId,
          assetId: assetId,
          workOrderId: tRequestModel.workOrderId,
        );
        await dataSource.savePauseRequest(tRequestModel);

        final result = await dataSource.getPauseRequests(
          tRequestModel.workOrderId,
        );

        expect(result, isA<SuccessState<List<PauseRequestModel>>>());
        final list = (result as SuccessState<List<PauseRequestModel>>).data!;
        expect(list.length, 1);
        expect(list.first.id, tRequestModel.id);
      });
    });

    group('reviewPause', () {
      test(
        'should update status and review fields of a pause request without changing work order status',
        () async {
          await insertDependencies(
            companyId: tRequestModel.companyId,
            userId: userId,
            locationId: locationId,
            areaId: areaId,
            assetId: assetId,
            workOrderId: tRequestModel.workOrderId,
          );
          await dataSource.savePauseRequest(tRequestModel);

          final result = await dataSource.reviewPause(
            id: tRequestModel.id,
            workOrderId: tRequestModel.workOrderId,
            status: 'approved',
            reviewedById: userId,
            reviewObservation: 'Approved request',
          );

          expect(result, isA<SuccessState<bool>>());
          expect((result as SuccessState<bool>).data, true);

          final check = await dataSource.getPauseRequests(
            tRequestModel.workOrderId,
          );
          final updated =
              (check as SuccessState<List<PauseRequestModel>>).data!.first;
          expect(updated.status.value, 'approved');
          expect(updated.reviewedById, userId);
          expect(updated.reviewObservation, 'Approved request');

          final wo = await (database.select(
            database.workOrders,
          )..where((t) => t.id.equals(tRequestModel.workOrderId))).getSingle();
          final expectedWoStatus =
              tRequestModel.eventType == PauseEventType.completion
              ? WorkOrderStatus.pendingConclusionApproval.code
              : WorkOrderStatus.pendingPauseApproval.code;
          expect(wo.status, expectedWoStatus);
        },
      );
    });

    group('reviewCompletion', () {
      test(
        'should update completion request and set work order to completed when approved',
        () async {
          final completionRequest = PauseRequestModel.fromEntity(
            EntityFactory.makePauseRequestEntity().copyWith(
              companyId: tRequestModel.companyId,
              workOrderId: tRequestModel.workOrderId,
              eventType: PauseEventType.completion,
            ),
          );

          await insertDependencies(
            companyId: completionRequest.companyId,
            userId: userId,
            locationId: locationId,
            areaId: areaId,
            assetId: assetId,
            workOrderId: completionRequest.workOrderId,
          );
          await dataSource.savePauseRequest(completionRequest);

          final result = await dataSource.reviewCompletion(
            id: completionRequest.id,
            workOrderId: completionRequest.workOrderId,
            status: 'approved',
            reviewedById: userId,
            reviewObservation: 'Work finished',
            responsibility: 'contractor',
            completionReason: 'Completed successfully',
          );

          expect(result, isA<SuccessState<bool>>());
          expect((result as SuccessState<bool>).data, true);

          final wo =
              await (database.select(database.workOrders)
                    ..where((t) => t.id.equals(completionRequest.workOrderId)))
                  .getSingle();
          expect(wo.status, 'completed');
          expect(wo.completionReason, 'Completed successfully');
          expect(wo.completionResponsibility, 'contractor');
          expect(wo.completedAt, isNotNull);
        },
      );
    });

    group('cancelPause', () {
      test(
        'should cancel the pause, set resumedAt, and update work order to in_progress',
        () async {
          await insertDependencies(
            companyId: tRequestModel.companyId,
            userId: userId,
            locationId: locationId,
            areaId: areaId,
            assetId: assetId,
            workOrderId: tRequestModel.workOrderId,
          );
          await dataSource.savePauseRequest(tRequestModel);

          final resumedAt = DateTime.now().add(const Duration(hours: 2));
          final result = await dataSource.cancelPause(
            id: tRequestModel.id,
            workOrderId: tRequestModel.workOrderId,
            resumedAt: resumedAt,
            resumedById: userId,
          );

          expect(result, isA<SuccessState<bool>>());
          expect((result as SuccessState<bool>).data, true);

          final check = await dataSource.getPauseRequests(
            tRequestModel.workOrderId,
          );
          final updated =
              (check as SuccessState<List<PauseRequestModel>>).data!.first;
          expect(updated.resumedAt?.year, resumedAt.year);
          expect(updated.resumedById, userId);

          final wo = await (database.select(
            database.workOrders,
          )..where((t) => t.id.equals(tRequestModel.workOrderId))).getSingle();
          expect(wo.status, 'in_progress');
        },
      );
    });
  });
}
