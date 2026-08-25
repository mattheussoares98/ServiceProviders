import 'dart:io';
import 'dart:typed_data';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/constants/local_storage_limits.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_model.dart';
import 'package:o_jogo_da_obra/features/attachments/data/repositories/attachments_repository_impl.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../testing/mocks/services.dart';

class MockFile extends Mock implements File {}

void main() {
  late MockInternetClient mockInternet;
  late MockAttachmentsRemoteDataSource mockRemoteDataSource;
  late MockAttachmentsLocalDataSource mockLocalDataSource;
  late MockSessionRepository mockSessionRepository;
  late MockCompanyRepository mockCompanyRepository;
  late AttachmentsRepositoryImpl repository;
  late MockFileService fileService;
  late MockStorageClient storageClient;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeAttachmentEntity());
    registerFallbackValue(
      AttachmentModel.fromEntity(EntityFactory.makeAttachmentEntity()),
    );
  });

  setUp(() {
    mockInternet = MockInternetClient();
    mockRemoteDataSource = MockAttachmentsRemoteDataSource();
    mockLocalDataSource = MockAttachmentsLocalDataSource();
    mockSessionRepository = MockSessionRepository();
    mockCompanyRepository = MockCompanyRepository();
    fileService = MockFileService();
    storageClient = MockStorageClient();
    when(
      () => mockSessionRepository.getSelectedMode(),
    ).thenReturn(AppMode.internal.name);
    when(
      () => mockSessionRepository.getSelectedCompanyId(),
    ).thenReturn('');
    when(
      () => mockCompanyRepository.getCompanyParameters(any()),
    ).thenAnswer((_) async => FailureState(message: 'none'));

    repository = AttachmentsRepositoryImpl(
      internet: mockInternet,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      fileService: fileService,
      storageClient: storageClient,
      sessionRepository: mockSessionRepository,
      companyRepository: mockCompanyRepository,
    );
    when(() => fileService.resolveSandboxPath(any())).thenAnswer((inv) async {
      final path = inv.positionalArguments[0] as String?;
      if (path == null) return null;
      return '/sandbox/$path';
    });
    when(
      () => fileService.readFileAsBytes(any()),
    ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
    when(() => fileService.fileExists(any())).thenAnswer((_) async => true);
    when(() => mockInternet.isConnected).thenReturn(true);
    when(
      () => mockLocalDataSource.touchLastAccessed(any()),
    ).thenAnswer((_) async => SuccessState.nil);
    when(
      () => mockRemoteDataSource.getAttachmentByHash(
        workOrderId: any(named: 'workOrderId'),
        hash: any(named: 'hash'),
      ),
    ).thenAnswer((_) async => const SuccessState(data: null));
    when(
      () => mockLocalDataSource.getAttachment(any()),
    ).thenAnswer((_) async => const SuccessState(data: null));
  });

  final tAttachmentEntity = EntityFactory.makeAttachmentEntity();
  final tAttachmentModel = AttachmentModel.fromEntity(tAttachmentEntity);
  final tAttachmentEntityList = EntityFactory.makeAttachmentEntityList();
  final tAttachmentModelList = tAttachmentEntityList
      .map(AttachmentModel.fromEntity)
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
        expect(result.data?.length, equals(tAttachmentEntityList.length));
        for (var i = 0; i < (result.data?.length ?? 0); i++) {
          expect(result.data![i].id, tAttachmentEntityList[i].id);
          expect(
            result.data![i].workOrderId,
            tAttachmentEntityList[i].workOrderId,
          );
        }
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
        expect(result.data?.length, equals(tAttachmentEntityList.length));
        for (var i = 0; i < (result.data?.length ?? 0); i++) {
          expect(result.data![i].id, tAttachmentEntityList[i].id);
          expect(
            result.data![i].workOrderId,
            tAttachmentEntityList[i].workOrderId,
          );
        }
        verify(
          () => mockRemoteDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).called(1);
        verify(
          () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).called(2);
        for (final model in tAttachmentModelList) {
          verify(() => mockLocalDataSource.saveAttachment(model)).called(1);
        }
      },
    );

    test(
      'getAttachmentsByWorkOrder should delete local attachments that have been deleted remotely when online',
      () async {
        // Arrange
        final workOrderId = faker.guid.guid();
        final model1 = AttachmentModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            id: faker.guid.guid(),
            workOrderId: workOrderId,
            uploadStatus: UploadStatus.uploaded,
          ),
        );
        final model2 = AttachmentModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            id: faker.guid.guid(),
            workOrderId: workOrderId,
            uploadStatus: UploadStatus.uploaded,
          ),
        );

        when(() => mockInternet.isConnected).thenReturn(true);
        // Remote only returns model1 (meaning model2 was deleted remotely)
        when(
          () => mockRemoteDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).thenAnswer((_) async => SuccessState(data: [model1]));
        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.deleteAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Stub local DB returning both initially, then only model1 after sync/deletion
        int localCallCount = 0;
        when(
          () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).thenAnswer((_) async {
          localCallCount++;
          if (localCallCount == 1) {
            return SuccessState(data: [model1, model2]);
          } else {
            return SuccessState(data: [model1]);
          }
        });

        // Act
        final result = await repository.getAttachmentsByWorkOrder(workOrderId);

        // Assert
        expect(result, isA<SuccessState<List<AttachmentEntity>>>());
        expect(result.data?.length, 1);
        expect(result.data?.first.id, model1.id);

        verify(
          () => mockRemoteDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).called(1);
        verify(
          () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).called(2);
        verify(() => mockLocalDataSource.saveAttachment(model1)).called(1);
        verify(() => mockLocalDataSource.deleteAttachment(model2.id)).called(1);
        verifyNever(() => mockLocalDataSource.deleteAttachment(model1.id));
      },
    );

    test(
      'getAttachmentsByWorkOrder should preserve existing localPath when syncing remote attachments',
      () async {
        // Arrange
        final workOrderId = faker.guid.guid();
        final attachmentId = faker.guid.guid();
        final remoteModel = AttachmentModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            id: attachmentId,
            workOrderId: workOrderId,
            uploadStatus: UploadStatus.uploaded,
            annulLocalPath: true,
          ),
        );
        final existingLocalModel = remoteModel.copyWith(
          localPath: 'local/path/file.jpg',
        );

        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).thenAnswer((_) async => SuccessState(data: [remoteModel]));
        when(() => mockLocalDataSource.getAttachment(attachmentId)).thenAnswer(
          (_) async => SuccessState(
            data: AttachmentModel.fromEntity(existingLocalModel),
          ),
        );
        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
        ).thenAnswer(
          (_) async => SuccessState(
            data: [AttachmentModel.fromEntity(existingLocalModel)],
          ),
        );

        // Act
        await repository.getAttachmentsByWorkOrder(workOrderId);

        // Assert
        verify(
          () => mockLocalDataSource.saveAttachment(
            AttachmentModel.fromEntity(
              remoteModel.copyWith(localPath: 'local/path/file.jpg'),
            ),
          ),
        ).called(1);
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
        final localAttachment = AttachmentModel.fromEntity(
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
        final localAttachment = AttachmentModel.fromEntity(
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
        final localAttachment = AttachmentModel.fromEntity(
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
        final localAttachment = AttachmentModel.fromEntity(
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
      'should not throw FormatException when path has custom/invalid URI scheme and no extension',
      () async {
        const invalidSchemePath = 'virtual_file://test_image_without_extension';
        when(
          () => fileService.takePhoto(),
        ).thenAnswer((_) async => invalidSchemePath);
        when(
          () => fileService.getFileSizeBytes(any()),
        ).thenAnswer((_) async => 1024);

        final result = await repository.pickAndPrepareAttachment(
          source: AttachmentSource.cameraPhoto,
          workOrderId: workOrderId,
          companyId: companyId,
          uploadedById: uploadedById,
        );

        // It should still return a FailureState due to unsupported extension, not throw FormatException
        expect(result, isA<FailureState<List<AttachmentEntity>>>());
        expect(
          (result as FailureState).message,
          contains('Tipo de arquivo não suportado'),
        );
      },
    );

    test(
      'should successfully compress, copy, and save image to local when offline',
      () async {
        // Create actual temporary files so File(originalPath).readAsBytes() does not throw FileSystemException
        final tempDir = Directory.systemTemp.createTempSync(
          'attachments_test_',
        );
        final mockPath = '${tempDir.path}/test_image.jpg';
        File(mockPath).createSync(recursive: true);
        File(mockPath).writeAsBytesSync(List.filled(100, 0));

        when(() => mockInternet.isConnected).thenReturn(false);
        when(() => fileService.takePhoto()).thenAnswer((_) async => mockPath);
        when(
          () => fileService.getFileSizeBytes(mockPath),
        ).thenAnswer((_) async => 5 * 1024 * 1024);

        final sandboxPath = '${tempDir.path}/${faker.guid.guid()}.webp';
        File(sandboxPath).createSync(recursive: true);
        File(sandboxPath).writeAsBytesSync(List.filled(10, 0));

        when(
          () => fileService.compressAndSaveImage(mockPath),
        ).thenAnswer((_) async => SuccessState(data: sandboxPath));
        when(
          () => fileService.getFileSizeBytes(sandboxPath),
        ).thenAnswer((_) async => 500 * 1024);

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
      },
    );

    test(
      'should only save locally as pending when online (no auto-upload)',
      () async {
        // Create actual temporary files so File(originalPath).readAsBytes() does not throw FileSystemException
        final tempDir = Directory.systemTemp.createTempSync(
          'attachments_test_',
        );
        final mockPath = '${tempDir.path}/test_image.jpg';
        File(mockPath).createSync(recursive: true);
        File(mockPath).writeAsBytesSync(List.filled(100, 0));

        when(() => mockInternet.isConnected).thenReturn(true);
        when(() => fileService.takePhoto()).thenAnswer((_) async => mockPath);
        when(
          () => fileService.getFileSizeBytes(mockPath),
        ).thenAnswer((_) async => 5 * 1024 * 1024);

        final sandboxPath = '${tempDir.path}/${faker.guid.guid()}.webp';
        File(sandboxPath).createSync(recursive: true);
        File(sandboxPath).writeAsBytesSync(List.filled(10, 0));

        when(
          () => fileService.compressAndSaveImage(mockPath),
        ).thenAnswer((_) async => SuccessState(data: sandboxPath));
        when(
          () => fileService.getFileSizeBytes(sandboxPath),
        ).thenAnswer((_) async => 500 * 1024);

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
        verifyNever(
          () => storageClient.uploadFile(
            presignedUrl: any(named: 'presignedUrl'),
            filePath: any(named: 'filePath'),
            mimeType: any(named: 'mimeType'),
          ),
        );
        verifyNever(() => mockRemoteDataSource.confirmUpload(any()));
      },
    );

    test(
      'should call pickMediaFromGallery with multiple: false when multiple: false is passed',
      () async {
        final tempDir = Directory.systemTemp.createTempSync(
          'attachments_test_',
        );
        final mockPath = '${tempDir.path}/test_gallery_image.jpg';
        final f = File(mockPath);
        if (!f.existsSync()) {
          f
            ..createSync(recursive: true)
            ..writeAsBytesSync(List.filled(10, 0));
        }

        when(
          () => fileService.pickMediaFromGallery(multiple: false),
        ).thenAnswer(
          (_) async => [
            (path: mockPath, name: 'test_gallery_image.jpg', bytes: null),
          ],
        );
        when(
          () => fileService.getFileSizeBytes(mockPath),
        ).thenAnswer((_) async => 1024);

        final sandboxPath = '${tempDir.path}/sandbox_image.webp';
        final fSandbox = File(sandboxPath);
        if (!fSandbox.existsSync()) {
          fSandbox
            ..createSync(recursive: true)
            ..writeAsBytesSync(List.filled(5, 0));
        }

        when(
          () => fileService.compressAndSaveImage(mockPath),
        ).thenAnswer((_) async => SuccessState(data: sandboxPath));
        when(
          () => fileService.getFileSizeBytes(sandboxPath),
        ).thenAnswer((_) async => 500);

        final result = await repository.pickAndPrepareAttachment(
          source: AttachmentSource.gallery,
          workOrderId: workOrderId,
          companyId: companyId,
          uploadedById: uploadedById,
          multiple: false,
        );

        expect(result, isA<SuccessState<List<AttachmentEntity>>>());
        expect(result.data!.length, 1);
        expect(result.data!.first.localPath, sandboxPath);

        verify(
          () => fileService.pickMediaFromGallery(multiple: false),
        ).called(1);
      },
    );
  });

  group('uploadPendingAttachment', () {
    final mockEntity = EntityFactory.makeAttachmentEntity().copyWith(
      localPath: '${Directory.systemTemp.path}/local_file.jpg',
      originalPath: '${Directory.systemTemp.path}/original_file.jpg',
    );

    test('should return FailureState when local file does not exist', () async {
      when(
        () => fileService.fileExists('/does/not/exist.jpg'),
      ).thenAnswer((_) async => false);
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

    test(
      'should restore soft-deleted attachment and skip upload when identical attachment is soft-deleted',
      () async {
        final file = File(mockEntity.localPath!);
        await file.create(recursive: true);
        addTearDown(() async {
          if (file.existsSync()) await file.delete();
        });

        final tDeletedEntity = tAttachmentModel.copyWith(
          deletedAt: DateTime.now(),
        );

        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getAttachmentByHash(
            workOrderId: mockEntity.workOrderId,
            hash: mockEntity.originalPath!,
          ),
        ).thenAnswer(
          (_) async =>
              SuccessState(data: AttachmentModel.fromEntity(tDeletedEntity)),
        );

        when(
          () => mockRemoteDataSource.restoreAttachment(
            id: tDeletedEntity.id,
            uploadedById: mockEntity.uploadedById,
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        when(
          () => mockLocalDataSource.hardDeleteAttachment(mockEntity.id),
        ).thenAnswer((_) async => const SuccessState(data: true));

        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.uploadPendingAttachment(mockEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);

        verify(
          () => mockRemoteDataSource.getAttachmentByHash(
            workOrderId: mockEntity.workOrderId,
            hash: mockEntity.originalPath!,
          ),
        ).called(1);
        verify(
          () => mockRemoteDataSource.restoreAttachment(
            id: tDeletedEntity.id,
            uploadedById: mockEntity.uploadedById,
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.hardDeleteAttachment(mockEntity.id),
        ).called(1);
        verify(() => mockLocalDataSource.saveAttachment(any())).called(1);
        verifyNever(() => mockRemoteDataSource.getPresignedUploadUrl(any()));
        verifyNever(
          () => storageClient.uploadFile(
            presignedUrl: any(named: 'presignedUrl'),
            filePath: any(named: 'filePath'),
            mimeType: any(named: 'mimeType'),
          ),
        );
      },
    );

    test(
      'should reuse active attachment and skip upload when identical attachment is active remotely',
      () async {
        final file = File(mockEntity.localPath!);
        await file.create(recursive: true);
        addTearDown(() async {
          if (file.existsSync()) await file.delete();
        });

        final tActiveModel = tAttachmentModel.copyWith(annulDeletedAt: true);

        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getAttachmentByHash(
            workOrderId: mockEntity.workOrderId,
            hash: mockEntity.originalPath!,
          ),
        ).thenAnswer(
          (_) async =>
              SuccessState(data: AttachmentModel.fromEntity(tActiveModel)),
        );

        when(
          () => mockLocalDataSource.hardDeleteAttachment(mockEntity.id),
        ).thenAnswer((_) async => const SuccessState(data: true));

        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.uploadPendingAttachment(mockEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);

        verify(
          () => mockRemoteDataSource.getAttachmentByHash(
            workOrderId: mockEntity.workOrderId,
            hash: mockEntity.originalPath!,
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.hardDeleteAttachment(mockEntity.id),
        ).called(1);
        verify(() => mockLocalDataSource.saveAttachment(any())).called(1);
        verifyNever(
          () => storageClient.uploadFile(
            presignedUrl: any(named: 'presignedUrl'),
            filePath: any(named: 'filePath'),
            mimeType: any(named: 'mimeType'),
          ),
        );
      },
    );
  });

  group('AttachmentsRepositoryImpl - Cache Management', () {
    test('touchLastAccessed should touch access time locally', () async {
      final id = faker.guid.guid();
      when(
        () => mockLocalDataSource.touchLastAccessed(id),
      ).thenAnswer((_) async => SuccessState.nil);

      final result = await repository.touchLastAccessed(id);

      expect(result, isA<SuccessState<void>>());
      verify(() => mockLocalDataSource.touchLastAccessed(id)).called(1);
    });

    test(
      'getSandboxSizeBytes should return local database sum of bytes',
      () async {
        final size = (kSandboxQuotaBytes * 0.15).round();
        when(
          () => mockLocalDataSource.getTotalSandboxBytes(),
        ).thenAnswer((_) async => SuccessState(data: size));

        final result = await repository.getSandboxSizeBytes();

        expect(result, isA<SuccessState<int>>());
        expect(result.data, size);
        verify(() => mockLocalDataSource.getTotalSandboxBytes()).called(1);
      },
    );

    test(
      'pruneSandbox should do nothing if current sandbox size is under quota',
      () async {
        when(() => mockLocalDataSource.getTotalSandboxBytes()).thenAnswer(
          (_) async => const SuccessState(data: kSandboxQuotaBytes - 1),
        ); // kSandboxQuotaBytes - 1

        final result = await repository.pruneSandbox();

        expect(result, isA<SuccessState<void>>());
        verifyNever(() => mockLocalDataSource.getUploadedOrderedByLastAccess());
      },
    );

    test(
      'pruneSandbox should evict oldest uploaded attachments until under quota',
      () async {
        final totalBytes = (kSandboxQuotaBytes * 1.5).round();
        final candidate1Size = (kSandboxQuotaBytes * 0.6).round();
        final candidate2Size = (kSandboxQuotaBytes * 0.4).round();

        when(
          () => mockLocalDataSource.getTotalSandboxBytes(),
        ).thenAnswer((_) async => SuccessState(data: totalBytes));

        final candidate1 = AttachmentModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            localPath: 'file1.webp',
            fileSizeBytes: candidate1Size,
          ),
        );
        final candidate2 = AttachmentModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            localPath: 'file2.webp',
            fileSizeBytes: candidate2Size,
          ),
        );

        when(
          () => mockLocalDataSource.getUploadedOrderedByLastAccess(),
        ).thenAnswer((_) async => SuccessState(data: [candidate1, candidate2]));
        when(() => fileService.fileExists(any())).thenAnswer((_) async => true);
        when(
          () => fileService.deleteLocalFile(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.pruneSandbox();

        expect(result, isA<SuccessState<void>>());
        // Candidate 1 evicted (frees candidate1Size, bringing total under quota)
        // Candidate 2 should NOT be processed
        verify(
          () => fileService.deleteLocalFile('/sandbox/file1.webp'),
        ).called(1);
        verifyNever(() => fileService.deleteLocalFile('/sandbox/file2.webp'));
        verify(() => mockLocalDataSource.saveAttachment(any())).called(1);
      },
    );

    test(
      'clearLocalAttachments should delete local sandbox files and nullify localPath in database',
      () async {
        final upload1 = AttachmentModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            localPath: 'upload1.jpg',
          ),
        );
        final upload2 = AttachmentModel.fromEntity(
          EntityFactory.makeAttachmentEntity().copyWith(
            localPath: 'upload2.jpg',
          ),
        );

        when(
          () => mockLocalDataSource.getUploadedOrderedByLastAccess(),
        ).thenAnswer((_) async => SuccessState(data: [upload1, upload2]));
        when(() => fileService.fileExists(any())).thenAnswer((_) async => true);
        when(
          () => fileService.deleteLocalFile(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.clearLocalAttachments();

        expect(result, isA<SuccessState<void>>());
        verify(
          () => fileService.deleteLocalFile('/sandbox/upload1.jpg'),
        ).called(1);
        verify(
          () => fileService.deleteLocalFile('/sandbox/upload2.jpg'),
        ).called(1);
        verify(() => mockLocalDataSource.saveAttachment(any())).called(2);
      },
    );

    group('_toEntityWithResolvedPath - remote file caching', () {
      // Shared test values — a stable ID and a URL whose extension we can assert.
      final fileId = faker.guid.guid();
      final remoteFileUrl =
          'https://pub-${faker.guid.guid()}.r2.dev/attachments/$fileId.jpg';
      final cacheFileName = '$fileId.jpg';
      final absoluteCachedPath = '/docs/attachments/$cacheFileName';
      final downloadedSize = faker.randomGenerator.integer(
        1024 * 1024,
        min: 1024,
      );

      setUp(() {
        // These tests run offline so we only need the local data source.
        when(() => mockInternet.isConnected).thenReturn(false);
        // Default: file does NOT exist on disk (triggers the download path).
        when(
          () => fileService.fileExists(any()),
        ).thenAnswer((_) async => false);
        when(
          () => fileService.downloadUrlToSandbox(any(), any()),
        ).thenAnswer((_) async => SuccessState(data: absoluteCachedPath));
        when(
          () => fileService.getFileSizeBytes(absoluteCachedPath),
        ).thenAnswer((_) async => downloadedSize);
        when(
          () => mockLocalDataSource.saveAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
      });

      test(
        'downloads and caches remote image file when no local copy exists',
        () async {
          final workOrderId = faker.guid.guid();
          final model = AttachmentModel.fromEntity(
            EntityFactory.makeAttachmentEntity().copyWith(
              id: fileId,
              remoteUrl: remoteFileUrl,
              uploadStatus: UploadStatus.uploaded,
              fileType: FileType.image,
              annulLocalPath: true,
            ),
          );
          when(
            () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
          ).thenAnswer((_) async => SuccessState(data: [model]));

          final result = await repository.getAttachmentsByWorkOrder(
            workOrderId,
          );

          expect(result, isA<SuccessState<List<AttachmentEntity>>>());
          expect(result.data?.first.localPath, absoluteCachedPath);
          expect(result.data?.first.fileSizeBytes, downloadedSize);
          verify(
            () =>
                fileService.downloadUrlToSandbox(remoteFileUrl, cacheFileName),
          ).called(1);
          verify(
            () => fileService.getFileSizeBytes(absoluteCachedPath),
          ).called(1);
          verify(() => mockLocalDataSource.saveAttachment(any())).called(1);
          verify(() => mockLocalDataSource.touchLastAccessed(fileId)).called(1);
        },
      );

      test(
        'does not download video files to prevent filling the sandbox with large files',
        () async {
          final workOrderId = faker.guid.guid();
          final model = AttachmentModel.fromEntity(
            EntityFactory.makeAttachmentEntity().copyWith(
              id: fileId,
              remoteUrl: remoteFileUrl,
              uploadStatus: UploadStatus.uploaded,
              fileType: FileType.video,
              annulLocalPath: true,
            ),
          );
          when(
            () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
          ).thenAnswer((_) async => SuccessState(data: [model]));

          final result = await repository.getAttachmentsByWorkOrder(
            workOrderId,
          );

          expect(result, isA<SuccessState<List<AttachmentEntity>>>());
          expect(result.data?.first.localPath, isNull);
          verifyNever(() => fileService.downloadUrlToSandbox(any(), any()));
        },
      );

      test(
        'does not download attachments that have not been fully uploaded yet',
        () async {
          final workOrderId = faker.guid.guid();
          final model = AttachmentModel.fromEntity(
            EntityFactory.makeAttachmentEntity().copyWith(
              id: fileId,
              remoteUrl: remoteFileUrl,
              uploadStatus: UploadStatus.pending,
              fileType: FileType.image,
              annulLocalPath: true,
            ),
          );
          when(
            () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
          ).thenAnswer((_) async => SuccessState(data: [model]));

          final result = await repository.getAttachmentsByWorkOrder(
            workOrderId,
          );

          expect(result, isA<SuccessState<List<AttachmentEntity>>>());
          expect(result.data?.first.localPath, isNull);
          verifyNever(() => fileService.downloadUrlToSandbox(any(), any()));
        },
      );

      test(
        'falls back to null localPath (using remoteUrl) when download fails',
        () async {
          when(
            () => fileService.downloadUrlToSandbox(any(), any()),
          ).thenAnswer((_) async => FailureState(message: 'Network error'));
          final workOrderId = faker.guid.guid();
          final model = AttachmentModel.fromEntity(
            EntityFactory.makeAttachmentEntity().copyWith(
              id: fileId,
              remoteUrl: remoteFileUrl,
              uploadStatus: UploadStatus.uploaded,
              fileType: FileType.image,
              annulLocalPath: true,
            ),
          );
          when(
            () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
          ).thenAnswer((_) async => SuccessState(data: [model]));

          final result = await repository.getAttachmentsByWorkOrder(
            workOrderId,
          );

          expect(result, isA<SuccessState<List<AttachmentEntity>>>());
          expect(result.data?.first.localPath, isNull);
          verify(
            () =>
                fileService.downloadUrlToSandbox(remoteFileUrl, cacheFileName),
          ).called(1);
          verifyNever(() => mockLocalDataSource.saveAttachment(any()));
        },
      );

      test(
        'clears stale localPath in DB and re-downloads when the physical file is missing from disk',
        () async {
          final staleLocalPath = faker.lorem.word();
          final workOrderId = faker.guid.guid();
          final model = AttachmentModel.fromEntity(
            EntityFactory.makeAttachmentEntity().copyWith(
              id: fileId,
              remoteUrl: remoteFileUrl,
              uploadStatus: UploadStatus.uploaded,
              fileType: FileType.image,
              localPath: staleLocalPath,
            ),
          );
          when(
            () => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId),
          ).thenAnswer((_) async => SuccessState(data: [model]));

          final result = await repository.getAttachmentsByWorkOrder(
            workOrderId,
          );

          expect(result, isA<SuccessState<List<AttachmentEntity>>>());
          expect(result.data?.first.localPath, absoluteCachedPath);
          // First saveAttachment clears the stale path, second saves the newly cached path.
          verify(() => mockLocalDataSource.saveAttachment(any())).called(2);
          verify(
            () =>
                fileService.downloadUrlToSandbox(remoteFileUrl, cacheFileName),
          ).called(1);
        },
      );
    });
  });

  group('AttachmentsRepository in provider mode', () {
    final tAttachment = EntityFactory.makeAttachmentEntity();
    final tModel = AttachmentModel.fromEntity(tAttachment);

    setUp(() {
      when(
        () => mockSessionRepository.getSelectedMode(),
      ).thenReturn(AppMode.provider.name);
    });

    test('getAttachmentsByWorkOrder fetches remotely without saving locally', () async {
      when(() => mockInternet.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.getAttachmentsByWorkOrder(any()),
      ).thenAnswer((_) async => SuccessState(data: [tModel]));

      final result = await repository.getAttachmentsByWorkOrder(tAttachment.workOrderId);

      expect(result, isA<SuccessState<List<AttachmentEntity>>>());
      verify(() => mockRemoteDataSource.getAttachmentsByWorkOrder(tAttachment.workOrderId)).called(1);
      verifyNever(() => mockLocalDataSource.saveAttachment(any()));
    });

    test('getAttachmentsByWorkOrder returns failure without local fallback when offline', () async {
      when(() => mockInternet.isConnected).thenReturn(false);

      final result = await repository.getAttachmentsByWorkOrder(tAttachment.workOrderId);

      expect(result, isA<FailureState<List<AttachmentEntity>>>());
      verifyNever(() => mockLocalDataSource.getAttachmentsByWorkOrder(any()));
    });

    test('deleteAttachment deletes remotely without local interaction in provider mode', () async {
      when(() => mockInternet.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.deleteAttachment(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.deleteAttachment(tAttachment.id);

      expect(result, const SuccessState(data: true));
      verify(() => mockRemoteDataSource.deleteAttachment(tAttachment.id)).called(1);
      verifyNever(() => mockLocalDataSource.deleteAttachment(any()));
    });

    test('deleteAttachment returns failure when offline in provider mode', () async {
      when(() => mockInternet.isConnected).thenReturn(false);

      final result = await repository.deleteAttachment(tAttachment.id);

      expect(result, isA<FailureState<bool>>());
      verifyNever(() => mockRemoteDataSource.deleteAttachment(any()));
      verifyNever(() => mockLocalDataSource.deleteAttachment(any()));
    });
  });

  group('watchAttachmentsRealtime', () {
    final tAttachment = EntityFactory.makeAttachmentEntity();
    final tModel = AttachmentModel.fromEntity(tAttachment);

    test('saves model locally and emits event on insert in internal mode', () async {
      when(() => mockSessionRepository.getSelectedMode()).thenReturn(AppMode.internal.name);
      when(() => mockLocalDataSource.getAttachment(tModel.id))
          .thenAnswer((_) async => const SuccessState(data: null));
      when(() => mockLocalDataSource.saveAttachment(any()))
          .thenAnswer((_) async => const SuccessState(data: true));

      final remoteEvent = RealtimeEvent<AttachmentModel>(
        eventType: RealtimeEventType.insert,
        id: tModel.id,
        entity: tModel,
      );

      when(() => mockRemoteDataSource.watchAttachmentsRealtime(workOrderId: tAttachment.workOrderId))
          .thenAnswer((_) => Stream.value(remoteEvent));

      final stream = repository.watchAttachmentsRealtime(workOrderId: tAttachment.workOrderId);

      await expectLater(
        stream,
        emits(
          predicate<RealtimeEvent<AttachmentEntity>>((event) {
            return event.eventType == RealtimeEventType.insert &&
                event.id == tModel.id &&
                event.entity?.fileName == tModel.fileName;
          }),
        ),
      );

      verify(() => mockLocalDataSource.saveAttachment(any())).called(1);
    });

    test('deletes locally on update with deletedAt in internal mode', () async {
      when(() => mockSessionRepository.getSelectedMode()).thenReturn(AppMode.internal.name);
      when(() => mockLocalDataSource.deleteAttachment(tModel.id))
          .thenAnswer((_) async => const SuccessState(data: true));

      final deletedModel = AttachmentModel.fromEntity(
        tAttachment.copyWith(deletedAt: DateTime.now()),
      );
      final remoteEvent = RealtimeEvent<AttachmentModel>(
        eventType: RealtimeEventType.update,
        id: deletedModel.id,
        entity: deletedModel,
      );

      when(() => mockRemoteDataSource.watchAttachmentsRealtime(workOrderId: tAttachment.workOrderId))
          .thenAnswer((_) => Stream.value(remoteEvent));

      final stream = repository.watchAttachmentsRealtime(workOrderId: tAttachment.workOrderId);

      await expectLater(
        stream,
        emits(
          predicate<RealtimeEvent<AttachmentEntity>>((event) {
            return event.eventType == RealtimeEventType.update &&
                event.id == deletedModel.id;
          }),
        ),
      );

      verify(() => mockLocalDataSource.deleteAttachment(deletedModel.id)).called(1);
    });

    test('deletes locally on delete event in internal mode', () async {
      when(() => mockSessionRepository.getSelectedMode()).thenReturn(AppMode.internal.name);
      when(() => mockLocalDataSource.deleteAttachment(tModel.id))
          .thenAnswer((_) async => const SuccessState(data: true));

      final remoteEvent = RealtimeEvent<AttachmentModel>(
        eventType: RealtimeEventType.delete,
        id: tModel.id,
      );

      when(() => mockRemoteDataSource.watchAttachmentsRealtime(workOrderId: tAttachment.workOrderId))
          .thenAnswer((_) => Stream.value(remoteEvent));

      final stream = repository.watchAttachmentsRealtime(workOrderId: tAttachment.workOrderId);

      await expectLater(
        stream,
        emits(
          predicate<RealtimeEvent<AttachmentEntity>>((event) {
            return event.eventType == RealtimeEventType.delete &&
                event.id == tModel.id;
          }),
        ),
      );

      verify(() => mockLocalDataSource.deleteAttachment(tModel.id)).called(1);
    });

    test('does not interact with local database in provider mode', () async {
      when(() => mockSessionRepository.getSelectedMode()).thenReturn(AppMode.provider.name);

      final remoteEvent = RealtimeEvent<AttachmentModel>(
        eventType: RealtimeEventType.insert,
        id: tModel.id,
        entity: tModel,
      );

      when(() => mockRemoteDataSource.watchAttachmentsRealtime(workOrderId: tAttachment.workOrderId))
          .thenAnswer((_) => Stream.value(remoteEvent));

      final stream = repository.watchAttachmentsRealtime(workOrderId: tAttachment.workOrderId);

      await expectLater(
        stream,
        emits(
          predicate<RealtimeEvent<AttachmentEntity>>((event) {
            return event.eventType == RealtimeEventType.insert &&
                event.id == tModel.id;
          }),
        ),
      );

      verifyNever(() => mockLocalDataSource.saveAttachment(any()));
      verifyNever(() => mockLocalDataSource.deleteAttachment(any()));
    });
  });
}

