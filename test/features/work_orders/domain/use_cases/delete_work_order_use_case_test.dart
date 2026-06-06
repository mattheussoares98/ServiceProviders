import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late DeleteWorkOrderUseCase useCase;
  late MockWorkOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkOrdersRepository();
    useCase = DeleteWorkOrderUseCase(workOrdersRepository: mockRepository);
  });

  final tWorkOrderId = TestFactory.makeWorkOrderEntity().id;

  test('should return true on success', () async {
    // Arrange
    when(() => mockRepository.deleteWorkOrder(any()))
        .thenAnswer((_) async => const SuccessState(data: true));

    // Act
    final result = await useCase(tWorkOrderId);

    // Assert
    expect(result, isA<SuccessState<bool>>());
    expect(result.data, true);
    verify(() => mockRepository.deleteWorkOrder(tWorkOrderId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.deleteWorkOrder(any())).thenAnswer(
      (_) async => FailureState<bool>(message: 'Delete failed'),
    );

    // Act
    final result = await useCase(tWorkOrderId);

    // Assert
    expect(result, isA<FailureState<bool>>());
    expect(result.message, 'Delete failed');
    verify(() => mockRepository.deleteWorkOrder(tWorkOrderId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
