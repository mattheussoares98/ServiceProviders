import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/update_work_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late UpdateWorkOrderUseCase useCase;
  late MockWorkOrdersRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(TestFactory.makeWorkOrderEntity());
  });

  setUp(() {
    mockRepository = MockWorkOrdersRepository();
    useCase = UpdateWorkOrderUseCase(workOrdersRepository: mockRepository);
  });

  final tWorkOrder = TestFactory.makeWorkOrderEntity();

  test('should return true on success', () async {
    // Arrange
    when(() => mockRepository.updateWorkOrder(any()))
        .thenAnswer((_) async => const SuccessState(data: true));

    // Act
    final result = await useCase(tWorkOrder);

    // Assert
    expect(result, isA<SuccessState<bool>>());
    expect(result.data, true);
    verify(() => mockRepository.updateWorkOrder(tWorkOrder)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.updateWorkOrder(any())).thenAnswer(
      (_) async => FailureState<bool>(message: 'Update failed'),
    );

    // Act
    final result = await useCase(tWorkOrder);

    // Assert
    expect(result, isA<FailureState<bool>>());
    expect(result.message, 'Update failed');
    verify(() => mockRepository.updateWorkOrder(tWorkOrder)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
