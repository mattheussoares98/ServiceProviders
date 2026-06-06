import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late CreateWorkOrderChangeRequestUseCase useCase;
  late MockWorkOrdersRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(TestFactory.makeWorkOrderChangeRequestEntity());
  });

  setUp(() {
    mockRepository = MockWorkOrdersRepository();
    useCase = CreateWorkOrderChangeRequestUseCase(workOrdersRepository: mockRepository);
  });

  final tChangeRequest = TestFactory.makeWorkOrderChangeRequestEntity();

  test('should return true on success', () async {
    // Arrange
    when(() => mockRepository.createChangeRequest(any()))
        .thenAnswer((_) async => const SuccessState(data: true));

    // Act
    final result = await useCase(tChangeRequest);

    // Assert
    expect(result, isA<SuccessState<bool>>());
    expect(result.data, true);
    verify(() => mockRepository.createChangeRequest(tChangeRequest)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.createChangeRequest(any())).thenAnswer(
      (_) async => FailureState<bool>(message: 'Create failed'),
    );

    // Act
    final result = await useCase(tChangeRequest);

    // Assert
    expect(result, isA<FailureState<bool>>());
    expect(result.message, 'Create failed');
    verify(() => mockRepository.createChangeRequest(tChangeRequest)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
