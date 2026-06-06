import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetWorkOrderHistoryUseCase useCase;
  late MockWorkOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkOrdersRepository();
    useCase = GetWorkOrderHistoryUseCase(workOrdersRepository: mockRepository);
  });

  final tWorkOrderId = TestFactory.makeWorkOrderEntity().id;
  final tHistory = TestFactory.makeWorkOrderHistoryEntityList();

  test('should return a list of work order history on success', () async {
    // Arrange
    when(() => mockRepository.getWorkOrderHistory(any()))
        .thenAnswer((_) async => SuccessState(data: tHistory));

    // Act
    final result = await useCase(tWorkOrderId);

    // Assert
    expect(result, isA<SuccessState<List<WorkOrderHistoryEntity>>>());
    expect(result.data, tHistory);
    verify(() => mockRepository.getWorkOrderHistory(tWorkOrderId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.getWorkOrderHistory(any())).thenAnswer(
      (_) async =>
          FailureState<List<WorkOrderHistoryEntity>>(message: 'Load failed'),
    );

    // Act
    final result = await useCase(tWorkOrderId);

    // Assert
    expect(result, isA<FailureState<List<WorkOrderHistoryEntity>>>());
    expect(result.message, 'Load failed');
    verify(() => mockRepository.getWorkOrderHistory(tWorkOrderId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
