import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/attachments/domain/entities/attachment_entity.dart';
import 'package:clean_architecture/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetAttachmentsUseCase useCase;
  late MockAttachmentsRepository mockRepository;

  setUp(() {
    mockRepository = MockAttachmentsRepository();
    useCase = GetAttachmentsUseCase(attachmentsRepository: mockRepository);
    registerFallbackValue(TestFactory.makeAttachmentEntity());
  });

  final tAttachments = [
    TestFactory.makeAttachmentEntity(),
    TestFactory.makeAttachmentEntity(),
    TestFactory.makeAttachmentEntity(),
  ];

  final workOrderId = faker.guid.guid();

  test(
    'should call repository.getAttachments and return true on success',
    () async {
      // Arrange
      when(
        () => mockRepository.getAttachmentsByWorkOrder(any()),
      ).thenAnswer((_) async => SuccessState(data: tAttachments));

      // Act
      final result = await useCase.call(workOrderId);

      // Assert
      expect(result.data, tAttachments);
      expect(result, SuccessState(data: tAttachments));
      verify(
        () => mockRepository.getAttachmentsByWorkOrder(workOrderId),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.getAttachmentsByWorkOrder(any())).thenAnswer(
      (_) async =>
          FailureState<List<AttachmentEntity>>(message: 'Create failed'),
    );

    // Act
    final result = await useCase(workOrderId);

    // Assert
    expect(result, isA<FailureState<List<AttachmentEntity>>>());
    expect(result.message, 'Create failed');
    verify(
      () => mockRepository.getAttachmentsByWorkOrder(workOrderId),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
