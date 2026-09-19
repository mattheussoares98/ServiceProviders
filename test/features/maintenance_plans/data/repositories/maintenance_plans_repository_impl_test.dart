import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/models/responses/maintenance_plan_model.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/repositories/maintenance_plans_repository_impl.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/factories/maintenance_plan_factory.dart';

void main() {
  late MockInternetClient mockInternet;
  late MockMaintenancePlansRemoteDataSource mockRemoteDataSource;
  late MockMaintenancePlansLocalDataSource mockLocalDataSource;
  late MaintenancePlansRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      MaintenancePlanModel.fromEntity(
        MaintenancePlanFactory.makeMaintenancePlanEntity(),
      ),
    );
  });

  setUp(() {
    mockInternet = MockInternetClient();
    mockRemoteDataSource = MockMaintenancePlansRemoteDataSource();
    mockLocalDataSource = MockMaintenancePlansLocalDataSource();
    repository = MaintenancePlansRepositoryImpl(
      internet: mockInternet,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tPlanEntity = MaintenancePlanFactory.makeMaintenancePlanEntity();
  final tPlanModel = MaintenancePlanModel.fromEntity(tPlanEntity);
  final tPlanEntityList =
      MaintenancePlanFactory.makeMaintenancePlanEntityList();
  final tPlanModelList = tPlanEntityList
      .map(MaintenancePlanModel.fromEntity)
      .toList();

  group('MaintenancePlansRepositoryImpl', () {
    group('getMaintenancePlans', () {
      test('fetches from remote and mirrors locally when online', () async {
        final companyId = faker.guid.guid();
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getPlans(any()),
        ).thenAnswer((_) async => SuccessState(data: tPlanModelList));
        when(
          () => mockLocalDataSource.savePlans(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getMaintenancePlans(companyId);

        expect(result, isA<SuccessState<List<MaintenancePlanEntity>>>());
        expect(result.data, equals(tPlanEntityList));
        verify(() => mockRemoteDataSource.getPlans(companyId)).called(1);
        verify(() => mockLocalDataSource.savePlans(tPlanModelList)).called(1);
      });

      test('fetches from local cache when offline', () async {
        final companyId = faker.guid.guid();
        when(() => mockInternet.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.getPlans(any()),
        ).thenAnswer((_) async => SuccessState(data: tPlanModelList));

        final result = await repository.getMaintenancePlans(companyId);

        expect(result, isA<SuccessState<List<MaintenancePlanEntity>>>());
        expect(result.data, equals(tPlanEntityList));
        verify(() => mockLocalDataSource.getPlans(companyId)).called(1);
        verifyNever(() => mockRemoteDataSource.getPlans(any()));
      });
    });

    group('createMaintenancePlan', () {
      test('creates on remote and mirrors locally when online', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.createPlan(any()),
        ).thenAnswer((_) async => SuccessState(data: tPlanModel));
        when(
          () => mockLocalDataSource.savePlan(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createMaintenancePlan(tPlanEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRemoteDataSource.createPlan(any())).called(1);
        verify(() => mockLocalDataSource.savePlan(tPlanModel)).called(1);
      });

      test('fails with offline message when offline', () async {
        when(() => mockInternet.isConnected).thenReturn(false);

        final result = await repository.createMaintenancePlan(tPlanEntity);

        expect(result, isA<FailureState<bool>>());
        verifyNever(() => mockRemoteDataSource.createPlan(any()));
        verifyNever(() => mockLocalDataSource.savePlan(any()));
      });
    });

    group('updateMaintenancePlan', () {
      test('updates on remote and mirrors locally when online', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.updatePlan(any()),
        ).thenAnswer((_) async => SuccessState(data: tPlanModel));
        when(
          () => mockLocalDataSource.savePlan(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.updateMaintenancePlan(tPlanEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRemoteDataSource.updatePlan(any())).called(1);
        verify(() => mockLocalDataSource.savePlan(tPlanModel)).called(1);
      });

      test('fails with offline message when offline', () async {
        when(() => mockInternet.isConnected).thenReturn(false);

        final result = await repository.updateMaintenancePlan(tPlanEntity);

        expect(result, isA<FailureState<bool>>());
        verifyNever(() => mockRemoteDataSource.updatePlan(any()));
      });
    });

    group('deleteMaintenancePlan', () {
      test('deletes on remote and marks locally when online', () async {
        final id = faker.guid.guid();
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.deletePlan(any()),
        ).thenAnswer((_) async => SuccessState.nil);
        when(
          () => mockLocalDataSource.deletePlan(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteMaintenancePlan(id);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRemoteDataSource.deletePlan(id)).called(1);
        verify(() => mockLocalDataSource.deletePlan(id)).called(1);
      });

      test('fails with offline message when offline', () async {
        final id = faker.guid.guid();
        when(() => mockInternet.isConnected).thenReturn(false);

        final result = await repository.deleteMaintenancePlan(id);

        expect(result, isA<FailureState<bool>>());
        verifyNever(() => mockRemoteDataSource.deletePlan(any()));
      });
    });
  });
}
