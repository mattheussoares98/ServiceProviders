import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/interval_unit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/calculate_next_due_date_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/create_maintenance_plan_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/delete_maintenance_plan_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/get_maintenance_plan_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/get_maintenance_plans_use_case.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/use_cases/update_maintenance_plan_use_case.dart';

import '../../../../../testing/mocks/factories/maintenance_plan_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetMaintenancePlansUseCase getPlansUseCase;
  late GetMaintenancePlanByIdUseCase getPlanByIdUseCase;
  late CreateMaintenancePlanUseCase createPlanUseCase;
  late UpdateMaintenancePlanUseCase updatePlanUseCase;
  late DeleteMaintenancePlanUseCase deletePlanUseCase;
  late CalculateNextDueDateUseCase calculateNextDueDateUseCase;
  late MockMaintenancePlansRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(MaintenancePlanFactory.makeMaintenancePlanEntity());
  });

  setUp(() {
    mockRepository = MockMaintenancePlansRepository();
    getPlansUseCase = GetMaintenancePlansUseCase(
      maintenancePlansRepository: mockRepository,
    );
    getPlanByIdUseCase = GetMaintenancePlanByIdUseCase(
      repository: mockRepository,
    );
    createPlanUseCase = CreateMaintenancePlanUseCase(
      repository: mockRepository,
    );
    updatePlanUseCase = UpdateMaintenancePlanUseCase(
      repository: mockRepository,
    );
    deletePlanUseCase = DeleteMaintenancePlanUseCase(
      repository: mockRepository,
    );
    calculateNextDueDateUseCase = const CalculateNextDueDateUseCase();
  });

  final tCompanyId =
      MaintenancePlanFactory.makeMaintenancePlanEntity().companyId;
  final tPlans = MaintenancePlanFactory.makeMaintenancePlanEntityList();
  final tPlan = MaintenancePlanFactory.makeMaintenancePlanEntity();

  group('Maintenance Plans Use Cases', () {
    group('GetMaintenancePlansUseCase', () {
      test('should return a list of maintenance plans on success', () async {
        // Arrange
        when(
          () => mockRepository.getMaintenancePlans(any()),
        ).thenAnswer((_) async => SuccessState(data: tPlans));

        // Act
        final result = await getPlansUseCase(tCompanyId);

        // Assert
        expect(result, isA<SuccessState<List<MaintenancePlanEntity>>>());
        expect(result.data, tPlans);
        verify(() => mockRepository.getMaintenancePlans(tCompanyId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getMaintenancePlans(any())).thenAnswer(
          (_) async =>
              FailureState<List<MaintenancePlanEntity>>(message: 'Load failed'),
        );

        // Act
        final result = await getPlansUseCase(tCompanyId);

        // Assert
        expect(result, isA<FailureState<List<MaintenancePlanEntity>>>());
        expect(result.message, 'Load failed');
        verify(() => mockRepository.getMaintenancePlans(tCompanyId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('GetMaintenancePlanByIdUseCase', () {
      test('should return single maintenance plan on success', () async {
        // Arrange
        final id = faker.guid.guid();
        when(
          () => mockRepository.getMaintenancePlanById(any()),
        ).thenAnswer((_) async => SuccessState(data: tPlan));

        // Act
        final result = await getPlanByIdUseCase(id);

        // Assert
        expect(result, isA<SuccessState<MaintenancePlanEntity>>());
        expect(result.data, tPlan);
        verify(() => mockRepository.getMaintenancePlanById(id)).called(1);
      });
    });

    group('CreateMaintenancePlanUseCase', () {
      test('should return true when creation is successful', () async {
        // Arrange
        when(
          () => mockRepository.createMaintenancePlan(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await createPlanUseCase(tPlan);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.createMaintenancePlan(tPlan)).called(1);
      });
    });

    group('UpdateMaintenancePlanUseCase', () {
      test('should return true when update is successful', () async {
        // Arrange
        when(
          () => mockRepository.updateMaintenancePlan(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await updatePlanUseCase(tPlan);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.updateMaintenancePlan(tPlan)).called(1);
      });
    });

    group('DeleteMaintenancePlanUseCase', () {
      test('should return true when delete is successful', () async {
        // Arrange
        final id = faker.guid.guid();
        when(
          () => mockRepository.deleteMaintenancePlan(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await deletePlanUseCase(id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.deleteMaintenancePlan(id)).called(1);
      });
    });

    group('CalculateNextDueDateUseCase', () {
      test('calculates interval in days accurately', () {
        final base = DateTime.utc(2026, 9);
        final result = calculateNextDueDateUseCase(
          RecurrenceParams(
            baseDate: base,
            intervalValue: 15,
            intervalUnit: IntervalUnit.days,
          ),
        );
        expect(result, DateTime.utc(2026, 9, 16));
      });

      test('calculates interval in weeks accurately', () {
        final base = DateTime.utc(2026, 9); // Tuesday
        final result = calculateNextDueDateUseCase(
          RecurrenceParams(
            baseDate: base,
            intervalValue: 2,
            intervalUnit: IntervalUnit.weeks,
          ),
        );
        expect(result, DateTime.utc(2026, 9, 15));
      });

      test(
        'calculates interval in months clamping to last day of short month',
        () {
          final base = DateTime.utc(2026, 1, 31);
          final result = calculateNextDueDateUseCase(
            RecurrenceParams(
              baseDate: base,
              intervalValue: 1,
              intervalUnit: IntervalUnit.months,
              dayOfMonth: 31,
            ),
          );
          expect(result, DateTime.utc(2026, 2, 28));
        },
      );

      test('calculates interval in years respecting leap years', () {
        final base = DateTime.utc(2024, 2, 29);
        final result = calculateNextDueDateUseCase(
          RecurrenceParams(
            baseDate: base,
            intervalValue: 1,
            intervalUnit: IntervalUnit.years,
            monthOfYear: 2,
            dayOfMonth: 29,
          ),
        );
        expect(result, DateTime.utc(2025, 2, 28));
      });
    });
  });
}
