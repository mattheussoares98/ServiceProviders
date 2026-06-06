import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetWorkOrdersUseCase useCase;
  late MockWorkOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkOrdersRepository();
    useCase = GetWorkOrdersUseCase(workOrdersRepository: mockRepository);
  });

  final tCompanyId = TestFactory.makeWorkOrderEntity().companyId;
  final tWorkOrders = TestFactory.makeWorkOrderEntityList();

  test('should return a list of work orders on success', () async {
    // Arrange
    when(() => mockRepository.getWorkOrders(any()))
        .thenAnswer((_) async => SuccessState(data: tWorkOrders));

    // Act
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<SuccessState<List<WorkOrderEntity>>>());
    expect(result.data, tWorkOrders);
    verify(() => mockRepository.getWorkOrders(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.getWorkOrders(any())).thenAnswer(
      (_) async =>
          FailureState<List<WorkOrderEntity>>(message: 'Load failed'),
    );

    // Act
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<FailureState<List<WorkOrderEntity>>>());
    expect(result.message, 'Load failed');
    verify(() => mockRepository.getWorkOrders(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
