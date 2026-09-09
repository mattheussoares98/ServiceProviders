import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/checklist_factory.dart';
import '../../../../../testing/mocks/factories/maintenance_plan_factory.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';
import '../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetChecklistItemsByTemplateUseCase mockGetChecklistItemsByTemplate;
  late MockGetWorkOrderChecklistAnswersUseCase mockGetWorkOrderChecklistAnswers;
  late MockSaveChecklistResponseUseCase mockSaveChecklistResponse;
  late MockPickAttachmentUseCase mockPickAttachment;
  late MockUploadAttachmentUseCase mockUploadAttachment;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockWatchChecklistAnswersRealtimeUseCase mockWatchChecklistAnswers;
  late MockNavigationClient mockNavigationClient;
  late WorkOrderChecklistCubitUseCases useCases;

  setUpAll(() {
    registerFallbackValue(ChecklistFactory.makeChecklistAnswerEntity());
    registerFallbackValue(MaintenancePlanFactory.makeAttachmentEntity());
    registerFallbackValue(
      PickAttachmentParams(
        source: AttachmentSource.cameraPhoto,
        workOrderId: faker.guid.guid(),
        companyId: faker.guid.guid(),
        userId: faker.guid.guid(),
      ),
    );
  });

  setUp(() {
    mockGetChecklistItemsByTemplate = MockGetChecklistItemsByTemplateUseCase();
    mockGetWorkOrderChecklistAnswers =
        MockGetWorkOrderChecklistAnswersUseCase();
    mockSaveChecklistResponse = MockSaveChecklistResponseUseCase();
    mockPickAttachment = MockPickAttachmentUseCase();
    mockUploadAttachment = MockUploadAttachmentUseCase();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockWatchChecklistAnswers = MockWatchChecklistAnswersRealtimeUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    useCases = WorkOrderChecklistCubitUseCases(
      getChecklistItemsByTemplate: mockGetChecklistItemsByTemplate,
      getWorkOrderChecklistAnswers: mockGetWorkOrderChecklistAnswers,
      saveChecklistResponse: mockSaveChecklistResponse,
      pickAttachment: mockPickAttachment,
      uploadAttachment: mockUploadAttachment,
      getSessionUser: mockGetSessionUser,
      getActiveCompanyId: mockGetActiveCompanyId,
      watchChecklistAnswersRealtime: mockWatchChecklistAnswers,
    );

    when(
      () => mockGetSessionUser(),
    ).thenReturn(UserFactory.makeUserProfileEntity());
    when(() => mockGetActiveCompanyId()).thenReturn(faker.guid.guid());
  });

  tearDown(GetIt.I.reset);

  final tWorkOrderId = faker.guid.guid();
  final tTemplateId = faker.guid.guid();
  final tItems = [
    ChecklistFactory.makeChecklistItemEntity().copyWith(
      isRequired: true,
      type: ChecklistItemType.boolean,
    ),
    ChecklistFactory.makeChecklistItemEntity().copyWith(
      isRequired: false,
      type: ChecklistItemType.text,
    ),
  ];
  final tAnswers = [
    ChecklistFactory.makeChecklistAnswerEntity().copyWith(
      workOrderId: tWorkOrderId,
      checklistItemId: tItems.first.id,
      booleanValue: true,
    ),
  ];

  group('WorkOrderChecklistCubit', () {
    blocTest<WorkOrderChecklistCubit, WorkOrderChecklistState>(
      'loadChecklist emits [running, success] with items and answers',
      setUp: () {
        when(
          () => mockGetChecklistItemsByTemplate(any()),
        ).thenAnswer((_) async => SuccessState(data: tItems));
        when(
          () => mockGetWorkOrderChecklistAnswers(any()),
        ).thenAnswer((_) async => SuccessState(data: tAnswers));
      },
      build: () => WorkOrderChecklistCubit(useCases: useCases),
      act: (cubit) => cubit.loadChecklist(
        templateId: tTemplateId,
        workOrderId: tWorkOrderId,
      ),
      expect: () => [
        isA<WorkOrderChecklistState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'sections.load',
          SectionStatus.running,
        ),
        isA<WorkOrderChecklistState>()
            .having(
              (s) => s.sections[BaseSections.load]?.status,
              'sections.load',
              SectionStatus.success,
            )
            .having((s) => s.items, 'items', equals(tItems))
            .having((s) => s.answers.length, 'answers.length', 1)
            .having(
              (s) => s.areRequiredItemsCompleted,
              'areRequiredItemsCompleted',
              isTrue,
            ),
      ],
    );

    blocTest<WorkOrderChecklistCubit, WorkOrderChecklistState>(
      'answerItem updates state answers and computes required completion',
      setUp: () {
        when(
          () => mockSaveChecklistResponse(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
      },
      build: () => WorkOrderChecklistCubit(useCases: useCases),
      seed: () =>
          const WorkOrderChecklistState.initial().copyWith(items: tItems),
      act: (cubit) => cubit.answerItem(
        workOrderId: tWorkOrderId,
        checklistItemId: tItems.first.id,
        booleanValue: true,
      ),
      expect: () => [
        isA<WorkOrderChecklistState>().having(
          (s) => s.sections[WorkOrderChecklistSections.saveAnswer]?.status,
          'saveAnswer running',
          SectionStatus.running,
        ),
        isA<WorkOrderChecklistState>()
            .having(
              (s) => s.sections[WorkOrderChecklistSections.saveAnswer]?.status,
              'saveAnswer success',
              SectionStatus.success,
            )
            .having(
              (s) => s.answers[tItems.first.id]?.booleanValue,
              'booleanValue',
              isTrue,
            )
            .having(
              (s) => s.areRequiredItemsCompleted,
              'areRequiredItemsCompleted',
              isTrue,
            ),
      ],
    );

    blocTest<WorkOrderChecklistCubit, WorkOrderChecklistState>(
      'answerItem saves multiSelection options and marks item completed',
      setUp: () {
        when(
          () => mockSaveChecklistResponse(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
      },
      build: () => WorkOrderChecklistCubit(useCases: useCases),
      seed: () {
        final multiItem = ChecklistFactory.makeChecklistItemEntity().copyWith(
          isRequired: true,
          type: ChecklistItemType.multiSelection,
          options: ['Opt 1', 'Opt 2'],
        );
        return const WorkOrderChecklistState.initial().copyWith(
          items: [multiItem],
        );
      },
      act: (cubit) => cubit.answerItem(
        workOrderId: tWorkOrderId,
        checklistItemId: cubit.state.items.first.id,
        selectedOptions: ['Opt 1', 'Opt 2'],
      ),
      expect: () => [
        isA<WorkOrderChecklistState>().having(
          (s) => s.sections[WorkOrderChecklistSections.saveAnswer]?.status,
          'saveAnswer running',
          SectionStatus.running,
        ),
        isA<WorkOrderChecklistState>()
            .having(
              (s) => s.sections[WorkOrderChecklistSections.saveAnswer]?.status,
              'saveAnswer success',
              SectionStatus.success,
            )
            .having(
              (s) => s.answers.values.first.selectedOptions,
              'selectedOptions',
              equals(['Opt 1', 'Opt 2']),
            )
            .having(
              (s) => s.areRequiredItemsCompleted,
              'areRequiredItemsCompleted',
              isTrue,
            ),
      ],
    );
  });

  group('attachEvidence', () {
    final tAttachment = MaintenancePlanFactory.makeAttachmentEntity();

    blocTest<WorkOrderChecklistCubit, WorkOrderChecklistState>(
      'uploads the picked file and stores its url on the answer',
      setUp: () {
        when(
          () => mockPickAttachment(any()),
        ).thenAnswer((_) async => SuccessState(data: [tAttachment]));
        when(
          () => mockUploadAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockSaveChecklistResponse(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
      },
      build: () => WorkOrderChecklistCubit(useCases: useCases),
      act: (cubit) => cubit.attachEvidence(
        workOrderId: tWorkOrderId,
        checklistItemId: tItems.first.id,
        source: AttachmentSource.cameraPhoto,
      ),
      verify: (cubit) {
        verify(() => mockUploadAttachment(tAttachment)).called(1);
        expect(
          cubit.state.answers[tItems.first.id]?.photoUrl,
          tAttachment.remoteUrl,
        );
      },
    );

    blocTest<WorkOrderChecklistCubit, WorkOrderChecklistState>(
      'records nothing when the picker is cancelled',
      setUp: () {
        when(
          () => mockPickAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: []));
      },
      build: () => WorkOrderChecklistCubit(useCases: useCases),
      act: (cubit) => cubit.attachEvidence(
        workOrderId: tWorkOrderId,
        checklistItemId: tItems.first.id,
        source: AttachmentSource.cameraPhoto,
      ),
      verify: (cubit) {
        verifyNever(() => mockUploadAttachment(any()));
        verifyNever(() => mockSaveChecklistResponse(any()));
        expect(cubit.state.answers, isEmpty);
      },
    );

    blocTest<WorkOrderChecklistCubit, WorkOrderChecklistState>(
      'falls back to the local path when the upload has no remote url yet',
      setUp: () {
        final offlineAttachment = tAttachment.copyWith(annulRemoteUrl: true);
        when(
          () => mockPickAttachment(any()),
        ).thenAnswer((_) async => SuccessState(data: [offlineAttachment]));
        when(
          () => mockUploadAttachment(any()),
        ).thenAnswer((_) async => const SuccessState(data: false));
        when(
          () => mockSaveChecklistResponse(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
      },
      build: () => WorkOrderChecklistCubit(useCases: useCases),
      act: (cubit) => cubit.attachEvidence(
        workOrderId: tWorkOrderId,
        checklistItemId: tItems.first.id,
        source: AttachmentSource.cameraPhoto,
      ),
      verify: (cubit) {
        expect(
          cubit.state.answers[tItems.first.id]?.photoUrl,
          tAttachment.localPath,
        );
      },
    );
  });

  group('subscribeToRealtime', () {
    blocTest<WorkOrderChecklistCubit, WorkOrderChecklistState>(
      'merges an answer another device wrote into state',
      setUp: () {
        final remoteAnswer = ChecklistFactory.makeChecklistAnswerEntity()
            .copyWith(checklistItemId: tItems.first.id, booleanValue: true);
        when(
          () => mockWatchChecklistAnswers(workOrderId: any(named: 'workOrderId')),
        ).thenAnswer(
          (_) => Stream.value(
            RealtimeEvent<ChecklistAnswerEntity>(
              eventType: RealtimeEventType.update,
              id: remoteAnswer.id,
              companyId: faker.guid.guid(),
              entity: remoteAnswer,
            ),
          ),
        );
      },
      build: () => WorkOrderChecklistCubit(useCases: useCases),
      act: (cubit) => cubit.subscribeToRealtime(tWorkOrderId),
      wait: const Duration(milliseconds: 50),
      verify: (cubit) {
        expect(cubit.state.answers[tItems.first.id]?.booleanValue, isTrue);
      },
    );
  });
}
