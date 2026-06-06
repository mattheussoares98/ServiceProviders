import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/get_work_order_change_requests_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetWorkOrderChangeRequestsUseCase useCase;
  late MockWorkOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkOrdersRepository();
    useCase = GetWorkOrderChangeRequestsUseCase(workOrdersRepository: mockRepository);
  });

  final tCompanyId = TestFactory.makeWorkOrderChangeRequestEntity().companyId;
  final tRequests = TestFactory.makeWorkOrderChangeRequestEntityList();

  test('should return a list of pending change requests on success', () async {
    // Arrange
    when(() => mockRepository.getChangeRequests(any()))
        .thenAnswer((_) async => SuccessState(data: tRequests));

    // Act
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<SuccessState<List<WorkOrderChangeRequestEntity>>>());
    expect(result.data, tRequests);
    verify(() => mockRepository.getChangeRequests(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.getChangeRequests(any())).thenAnswer(
      (_) async =>
          FailureState<List<WorkOrderChangeRequestEntity>>(message: 'Load failed'),
    );

    // Act
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<FailureState<List<WorkOrderChangeRequestEntity>>>());
    expect(result.message, 'Load failed');
    verify(() => mockRepository.getChangeRequests(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
