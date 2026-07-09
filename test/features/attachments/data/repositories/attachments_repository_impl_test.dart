import 'dart:io';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:o_jogo_da_obra/features/attachments/data/repositories/attachments_repository_impl.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/services.dart';

class MockFile extends Mock implements File {}

void main() {
  late MockInternetClient mockInternet;
  late MockAttachmentsRemoteDataSource mockRemoteDataSource;
  late MockAttachmentsLocalDataSource mockLocalDataSource;
  late AttachmentsRepositoryImpl repository;
  late MockFileService fileService;
  late MockStorageClient storageClient;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeAttachmentEntity());
    registerFallbackValue(
      AttachmentResponseModel.fromEntity(EntityFactory.makeAttachmentEntity()),
    );
  });

  setUp(() {
    mockInternet = MockInternetClient();
    mockRemoteDataSource = MockAttachmentsRemoteDataSource();
    mockLocalDataSource = MockAttachmentsLocalDataSource();
    fileService = MockFileService();
    storageClient = MockStorageClient();
    repository = AttachmentsRepositoryImpl(
      internet: mockInternet,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      fileService: fileService,
      storageClient: storageClient,
    );
    when(() => fileService.resolveSandboxPath(any())).thenAnswer(
      (inv) async {
        final path = inv.positionalArguments[0] as String?;
        if (path == null) return null;
        return '/sandbox/$path';
      },
    );
  });

  final tAttachmentEntity = EntityFactory.makeAttachmentEntity();
  final tAttachmentModel = AttachmentResponseModel.fromEntity(
    tAttachmentEntity,
  );
  final tAttachmentEntityList = EntityFactory.makeAttachmentEntityList();
  final tAttachmentModelList = tAttachmentEntityList
      .map(AttachmentResponseModel.fromEntity)
      .toList();

  group('AttachmentsRepositoryImpl - CRUD', () {
    test(
      'getAttachmentsByWorkOrder should return list of attachments from local data source and not sync when offline',
      () async {
        // Arrange
        final workOrderId = faker.guid.guid();
        when(() => mockInternet.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.getAttachmentsByWorkOrder(any()),
        ).thenAnswer((_) async => SuccessState(data: tAttachmentModelList));

        // Act
        final result = await repository.getAttachmentsByWorkOrder(workOrderId);

        // Assert
        expect(result, isA<SuccessState<List<AttachmentEntity>>>());
        expect(result.data, equals(tAttachmentEntityList));
        verify(
          () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).called(1);
        verifyNever(
          () => mockRemoteDataSource.getAttachmentsByWorkOrder(any()),
        );
      },
    );

    test(
      'getAttachmentsByWorkOrder should sync remote attachments into local database when online',
      () async {
        // Arrange
        final workOrderId = faker.guid.guid();
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getAttachmentsByWorkOrder(any()),
        ).thenAnswer((_) async => SuccessState(data: tAttachmentModelList));
        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.getAttachmentsByWorkOrder(any()),
        ).thenAnswer((_) async => SuccessState(data: tAttachmentModelList));

        // Act
        final result = await repository.getAttachmentsByWorkOrder(workOrderId);

        // Assert
        expect(result, isA<SuccessState<List<AttachmentEntity>>>());
        expect(result.data, equals(tAttachmentEntityList));
        verify(
          () => mockRemoteDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).called(1);
        verify(
          () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).called(1);
        for (final model in tAttachmentModelList) {
          verify(() => mockLocalDataSource.saveAttachment(model)).called(1);
        }
      },
    );

    test(
      'createAttachment should return true when local save is successful',
      () async {
        // Arrange
        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.createAttachment(tAttachmentEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(
          () => mockLocalDataSource.saveAttachment(tAttachmentModel),
        ).called(1);
      },
    );

    test(
      'deleteAttachment should delete locally and skip remote call when attachment is not uploaded',
      () async {
        // Arrange
        final id = faker.guid.guid();
        final Set<UploadStatus> statuses = UploadStatus.values
            .where((e) => e != UploadStatus.uploaded)
            .toSet();
        final status = statuses.elementAt(
          faker.randomGenerator.integer(statuses.length),
        );
        final localAttachment = AttachmentResponseModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            id: id,
            uploadStatus: status,
          ),
        );
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.getAttachment(id),
        ).thenAnswer((_) async => SuccessState(data: localAttachment));
        when(
          () => mockLocalDataSource.deleteAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.deleteAttachment(id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.getAttachment(id)).called(1);
        verify(() => mockLocalDataSource.deleteAttachment(id)).called(1);
        verifyNever(() => mockRemoteDataSource.deleteAttachment(any()));
      },
    );

    test(
      'deleteAttachment should delete remote and local when online and attachment is uploaded',
      () async {
        // Arrange
        final id = faker.guid.guid();
        final localAttachment = AttachmentResponseModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            id: id,
            uploadStatus: UploadStatus.uploaded,
          ),
        );
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.getAttachment(id),
        ).thenAnswer((_) async => SuccessState(data: localAttachment));
        when(
          () => mockRemoteDataSource.deleteAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.deleteAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.deleteAttachment(id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.getAttachment(id)).called(1);
        verify(() => mockRemoteDataSource.deleteAttachment(id)).called(1);
        verify(() => mockLocalDataSource.deleteAttachment(id)).called(1);
      },
    );

    test(
      'deleteAttachment should delete only locally when offline and attachment is uploaded',
      () async {
        // Arrange
        final id = faker.guid.guid();
        final localAttachment = AttachmentResponseModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            id: id,
            uploadStatus: UploadStatus.uploaded,
          ),
        );
        when(() => mockInternet.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.getAttachment(id),
        ).thenAnswer((_) async => SuccessState(data: localAttachment));
        when(
          () => mockLocalDataSource.deleteAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.deleteAttachment(id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.getAttachment(id)).called(1);
        verify(() => mockLocalDataSource.deleteAttachment(id)).called(1);
        verifyNever(() => mockRemoteDataSource.deleteAttachment(any()));
      },
    );

    test(
      'deleteAttachment should return FailureState when online, attachment is uploaded, and remote delete fails',
      () async {
        // Arrange
        final id = faker.guid.guid();
        final localAttachment = AttachmentResponseModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            id: id,
            uploadStatus: UploadStatus.uploaded,
          ),
        );
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.getAttachment(id),
        ).thenAnswer((_) async => SuccessState(data: localAttachment));
        when(() => mockRemoteDataSource.deleteAttachment(any())).thenAnswer(
          (_) async => FailureState(message: 'Remote delete failed'),
        );

        // Act
        final result = await repository.deleteAttachment(id);

        // Assert
        expect(result, isA<FailureState<bool>>());
        verify(() => mockLocalDataSource.getAttachment(id)).called(1);
        verify(() => mockRemoteDataSource.deleteAttachment(id)).called(1);
        verifyNever(() => mockLocalDataSource.deleteAttachment(any()));
      },
    );
  });

  group('pickAndPrepareAttachment', () {
    final workOrderId = faker.guid.guid();
    final companyId = faker.guid.guid();
    final uploadedById = faker.guid.guid();
    final mockPath = '/temp/${faker.guid.guid()}.jpg';

    test(
      'should return empty list when source returns null/empty picked path',
      () async {
        when(() => fileService.takePhoto()).thenAnswer((_) async => null);

        final result = await repository.pickAndPrepareAttachment(
          source: AttachmentSource.cameraPhoto,
          workOrderId: workOrderId,
          companyId: companyId,
          uploadedById: uploadedById,
        );

        expect(result, isA<SuccessState<List<AttachmentEntity>>>());
        expect(result.data, isEmpty);
      },
    );

    test(
      'should return FailureState when file extension validation fails',
      () async {
        final invalidPath = '/temp/${faker.guid.guid()}.invalid';
        when(
          () => fileService.takePhoto(),
        ).thenAnswer((_) async => invalidPath);
        when(
          () => fileService.getFileSizeBytes(any()),
        ).thenAnswer((_) async => 1024);

        final result = await repository.pickAndPrepareAttachment(
          source: AttachmentSource.cameraPhoto,
          workOrderId: workOrderId,
          companyId: companyId,
          uploadedById: uploadedById,
        );

        expect(result, isA<FailureState<List<AttachmentEntity>>>());
        expect(
          (result as FailureState).message,
          contains('Tipo de arquivo não suportado'),
        );
      },
    );

    test(
      'should return FailureState when file size validation fails',
      () async {
        when(() => fileService.takePhoto()).thenAnswer((_) async => mockPath);
        // Let's return 30MB for an image (max is 20MB)
        when(
          () => fileService.getFileSizeBytes(any()),
        ).thenAnswer((_) async => 30 * 1024 * 1024);

        final result = await repository.pickAndPrepareAttachment(
          source: AttachmentSource.cameraPhoto,
          workOrderId: workOrderId,
          companyId: companyId,
          uploadedById: uploadedById,
        );

        expect(result, isA<FailureState<List<AttachmentEntity>>>());
        expect(
          (result as FailureState).message,
          contains('Arquivo muito grande'),
        );
      },
    );

    test(
      'should successfully compress, copy, and save image to local when offline',
      () async {
        when(() => mockInternet.isConnected).thenReturn(false);
        when(() => fileService.takePhoto()).thenAnswer((_) async => mockPath);
        when(
          () => fileService.getFileSizeBytes(mockPath),
        ).thenAnswer((_) async => 5 * 1024 * 1024);

        final sandboxPath = '/sandbox/${faker.guid.guid()}.webp';
        when(
          () => fileService.compressAndSaveImage(mockPath),
        ).thenAnswer((_) async => SuccessState(data: sandboxPath));
        when(
          () => fileService.getFileSizeBytes(sandboxPath),
        ).thenAnswer((_) async => 500 * 1024);

        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.pickAndPrepareAttachment(
          source: AttachmentSource.cameraPhoto,
          workOrderId: workOrderId,
          companyId: companyId,
          uploadedById: uploadedById,
        );

        expect(result, isA<SuccessState<List<AttachmentEntity>>>());
        expect(result.data!.length, 1);
        final entity = result.data!.first;
        expect(entity.localPath, sandboxPath);
        expect(entity.fileSizeBytes, 500 * 1024);
        expect(entity.uploadStatus, UploadStatus.pending);
        expect(entity.isCompressed, isTrue);

        verify(() => fileService.compressAndSaveImage(mockPath)).called(1);
        verify(() => mockLocalDataSource.saveAttachment(any())).called(1);
      },
    );

    test(
      'should only save locally as pending when online (no auto-upload)',
      () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(() => fileService.takePhoto()).thenAnswer((_) async => mockPath);
        when(
          () => fileService.getFileSizeBytes(mockPath),
        ).thenAnswer((_) async => 5 * 1024 * 1024);

        final sandboxPath = '${Directory.systemTemp.path}/test_sandbox.webp';
        when(
          () => fileService.compressAndSaveImage(mockPath),
        ).thenAnswer((_) async => SuccessState(data: sandboxPath));
        when(
          () => fileService.getFileSizeBytes(sandboxPath),
        ).thenAnswer((_) async => 500 * 1024);

        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.pickAndPrepareAttachment(
          source: AttachmentSource.cameraPhoto,
          workOrderId: workOrderId,
          companyId: companyId,
          uploadedById: uploadedById,
        );

        expect(result, isA<SuccessState<List<AttachmentEntity>>>());
        expect(result.data!.length, 1);
        final entity = result.data!.first;
        expect(entity.uploadStatus, UploadStatus.pending);

        verifyNever(() => mockRemoteDataSource.getPresignedUploadUrl(any()));
        verifyNever(() => storageClient.uploadFile(
              presignedUrl: any(named: 'presignedUrl'),
              filePath: any(named: 'filePath'),
              mimeType: any(named: 'mimeType'),
            ));
        verifyNever(() => mockRemoteDataSource.confirmUpload(any()));
      },
    );
  });

  group('uploadPendingAttachment', () {
    final mockEntity = EntityFactory.makeAttachmentEntity().copyWith(
      localPath: '${Directory.systemTemp.path}/local_file.jpg',
    );

    test('should return FailureState when local file does not exist', () async {
      final nonExistentEntity = mockEntity.copyWith(
        localPath: '/does/not/exist.jpg',
      );
      final result = await repository.uploadPendingAttachment(
        nonExistentEntity,
      );

      expect(result, isA<FailureState<bool>>());
      expect(
        (result as FailureState).message,
        contains('Arquivo local não encontrado'),
      );
    });

    test(
      'should successfully request presigned URL, upload, confirm and save locally',
      () async {
        // Create a dummy file so local checks pass
        final file = File(mockEntity.localPath!);
        await file.create(recursive: true);
        addTearDown(() async {
          if (file.existsSync()) await file.delete();
        });

        when(
          () => fileService.getMimeType(mockEntity.localPath!),
        ).thenReturn('image/jpeg');

        const presignedResponse = PresignedUrlResponse(
          uploadUrl: 'http://upload-url',
          fileKey: 'file-key',
          publicUrl: 'http://r2/file.jpg',
        );
        when(
          () => mockRemoteDataSource.getPresignedUploadUrl(any()),
        ).thenAnswer((_) async => const SuccessState(data: presignedResponse));

        const remoteUrl = 'http://r2/file.jpg';
        when(
          () => storageClient.uploadFile(
            presignedUrl: 'http://upload-url',
            filePath: mockEntity.localPath!,
            mimeType: 'image/jpeg',
          ),
        ).thenAnswer((_) async => const SuccessState(data: remoteUrl));

        when(
          () => mockRemoteDataSource.confirmUpload(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.uploadPendingAttachment(mockEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);

        verify(
          () => mockRemoteDataSource.getPresignedUploadUrl(any()),
        ).called(1);
        verify(
          () => storageClient.uploadFile(
            presignedUrl: 'http://upload-url',
            filePath: mockEntity.localPath!,
            mimeType: 'image/jpeg',
          ),
        ).called(1);
        verify(() => mockRemoteDataSource.confirmUpload(any())).called(1);
        verify(() => mockLocalDataSource.saveAttachment(any())).called(1);
      },
    );

    test(
      'should return FailureState when getting presigned URL fails',
      () async {
        final file = File(mockEntity.localPath!);
        await file.create(recursive: true);
        addTearDown(() async {
          if (file.existsSync()) await file.delete();
        });

        when(
          () => fileService.getMimeType(mockEntity.localPath!),
        ).thenReturn('image/jpeg');
        when(
          () => mockRemoteDataSource.getPresignedUploadUrl(any()),
        ).thenAnswer(
          (_) async => FailureState(message: 'Error generating URL'),
        );

        final result = await repository.uploadPendingAttachment(mockEntity);

        expect(result, isA<FailureState<bool>>());
        expect((result as FailureState).message, 'Error generating URL');
      },
    );

    test('should return FailureState when uploading file fails', () async {
      final file = File(mockEntity.localPath!);
      await file.create(recursive: true);
      addTearDown(() async {
        if (file.existsSync()) await file.delete();
      });

      when(
        () => fileService.getMimeType(mockEntity.localPath!),
      ).thenReturn('image/jpeg');

      const presignedResponse = PresignedUrlResponse(
        uploadUrl: 'http://upload-url',
        fileKey: 'file-key',
        publicUrl: 'http://public-url',
      );
      when(
        () => mockRemoteDataSource.getPresignedUploadUrl(any()),
      ).thenAnswer((_) async => const SuccessState(data: presignedResponse));

      when(
        () => storageClient.uploadFile(
          presignedUrl: 'http://upload-url',
          filePath: mockEntity.localPath!,
          mimeType: 'image/jpeg',
        ),
      ).thenAnswer((_) async => FailureState(message: 'Upload failed'));

      final result = await repository.uploadPendingAttachment(mockEntity);

      expect(result, isA<FailureState<bool>>());
      expect((result as FailureState).message, 'Upload failed');
    });

    test('should return FailureState when confirmation fails', () async {
      final file = File(mockEntity.localPath!);
      await file.create(recursive: true);
      addTearDown(() async {
        if (file.existsSync()) await file.delete();
      });

      when(
        () => fileService.getMimeType(mockEntity.localPath!),
      ).thenReturn('image/jpeg');

      const presignedResponse = PresignedUrlResponse(
        uploadUrl: 'http://upload-url',
        fileKey: 'file-key',
        publicUrl: 'http://public-url',
      );
      when(
        () => mockRemoteDataSource.getPresignedUploadUrl(any()),
      ).thenAnswer((_) async => const SuccessState(data: presignedResponse));

      const remoteUrl = 'http://r2/file.jpg';
      when(
        () => storageClient.uploadFile(
          presignedUrl: 'http://upload-url',
          filePath: mockEntity.localPath!,
          mimeType: 'image/jpeg',
        ),
      ).thenAnswer((_) async => const SuccessState(data: remoteUrl));
      when(
        () => mockRemoteDataSource.confirmUpload(any()),
      ).thenAnswer((_) async => FailureState(message: 'Confirmation failed'));

      final result = await repository.uploadPendingAttachment(mockEntity);

      expect(result, isA<FailureState<bool>>());
      expect((result as FailureState).message, 'Confirmation failed');
    });
  });
}
