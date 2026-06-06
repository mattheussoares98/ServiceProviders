import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/change_request_status.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late ReviewWorkOrderChangeRequestUseCase useCase;
  late MockWorkOrdersRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(ChangeRequestStatus.approved);
  });

  setUp(() {
    mockRepository = MockWorkOrdersRepository();
    useCase = ReviewWorkOrderChangeRequestUseCase(
      workOrdersRepository: mockRepository,
    );
  });

  final tParams = ReviewChangeRequestParams(
    id: faker.guid.guid(),
    status: ChangeRequestStatus.approved,
    rejectionReason: faker.lorem.sentence(),
    reviewedById: faker.guid.guid(),
  );

  test('should return true on success', () async {
    // Arrange
    when(
      () => mockRepository.reviewChangeRequest(
        id: any(named: 'id'),
        status: any(named: 'status'),
        rejectionReason: any(named: 'rejectionReason'),
        reviewedById: any(named: 'reviewedById'),
      ),
    ).thenAnswer((_) async => const SuccessState(data: true));

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result, isA<SuccessState<bool>>());
    expect(result.data, true);
    verify(
      () => mockRepository.reviewChangeRequest(
        id: tParams.id,
        status: tParams.status,
        rejectionReason: tParams.rejectionReason,
        reviewedById: tParams.reviewedById,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(
      () => mockRepository.reviewChangeRequest(
        id: any(named: 'id'),
        status: any(named: 'status'),
        rejectionReason: any(named: 'rejectionReason'),
        reviewedById: any(named: 'reviewedById'),
      ),
    ).thenAnswer((_) async => FailureState<bool>(message: 'Review failed'));

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result, isA<FailureState<bool>>());
    expect(result.message, 'Review failed');
    verify(
      () => mockRepository.reviewChangeRequest(
        id: tParams.id,
        status: tParams.status,
        rejectionReason: tParams.rejectionReason,
        reviewedById: tParams.reviewedById,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
