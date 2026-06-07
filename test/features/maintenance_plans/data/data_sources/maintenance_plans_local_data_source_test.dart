import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/maintenance_plans/data/data_sources/maintenance_plans_local_data_source.dart';
import 'package:clean_architecture/features/maintenance_plans/data/models/responses/maintenance_plan_response_model.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late MaintenancePlansLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = MaintenancePlansLocalDataSourceImpl(database: database);
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

  final tPlanEntity = EntityFactory.makeMaintenancePlanEntity();
  final tPlanModel = MaintenancePlanResponseModel.fromEntity(tPlanEntity);

  group('MaintenancePlansLocalDataSourceImpl', () {
    test('should save a maintenance plan and successfully retrieve it', () async {
      // Arrange
      await insertTestCompany(tPlanModel.companyId);

      // Act: Save
      final saveResult = await dataSource.savePlan(tPlanModel);

      // Assert Save
      expect(saveResult, isA<SuccessState<bool>>());
      expect(saveResult.data, isTrue);

      // Act: Get plans
      final getResult = await dataSource.getPlans(tPlanModel.companyId);

      // Assert Get List
      expect(getResult, isA<SuccessState<List<MaintenancePlanResponseModel>>>());
      expect(getResult.data, hasLength(1));
      final resultModel = getResult.data!.first;
      expect(resultModel.id, tPlanModel.id);
      expect(resultModel.companyId, tPlanModel.companyId);
      expect(resultModel.title, tPlanModel.title);
      expect(resultModel.description, tPlanModel.description);
      expect(resultModel.frequency, tPlanModel.frequency);
      expect(resultModel.priority, tPlanModel.priority);
      expect(resultModel.isActive, tPlanModel.isActive);

      // Act: Get single by id
      final getSingleResult = await dataSource.getPlanById(tPlanModel.id);

      // Assert Get Single
      expect(getSingleResult, isA<SuccessState<MaintenancePlanResponseModel>>());
      expect(getSingleResult.data!.id, tPlanModel.id);
    });

    test('should return FailureState when getting non-existent plan', () async {
      // Act
      final result = await dataSource.getPlanById(faker.guid.guid());

      // Assert
      expect(result, isA<FailureState<MaintenancePlanResponseModel>>());
    });

    test('should soft-delete a maintenance plan and verify it is not returned', () async {
      // Arrange
      await insertTestCompany(tPlanModel.companyId);
      await dataSource.savePlan(tPlanModel);

      // Act: Delete
      final deleteResult = await dataSource.deletePlan(tPlanModel.id);

      // Assert Delete
      expect(deleteResult, isA<SuccessState<bool>>());
      expect(deleteResult.data, isTrue);

      // Act: Get List
      final getResult = await dataSource.getPlans(tPlanModel.companyId);

      // Assert Get: Should be empty
      expect(getResult, isA<SuccessState<List<MaintenancePlanResponseModel>>>());
      expect(getResult.data, isEmpty);

      // Act: Get Single
      final getSingleResult = await dataSource.getPlanById(tPlanModel.id);

      // Assert Get Single: Should be failure
      expect(getSingleResult, isA<FailureState<MaintenancePlanResponseModel>>());
    });
  });
}
