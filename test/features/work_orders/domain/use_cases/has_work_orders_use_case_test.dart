import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/has_work_orders_use_case.dart';

import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockWorkOrdersRepository mockRepository;
  late HasWorkOrdersUseCase useCase;

  setUp(() {
    mockRepository = MockWorkOrdersRepository();
    useCase = HasWorkOrdersUseCase(workOrdersRepository: mockRepository);
  });

  group('HasWorkOrdersUseCase', () {
    test('should call repository.hasNonDeletedWorkOrders and return SuccessState', () async {
      when(() => mockRepository.hasNonDeletedWorkOrders(any())).thenAnswer(
        (_) async => const SuccessState(data: true),
      );

      final result = await useCase('company_123');

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockRepository.hasNonDeletedWorkOrders('company_123')).called(1);
    });

    test('should return FailureState when repository fails', () async {
      when(() => mockRepository.hasNonDeletedWorkOrders(any())).thenAnswer(
        (_) async => FailureState<bool>(message: 'Error'),
      );

      final result = await useCase('company_123');

      expect(result, isA<FailureState<bool>>());
      verify(() => mockRepository.hasNonDeletedWorkOrders('company_123')).called(1);
    });
  });
}
