import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/attachments/domain/entities/attachment_entity.dart';
import 'package:clean_architecture/features/attachments/domain/use_cases/create_attachment_use_case.dart';
import 'package:clean_architecture/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:clean_architecture/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockAttachmentsRepository mockRepository;

  // Use cases
  late CreateAttachmentUseCase createAttachmentUseCase;
  late DeleteAttachmentUseCase deleteAttachmentUseCase;
  late GetAttachmentsUseCase getAttachmentsUseCase;

  setUpAll(() {
    registerFallbackValue(TestFactory.makeAttachmentEntity());
  });

  setUp(() {
    mockRepository = MockAttachmentsRepository();
    createAttachmentUseCase = CreateAttachmentUseCase(attachmentsRepository: mockRepository);
    deleteAttachmentUseCase = DeleteAttachmentUseCase(attachmentsRepository: mockRepository);
    getAttachmentsUseCase = GetAttachmentsUseCase(attachmentsRepository: mockRepository);
  });

  final tAttachment = TestFactory.makeAttachmentEntity();
  final tAttachments = [
    TestFactory.makeAttachmentEntity(),
    TestFactory.makeAttachmentEntity(),
    TestFactory.makeAttachmentEntity(),
  ];
  final tWorkOrderId = faker.guid.guid();

  group('Attachments Use Cases', () {
    group('CreateAttachmentUseCase', () {
      test('should call repository.createAttachment and return true on success', () async {
        // Arrange
        when(() => mockRepository.createAttachment(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await createAttachmentUseCase(tAttachment);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRepository.createAttachment(tAttachment)).called(1);
      });

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.createAttachment(any()))
            .thenAnswer((_) async => FailureState<bool>(message: 'Create failed'));

        // Act
        final result = await createAttachmentUseCase(tAttachment);

        // Assert
        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Create failed');
        verify(() => mockRepository.createAttachment(tAttachment)).called(1);
      });
    });

    group('DeleteAttachmentUseCase', () {
      test('should call repository.deleteAttachment and return true on success', () async {
        // Arrange
        when(() => mockRepository.deleteAttachment(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await deleteAttachmentUseCase(tAttachment.id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRepository.deleteAttachment(tAttachment.id)).called(1);
      });

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.deleteAttachment(any()))
            .thenAnswer((_) async => FailureState<bool>(message: 'Delete failed'));

        // Act
        final result = await deleteAttachmentUseCase(tAttachment.id);

        // Assert
        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Delete failed');
        verify(() => mockRepository.deleteAttachment(tAttachment.id)).called(1);
      });
    });

    group('GetAttachmentsUseCase', () {
      test('should call repository.getAttachments and return list of attachments on success', () async {
        // Arrange
        when(() => mockRepository.getAttachmentsByWorkOrder(any()))
            .thenAnswer((_) async => SuccessState(data: tAttachments));

        // Act
        final result = await getAttachmentsUseCase(tWorkOrderId);

        // Assert
        expect(result.data, tAttachments);
        expect(result, SuccessState(data: tAttachments));
        verify(() => mockRepository.getAttachmentsByWorkOrder(tWorkOrderId)).called(1);
      });

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getAttachmentsByWorkOrder(any()))
            .thenAnswer((_) async => FailureState<List<AttachmentEntity>>(message: 'Load failed'));

        // Act
        final result = await getAttachmentsUseCase(tWorkOrderId);

        // Assert
        expect(result, isA<FailureState<List<AttachmentEntity>>>());
        expect(result.message, 'Load failed');
        verify(() => mockRepository.getAttachmentsByWorkOrder(tWorkOrderId)).called(1);
      });
    });
  });
}
