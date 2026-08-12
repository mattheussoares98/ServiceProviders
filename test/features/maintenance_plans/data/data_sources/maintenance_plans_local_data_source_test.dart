import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/data_sources/maintenance_plans_local_data_source.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/models/responses/maintenance_plan_model.dart';

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

  final tPlanEntity = EntityFactory.makeMaintenancePlanEntity();
  final tPlanModel = MaintenancePlanModel.fromEntity(tPlanEntity);

  group('MaintenancePlansLocalDataSourceImpl', () {
    test(
      'should save a maintenance plan and successfully retrieve it',
      () async {
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
        expect(getResult, isA<SuccessState<List<MaintenancePlanModel>>>());
        expect(getResult.data, hasLength(1));
        expect(getResult.data!.first, equals(tPlanModel));

        // Act: Get single by id
        final getSingleResult = await dataSource.getPlanById(tPlanModel.id);

        // Assert Get Single
        expect(getSingleResult, isA<SuccessState<MaintenancePlanModel>>());
        expect(getSingleResult.data, equals(tPlanModel));
      },
    );

    test('should return FailureState when getting non-existent plan', () async {
      // Act
      final result = await dataSource.getPlanById(faker.guid.guid());

      // Assert
      expect(result, isA<FailureState<MaintenancePlanModel>>());
    });

    test(
      'should soft-delete a maintenance plan and verify it is not returned',
      () async {
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
        expect(getResult, isA<SuccessState<List<MaintenancePlanModel>>>());
        expect(getResult.data, isEmpty);

        // Act: Get Single
        final getSingleResult = await dataSource.getPlanById(tPlanModel.id);

        // Assert Get Single: Should be failure
        expect(getSingleResult, isA<FailureState<MaintenancePlanModel>>());
      },
    );
  });
}
