import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/use_cases/get_maintenance_plans_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetMaintenancePlansUseCase useCase;
  late MockMaintenancePlansRepository mockRepository;

  setUp(() {
    mockRepository = MockMaintenancePlansRepository();
    useCase = GetMaintenancePlansUseCase(maintenancePlansRepository: mockRepository);
  });

  final tCompanyId = TestFactory.makeMaintenancePlanEntity().companyId;
  final tPlans = TestFactory.makeMaintenancePlanEntityList();

  test('should return a list of maintenance plans on success', () async {
    // Arrange
    when(() => mockRepository.getMaintenancePlans(any()))
        .thenAnswer((_) async => SuccessState(data: tPlans));

    // Act
    final result = await useCase(tCompanyId);

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
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<FailureState<List<MaintenancePlanEntity>>>());
    expect(result.message, 'Load failed');
    verify(() => mockRepository.getMaintenancePlans(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
