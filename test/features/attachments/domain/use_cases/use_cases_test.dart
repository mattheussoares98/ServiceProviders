import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/create_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_video_thumbnail_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_sandbox_size_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/prune_sandbox_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/clear_local_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/touch_last_accessed_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../testing/mocks/services.dart';

void main() {
  late MockAttachmentsRepository mockRepository;
  late MockFileService mockFileService;

  // Use cases
  late CreateAttachmentUseCase createAttachmentUseCase;
  late DeleteAttachmentUseCase deleteAttachmentUseCase;
  late GetAttachmentsUseCase getAttachmentsUseCase;
  late GetVideoThumbnailUseCase getVideoThumbnailUseCase;
  late GetSandboxSizeUseCase getSandboxSizeUseCase;
  late PruneSandboxUseCase pruneSandboxUseCase;
  late ClearLocalAttachmentsUseCase clearLocalAttachmentsUseCase;
  late TouchLastAccessedUseCase touchLastAccessedUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeAttachmentEntity());
  });

  setUp(() {
    mockRepository = MockAttachmentsRepository();
    mockFileService = MockFileService();
    createAttachmentUseCase = CreateAttachmentUseCase(
      attachmentsRepository: mockRepository,
    );
    deleteAttachmentUseCase = DeleteAttachmentUseCase(
      attachmentsRepository: mockRepository,
    );
    getAttachmentsUseCase = GetAttachmentsUseCase(
      attachmentsRepository: mockRepository,
    );
    getVideoThumbnailUseCase = GetVideoThumbnailUseCase(
      fileService: mockFileService,
    );
    getSandboxSizeUseCase = GetSandboxSizeUseCase(
      attachmentsRepository: mockRepository,
    );
    pruneSandboxUseCase = PruneSandboxUseCase(
      attachmentsRepository: mockRepository,
    );
    clearLocalAttachmentsUseCase = ClearLocalAttachmentsUseCase(
      attachmentsRepository: mockRepository,
    );
    touchLastAccessedUseCase = TouchLastAccessedUseCase(
      attachmentsRepository: mockRepository,
    );
  });

  final tAttachment = EntityFactory.makeAttachmentEntity();
  final tAttachments = [
    EntityFactory.makeAttachmentEntity(),
    EntityFactory.makeAttachmentEntity(),
    EntityFactory.makeAttachmentEntity(),
  ];
  final tWorkOrderId = faker.guid.guid();

  group('Attachments Use Cases', () {
    group('CreateAttachmentUseCase', () {
      test(
        'should call repository.createAttachment and return true on success',
        () async {
          // Arrange
          when(
            () => mockRepository.createAttachment(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await createAttachmentUseCase(tAttachment);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, true);
          verify(() => mockRepository.createAttachment(tAttachment)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.createAttachment(any()),
        ).thenAnswer((_) async => FailureState<bool>(message: 'Create failed'));

        // Act
        final result = await createAttachmentUseCase(tAttachment);

        // Assert
        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Create failed');
        verify(() => mockRepository.createAttachment(tAttachment)).called(1);
      });
    });

    group('DeleteAttachmentUseCase', () {
      test(
        'should call repository.deleteAttachment and return true on success',
        () async {
          // Arrange
          when(
            () => mockRepository.deleteAttachment(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await deleteAttachmentUseCase(tAttachment.id);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, true);
          verify(
            () => mockRepository.deleteAttachment(tAttachment.id),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.deleteAttachment(any()),
        ).thenAnswer((_) async => FailureState<bool>(message: 'Delete failed'));

        // Act
        final result = await deleteAttachmentUseCase(tAttachment.id);

        // Assert
        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Delete failed');
        verify(() => mockRepository.deleteAttachment(tAttachment.id)).called(1);
      });
    });

    group('GetAttachmentsUseCase', () {
      test(
        'should call repository.getAttachments and return list of attachments on success',
        () async {
          // Arrange
          when(
            () => mockRepository.getAttachmentsByWorkOrder(any()),
          ).thenAnswer((_) async => SuccessState(data: tAttachments));

          // Act
          final result = await getAttachmentsUseCase(tWorkOrderId);

          // Assert
          expect(result.data, tAttachments);
          expect(result, SuccessState(data: tAttachments));
          verify(
            () => mockRepository.getAttachmentsByWorkOrder(tWorkOrderId),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getAttachmentsByWorkOrder(any())).thenAnswer(
          (_) async =>
              FailureState<List<AttachmentEntity>>(message: 'Load failed'),
        );

        // Act
        final result = await getAttachmentsUseCase(tWorkOrderId);

        // Assert
        expect(result, isA<FailureState<List<AttachmentEntity>>>());
        expect(result.message, 'Load failed');
        verify(
          () => mockRepository.getAttachmentsByWorkOrder(tWorkOrderId),
        ).called(1);
      });
    });

    group('GetVideoThumbnailUseCase', () {
      test(
        'should call fileService.getOrCreateVideoThumbnail and return thumbnail path on success',
        () async {
          final tVideoPath = faker.internet.httpsUrl();
          final tThumbPath = faker.guid.guid();
          when(
            () => mockFileService.getOrCreateVideoThumbnail(any()),
          ).thenAnswer((_) async => SuccessState(data: tThumbPath));

          final result = await getVideoThumbnailUseCase(tVideoPath);

          expect(result, isA<SuccessState<String>>());
          expect(result.data, tThumbPath);
          verify(
            () => mockFileService.getOrCreateVideoThumbnail(tVideoPath),
          ).called(1);
        },
      );

      test('should return FailureState when fileService fails', () async {
        final tVideoPath = faker.internet.httpsUrl();
        when(
          () => mockFileService.getOrCreateVideoThumbnail(any()),
        ).thenAnswer((_) async => FailureState(message: 'Failed to extract'));

        final result = await getVideoThumbnailUseCase(tVideoPath);

        expect(result, isA<FailureState<String>>());
        expect((result as FailureState).message, 'Failed to extract');
        verify(
          () => mockFileService.getOrCreateVideoThumbnail(tVideoPath),
        ).called(1);
      });
    });

    group('GetSandboxSizeUseCase', () {
      test('should call repository.getSandboxSizeBytes and return size', () async {
        when(() => mockRepository.getSandboxSizeBytes())
            .thenAnswer((_) async => const SuccessState(data: 100));

        final result = await getSandboxSizeUseCase();

        expect(result, isA<SuccessState<int>>());
        expect(result.data, 100);
        verify(() => mockRepository.getSandboxSizeBytes()).called(1);
      });
    });

    group('PruneSandboxUseCase', () {
      test('should call repository.pruneSandbox', () async {
        when(() => mockRepository.pruneSandbox())
            .thenAnswer((_) async => SuccessState.nil);

        final result = await pruneSandboxUseCase();

        expect(result, isA<SuccessState<void>>());
        verify(() => mockRepository.pruneSandbox()).called(1);
      });
    });

    group('ClearLocalAttachmentsUseCase', () {
      test('should call repository.clearLocalAttachments', () async {
        when(() => mockRepository.clearLocalAttachments())
            .thenAnswer((_) async => SuccessState.nil);

        final result = await clearLocalAttachmentsUseCase();

        expect(result, isA<SuccessState<void>>());
        verify(() => mockRepository.clearLocalAttachments()).called(1);
      });
    });

    group('TouchLastAccessedUseCase', () {
      test('should call repository.touchLastAccessed', () async {
        final id = faker.guid.guid();
        when(() => mockRepository.touchLastAccessed(id))
            .thenAnswer((_) async => SuccessState.nil);

        final result = await touchLastAccessedUseCase(id);

        expect(result, isA<SuccessState<void>>());
        verify(() => mockRepository.touchLastAccessed(id)).called(1);
      });
    });
  });
}
