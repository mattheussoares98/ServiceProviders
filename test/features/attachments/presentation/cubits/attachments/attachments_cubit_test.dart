import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_sandbox_size_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_video_thumbnail_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/open_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/prune_sandbox_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/touch_last_accessed_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/upload_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetAttachmentsUseCase extends Mock implements GetAttachmentsUseCase {}

class MockPickAttachmentUseCase extends Mock implements PickAttachmentUseCase {}

class MockUploadAttachmentUseCase extends Mock
    implements UploadAttachmentUseCase {}

class MockDeleteAttachmentUseCase extends Mock
    implements DeleteAttachmentUseCase {}

class MockOpenAttachmentUseCase extends Mock implements OpenAttachmentUseCase {}

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockGetActiveCompanyIdUseCase extends Mock
    implements GetActiveCompanyIdUseCase {}

class MockGetVideoThumbnailUseCase extends Mock
    implements GetVideoThumbnailUseCase {}

class MockPruneSandboxUseCase extends Mock implements PruneSandboxUseCase {}

class MockGetSandboxSizeUseCase extends Mock implements GetSandboxSizeUseCase {}

class MockTouchLastAccessedUseCase extends Mock
    implements TouchLastAccessedUseCase {}

void main() {
  final faker = Faker();
  late MockGetAttachmentsUseCase mockGetAttachments;
  late MockPickAttachmentUseCase mockPickAttachment;
  late MockUploadAttachmentUseCase mockUploadAttachment;
  late MockDeleteAttachmentUseCase mockDeleteAttachment;
  late MockOpenAttachmentUseCase mockOpenAttachment;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetVideoThumbnailUseCase mockGetVideoThumbnail;
  late MockPruneSandboxUseCase mockPruneSandbox;
  late MockGetSandboxSizeUseCase mockGetSandboxSize;
  late MockTouchLastAccessedUseCase mockTouchLastAccessed;
  late AttachmentsCubitUseCases useCases;
  late MockNavigationClient mockNavigationClient;

  setUpAll(() {
    registerFallbackValue(
      const PickAttachmentParams(
        source: AttachmentSource.cameraPhoto,
        workOrderId: '123',
        companyId: 'abc',
        userId: 'xyz',
      ),
    );
    registerFallbackValue(EntityFactory.makeAttachmentEntity());
  });

  setUp(() {
    mockGetAttachments = MockGetAttachmentsUseCase();
    mockPickAttachment = MockPickAttachmentUseCase();
    mockUploadAttachment = MockUploadAttachmentUseCase();
    mockDeleteAttachment = MockDeleteAttachmentUseCase();
    mockOpenAttachment = MockOpenAttachmentUseCase();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockGetVideoThumbnail = MockGetVideoThumbnailUseCase();
    mockPruneSandbox = MockPruneSandboxUseCase();
    mockGetSandboxSize = MockGetSandboxSizeUseCase();
    mockTouchLastAccessed = MockTouchLastAccessedUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    when(() => mockPruneSandbox()).thenAnswer((_) async => SuccessState.nil);
    when(
      () => mockTouchLastAccessed(any()),
    ).thenAnswer((_) async => SuccessState.nil);
    when(() => mockGetActiveCompanyId()).thenReturn('abc');

    useCases = AttachmentsCubitUseCases(
      getAttachments: mockGetAttachments,
      pickAttachment: mockPickAttachment,
      uploadAttachment: mockUploadAttachment,
      deleteAttachment: mockDeleteAttachment,
      openAttachment: mockOpenAttachment,
      getSessionUser: mockGetSessionUser,
      getActiveCompanyId: mockGetActiveCompanyId,
      getVideoThumbnail: mockGetVideoThumbnail,
      pruneSandbox: mockPruneSandbox,
      getSandboxSize: mockGetSandboxSize,
      touchLastAccessed: mockTouchLastAccessed,
    );
  });

  tearDown(GetIt.I.reset);

  final tUser = EntityFactory.makeUserProfileEntity();
  final tAttachmentList = EntityFactory.makeAttachmentEntityList();
  final tUploadedAttachmentList = EntityFactory.makeAttachmentEntityList()
      .map((e) => e.copyWith(uploadStatus: UploadStatus.uploaded))
      .toList();
  final tWorkOrderId = faker.guid.guid();

  group('AttachmentsCubit - init & refresh', () {
    blocTest<AttachmentsCubit, AttachmentsState>(
      'emits [loading, loaded] when init successfully fetches attachments',
      build: () {
        when(
          () => mockGetAttachments(any()),
        ).thenAnswer((_) async => SuccessState(data: tUploadedAttachmentList));
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      act: (cubit) => cubit.refreshAttachments(),
      expect: () => [
        isA<AttachmentsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<AttachmentsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having(
              (s) => s.attachments,
              'attachments',
              tUploadedAttachmentList,
            ),
      ],
      verify: (_) {
        verify(() => mockGetAttachments(tWorkOrderId)).called(1);
      },
    );

    blocTest<AttachmentsCubit, AttachmentsState>(
      'emits [loading, loadingError] when init fails to fetch attachments',
      build: () {
        when(
          () => mockGetAttachments(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error fetching'));
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      act: (cubit) => cubit.refreshAttachments(),
      expect: () => [
        isA<AttachmentsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<AttachmentsState>()
            .having((s) => s.status, 'status', StateStatus.loadingError)
            .having((s) => s.errorMessage, 'errorMessage', 'Error fetching'),
      ],
    );
  });

  group('AttachmentsCubit - pickAttachment & upload', () {
    final tPickedFile = EntityFactory.makeAttachmentEntity().copyWith(
      uploadStatus: UploadStatus.pending,
    );

    blocTest<AttachmentsCubit, AttachmentsState>(
      'successfully picks and triggers upload for pending attachment',
      build: () {
        when(() => mockGetSessionUser()).thenReturn(tUser);
        when(
          () => mockPickAttachment(any()),
        ).thenAnswer((_) async => SuccessState(data: [tPickedFile]));
        when(
          () => mockUploadAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        // Refresh call inside _uploadAttachment will fetch updated list, but first fetch should be empty
        var getAttachmentsCallCount = 0;
        when(() => mockGetAttachments(any())).thenAnswer((_) async {
          getAttachmentsCallCount++;
          if (getAttachmentsCallCount == 1) {
            return const SuccessState(data: []);
          }
          return SuccessState(
            data: [tPickedFile.copyWith(uploadStatus: UploadStatus.uploaded)],
          );
        });
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      act: (cubit) async {
        await cubit.refreshAttachments();
        await cubit.pickAttachment(AttachmentSource.cameraPhoto);
        await cubit.uploadPending();
      },
      skip: 2, // Skip initial loading/loaded from init
      expect: () => [
        // 1. Adds picked attachment to state
        isA<AttachmentsState>().having((s) => s.attachments, 'attachments', [
          tPickedFile,
        ]),
        // 2. Starts uploading (adds ID to uploadingIds)
        isA<AttachmentsState>().having((s) => s.uploadingIds, 'uploadingIds', {
          tPickedFile.id,
        }),
        // 3. Upload finishes (removes ID from uploadingIds)
        isA<AttachmentsState>().having(
          (s) => s.uploadingIds,
          'uploadingIds',
          isEmpty,
        ),
        // 4. Refreshes list after successful upload
        isA<AttachmentsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<AttachmentsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having(
              (s) => s.attachments[0].uploadStatus,
              'status',
              UploadStatus.uploaded,
            ),
      ],
    );

    blocTest<AttachmentsCubit, AttachmentsState>(
      'filters out and cleans up duplicates during pickAttachment',
      build: () {
        when(() => mockGetSessionUser()).thenReturn(tUser);
        final tUploadedList = tAttachmentList
            .map((e) => e.copyWith(uploadStatus: UploadStatus.uploaded))
            .toList();
        when(
          () => mockGetAttachments(any()),
        ).thenAnswer((_) async => SuccessState(data: tUploadedList));
        when(
          () => mockUploadAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockGetVideoThumbnail(any()),
        ).thenAnswer((_) async => const SuccessState(data: 'thumb.jpg'));
        // Returns the same attachment that is already in state
        when(
          () => mockPickAttachment(any()),
        ).thenAnswer((_) async => SuccessState(data: [tAttachmentList.first]));
        when(
          () => mockDeleteAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      act: (cubit) async {
        await cubit.refreshAttachments();
        await cubit.pickAttachment(AttachmentSource.cameraPhoto);
      },
      skip: 2, // Skip initial loading/loaded from init
      expect: () =>
          <AttachmentsState>[], // No emissions because newAttachments is empty
      verify: (_) {
        verify(() => mockDeleteAttachment(tAttachmentList.first.id)).called(1);
      },
    );

    blocTest<AttachmentsCubit, AttachmentsState>(
      'emits processingCount during picking and resets to 0 at the end',
      build: () {
        when(() => mockGetSessionUser()).thenReturn(tUser);
        when(() => mockPickAttachment(any())).thenAnswer((invocation) async {
          final params =
              invocation.positionalArguments[0] as PickAttachmentParams;
          params.onFilesPicked?.call(2);
          return SuccessState(data: [tPickedFile]);
        });
        when(
          () => mockGetAttachments(any()),
        ).thenAnswer((_) async => const SuccessState(data: []));
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      act: (cubit) async {
        await cubit.refreshAttachments();
        await cubit.pickAttachment(AttachmentSource.cameraPhoto);
      },
      skip: 2, // Skip initial loading/loaded from init
      expect: () => [
        isA<AttachmentsState>().having(
          (s) => s.processingCount,
          'processingCount',
          2,
        ),
        isA<AttachmentsState>()
            .having((s) => s.processingCount, 'processingCount', 0)
            .having((s) => s.attachments, 'attachments', isEmpty),
        isA<AttachmentsState>()
            .having((s) => s.processingCount, 'processingCount', 0)
            .having((s) => s.attachments, 'attachments', [tPickedFile]),
      ],
    );
  });

  group('AttachmentsCubit - uploadPending', () {
    final tAttachment = EntityFactory.makeAttachmentEntity().copyWith(
      uploadStatus: UploadStatus.pending,
    );

    blocTest<AttachmentsCubit, AttachmentsState>(
      'should auto-upload pending attachments on init/refresh and succeed',
      build: () {
        when(
          () => mockUploadAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        var getAttachmentsCallCount = 0;
        when(() => mockGetAttachments(any())).thenAnswer((_) async {
          getAttachmentsCallCount++;
          if (getAttachmentsCallCount == 1) {
            return SuccessState(data: [tAttachment]);
          }
          return SuccessState(
            data: [tAttachment.copyWith(uploadStatus: UploadStatus.uploaded)],
          );
        });
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      act: (cubit) => cubit.refreshAttachments(),
      expect: () => [
        isA<AttachmentsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<AttachmentsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.attachments, 'attachments', [tAttachment]),
        isA<AttachmentsState>().having((s) => s.uploadingIds, 'uploadingIds', {
          tAttachment.id,
        }),
        isA<AttachmentsState>().having(
          (s) => s.uploadingIds,
          'uploadingIds',
          isEmpty,
        ),
        isA<AttachmentsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<AttachmentsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having(
              (s) => s.attachments[0].uploadStatus,
              'uploadStatus',
              UploadStatus.uploaded,
            ),
      ],
    );
  });

  group('AttachmentsCubit - deleteAttachment', () {
    final tAttachment = tAttachmentList.first;

    blocTest<AttachmentsCubit, AttachmentsState>(
      'adds ID to pendingDeletions and removes from attachments list',
      build: () {
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      seed: () => AttachmentsState(
        status: StateStatus.loaded,
        attachments: tAttachmentList,
      ),
      act: (cubit) => cubit.deleteAttachment(tAttachment.id),
      expect: () => [
        isA<AttachmentsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having(
              (s) => s.attachments,
              'attachments',
              tAttachmentList.skip(1).toList(),
            )
            .having((s) => s.pendingDeletions, 'pendingDeletions', {
              tAttachment.id,
            }),
      ],
    );
  });

  group('AttachmentsCubit - openAttachment', () {
    final tAttachment = tAttachmentList.first;

    blocTest<AttachmentsCubit, AttachmentsState>(
      'does not emit new states when open is successful',
      build: () {
        when(
          () => mockOpenAttachment(any()),
        ).thenAnswer((_) async => SuccessState.nil);
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      act: (cubit) => cubit.openAttachment(tAttachment),
      expect: () => <AttachmentsState>[],
      verify: (_) {
        verify(() => mockOpenAttachment(tAttachment)).called(1);
      },
    );
  });

  group('AttachmentsCubit - video thumbnails', () {
    final tVideoAttachment = EntityFactory.makeAttachmentEntity().copyWith(
      id: 'video_1',
      fileType: FileType.video,
      localPath: 'local_video.mp4',
      uploadStatus: UploadStatus.uploaded,
    );

    blocTest<AttachmentsCubit, AttachmentsState>(
      'successfully loads video thumbnails on init/refresh',
      build: () {
        when(
          () => mockGetAttachments(any()),
        ).thenAnswer((_) async => SuccessState(data: [tVideoAttachment]));
        when(
          () => mockGetVideoThumbnail(any()),
        ).thenAnswer((_) async => const SuccessState(data: 'thumb_path.jpg'));
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      act: (cubit) => cubit.refreshAttachments(),
      expect: () => [
        isA<AttachmentsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<AttachmentsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.attachments, 'attachments', [tVideoAttachment]),
        isA<AttachmentsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.videoThumbnails, 'videoThumbnails', {
              'video_1': 'thumb_path.jpg',
            }),
      ],
      verify: (_) {
        verify(() => mockGetAttachments(tWorkOrderId)).called(1);
        verify(() => mockGetVideoThumbnail('local_video.mp4')).called(1);
      },
    );
  });

  group('AttachmentsCubit - Cache Integration', () {
    final tAttachment = EntityFactory.makeAttachmentEntity();

    blocTest<AttachmentsCubit, AttachmentsState>(
      'should call pruneSandbox before picking attachments',
      build: () {
        when(() => mockGetSessionUser()).thenReturn(tUser);
        when(
          () => mockGetAttachments(any()),
        ).thenAnswer((_) async => const SuccessState(data: []));
        when(
          () => mockPickAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: []));
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      act: (cubit) async {
        await cubit.refreshAttachments();
        await cubit.pickAttachment(AttachmentSource.cameraPhoto);
      },
      verify: (_) {
        verify(() => mockPruneSandbox()).called(1);
        verify(() => mockPickAttachment(any())).called(1);
      },
    );

    blocTest<AttachmentsCubit, AttachmentsState>(
      'should call touchLastAccessed when opening an attachment',
      build: () {
        when(
          () => mockOpenAttachment(any()),
        ).thenAnswer((_) async => SuccessState.nil);
        return AttachmentsCubit(useCases: useCases, workOrderId: tWorkOrderId);
      },
      act: (cubit) => cubit.openAttachment(tAttachment),
      verify: (_) {
        verify(() => mockTouchLastAccessed(tAttachment.id)).called(1);
        verify(() => mockOpenAttachment(tAttachment)).called(1);
      },
    );
  });
}
