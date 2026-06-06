import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late DeleteAttachmentUseCase useCase;
  late MockAttachmentsRepository mockRepository;

  setUp(() {
    mockRepository = MockAttachmentsRepository();
    useCase = DeleteAttachmentUseCase(attachmentsRepository: mockRepository);
    registerFallbackValue(TestFactory.makeAttachmentEntity());
  });

  final tAttachmentId = TestFactory.makeAttachmentEntity().id;

  test(
    'should call repository.deleteAttachment and return true on success',
    () async {
      // Arrange
      when(
        () => mockRepository.deleteAttachment(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await useCase.call(tAttachmentId);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockRepository.deleteAttachment(tAttachmentId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(
      () => mockRepository.deleteAttachment(any()),
    ).thenAnswer((_) async => FailureState<bool>(message: 'Create failed'));

    // Act
    final result = await useCase(tAttachmentId);

    // Assert
    expect(result, isA<FailureState<bool>>());
    expect(result.message, 'Create failed');
    verify(() => mockRepository.deleteAttachment(tAttachmentId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
