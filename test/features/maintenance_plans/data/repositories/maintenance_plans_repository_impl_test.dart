import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/models/responses/maintenance_plan_model.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/repositories/maintenance_plans_repository_impl.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternet;
  late MockMaintenancePlansRemoteDataSource mockRemoteDataSource;
  late MockMaintenancePlansLocalDataSource mockLocalDataSource;
  late MaintenancePlansRepositoryImpl repository;

  setUp(() {
    mockInternet = MockInternetClient();
    mockRemoteDataSource = MockMaintenancePlansRemoteDataSource();
    mockLocalDataSource = MockMaintenancePlansLocalDataSource();
    repository = MaintenancePlansRepositoryImpl(
      internet: mockInternet,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );

    registerFallbackValue(
      MaintenancePlanModel.fromEntity(
        EntityFactory.makeMaintenancePlanEntity(),
      ),
    );
  });

  final tPlanEntity = EntityFactory.makeMaintenancePlanEntity();
  final tPlanModel = MaintenancePlanModel.fromEntity(tPlanEntity);
  final tPlanEntityList = EntityFactory.makeMaintenancePlanEntityList();
  final tPlanModelList = tPlanEntityList
      .map(MaintenancePlanModel.fromEntity)
      .toList();

  group('MaintenancePlansRepositoryImpl', () {
    test(
      'getMaintenancePlans should return list of plans from local data source',
      () async {
        // Arrange
        final companyId = faker.guid.guid();
        when(
          () => mockLocalDataSource.getPlans(any()),
        ).thenAnswer((_) async => SuccessState(data: tPlanModelList));

        // Act
        final result = await repository.getMaintenancePlans(companyId);

        // Assert
        expect(result, isA<SuccessState<List<MaintenancePlanEntity>>>());
        expect(result.data, equals(tPlanEntityList));
        verify(() => mockLocalDataSource.getPlans(companyId)).called(1);
      },
    );

    test(
      'getMaintenancePlanById should return single plan from local data source',
      () async {
        // Arrange
        final id = faker.guid.guid();
        when(
          () => mockLocalDataSource.getPlanById(any()),
        ).thenAnswer((_) async => SuccessState(data: tPlanModel));

        // Act
        final result = await repository.getMaintenancePlanById(id);

        // Assert
        expect(result, isA<SuccessState<MaintenancePlanEntity>>());
        expect(result.data, equals(tPlanEntity));
        verify(() => mockLocalDataSource.getPlanById(id)).called(1);
      },
    );

    test(
      'createMaintenancePlan should return true when local save is successful',
      () async {
        // Arrange
        when(
          () => mockLocalDataSource.savePlan(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.createMaintenancePlan(tPlanEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.savePlan(tPlanModel)).called(1);
      },
    );

    test(
      'updateMaintenancePlan should return true when local save is successful',
      () async {
        // Arrange
        when(
          () => mockLocalDataSource.savePlan(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.updateMaintenancePlan(tPlanEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.savePlan(tPlanModel)).called(1);
      },
    );

    test(
      'deleteMaintenancePlan should return true when local delete is successful',
      () async {
        // Arrange
        final id = faker.guid.guid();
        when(
          () => mockLocalDataSource.deletePlan(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.deleteMaintenancePlan(id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.deletePlan(id)).called(1);
      },
    );
  });
}
