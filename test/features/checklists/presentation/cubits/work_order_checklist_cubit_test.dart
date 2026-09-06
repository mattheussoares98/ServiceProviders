import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/work_order_checklist/work_order_checklist_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/checklist_factory.dart';
import '../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetChecklistItemsByTemplateUseCase mockGetChecklistItemsByTemplate;
  late MockGetWorkOrderChecklistAnswersUseCase mockGetWorkOrderChecklistAnswers;
  late MockSaveChecklistResponseUseCase mockSaveChecklistResponse;
  late MockNavigationClient mockNavigationClient;
  late WorkOrderChecklistCubitUseCases useCases;

  setUpAll(() {
    registerFallbackValue(ChecklistFactory.makeChecklistAnswerEntity());
  });

  setUp(() {
    mockGetChecklistItemsByTemplate = MockGetChecklistItemsByTemplateUseCase();
    mockGetWorkOrderChecklistAnswers =
        MockGetWorkOrderChecklistAnswersUseCase();
    mockSaveChecklistResponse = MockSaveChecklistResponseUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    useCases = WorkOrderChecklistCubitUseCases(
      getChecklistItemsByTemplate: mockGetChecklistItemsByTemplate,
      getWorkOrderChecklistAnswers: mockGetWorkOrderChecklistAnswers,
      saveChecklistResponse: mockSaveChecklistResponse,
    );
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
  });
}
