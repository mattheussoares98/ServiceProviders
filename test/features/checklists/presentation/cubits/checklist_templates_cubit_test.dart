import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetChecklistsUseCase mockGetChecklists;
  late MockGetChecklistTemplateByIdUseCase mockGetChecklistTemplateById;
  late MockCreateChecklistTemplateUseCase mockCreateChecklistTemplate;
  late MockUpdateChecklistTemplateUseCase mockUpdateChecklistTemplate;
  late MockDeleteChecklistTemplateUseCase mockDeleteChecklistTemplate;
  late MockWatchChecklistTemplatesRealtimeUseCase mockWatchChecklistTemplatesRealtime;
  late MockGetChecklistItemsByTemplateUseCase mockGetChecklistItemsByTemplate;
  late MockCreateChecklistItemUseCase mockCreateChecklistItem;
  late MockUpdateChecklistItemUseCase mockUpdateChecklistItem;
  late MockDeleteChecklistItemUseCase mockDeleteChecklistItem;
  late MockWatchChecklistItemsRealtimeUseCase mockWatchChecklistItemsRealtime;
  late MockNavigationClient mockNavigationClient;
  late ChecklistTemplatesCubitUseCases useCases;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeChecklistTemplateEntity());
    registerFallbackValue(EntityFactory.makeChecklistItemEntity());
  });

  setUp(() {
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockGetChecklists = MockGetChecklistsUseCase();
    mockGetChecklistTemplateById = MockGetChecklistTemplateByIdUseCase();
    mockCreateChecklistTemplate = MockCreateChecklistTemplateUseCase();
    mockUpdateChecklistTemplate = MockUpdateChecklistTemplateUseCase();
    mockDeleteChecklistTemplate = MockDeleteChecklistTemplateUseCase();
    mockWatchChecklistTemplatesRealtime = MockWatchChecklistTemplatesRealtimeUseCase();
    mockGetChecklistItemsByTemplate = MockGetChecklistItemsByTemplateUseCase();
    mockCreateChecklistItem = MockCreateChecklistItemUseCase();
    mockUpdateChecklistItem = MockUpdateChecklistItemUseCase();
    mockDeleteChecklistItem = MockDeleteChecklistItemUseCase();
    mockWatchChecklistItemsRealtime = MockWatchChecklistItemsRealtimeUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    useCases = ChecklistTemplatesCubitUseCases(
      getActiveCompanyId: mockGetActiveCompanyId,
      getChecklists: mockGetChecklists,
      getChecklistTemplateById: mockGetChecklistTemplateById,
      createChecklistTemplate: mockCreateChecklistTemplate,
      updateChecklistTemplate: mockUpdateChecklistTemplate,
      deleteChecklistTemplate: mockDeleteChecklistTemplate,
      watchChecklistTemplatesRealtime: mockWatchChecklistTemplatesRealtime,
      getChecklistItemsByTemplate: mockGetChecklistItemsByTemplate,
      createChecklistItem: mockCreateChecklistItem,
      updateChecklistItem: mockUpdateChecklistItem,
      deleteChecklistItem: mockDeleteChecklistItem,
      watchChecklistItemsRealtime: mockWatchChecklistItemsRealtime,
    );
  });

  tearDown(GetIt.I.reset);

  final tCompanyId = faker.guid.guid();
  final tTemplates = EntityFactory.makeChecklistTemplateEntityList();
  final tItems = EntityFactory.makeChecklistItemEntityList();

  group('ChecklistTemplatesCubit', () {
    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'loadTemplates emits [running, success] with templates',
      setUp: () {
        when(() => mockGetActiveCompanyId()).thenReturn(tCompanyId);
        when(() => mockGetChecklists(any()))
            .thenAnswer((_) async => SuccessState(data: tTemplates));
      },
      build: () => ChecklistTemplatesCubit(useCases: useCases),
      act: (cubit) => cubit.loadTemplates(),
      expect: () => [
        isA<ChecklistTemplatesState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'sections.load',
          SectionStatus.running,
        ),
        isA<ChecklistTemplatesState>()
            .having(
              (s) => s.sections[BaseSections.load]?.status,
              'sections.load',
              SectionStatus.success,
            )
            .having((s) => s.templates, 'templates', equals(tTemplates)),
      ],
    );

    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'selectTemplate updates selectedTemplate and loads its items',
      setUp: () {
        when(() => mockGetChecklistItemsByTemplate(any()))
            .thenAnswer((_) async => SuccessState(data: tItems));
      },
      build: () => ChecklistTemplatesCubit(useCases: useCases),
      act: (cubit) => cubit.selectTemplate(tTemplates.first),
      expect: () => [
        isA<ChecklistTemplatesState>().having(
          (s) => s.selectedTemplate,
          'selectedTemplate',
          equals(tTemplates.first),
        ),
        isA<ChecklistTemplatesState>().having(
          (s) => s.sections[ChecklistTemplatesSections.loadItems]?.status,
          'loadItems running',
          SectionStatus.running,
        ),
        isA<ChecklistTemplatesState>()
            .having(
              (s) => s.sections[ChecklistTemplatesSections.loadItems]?.status,
              'loadItems success',
              SectionStatus.success,
            )
            .having((s) => s.templateItems, 'templateItems', equals(tItems)),
      ],
    );

    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'saveTemplate creates new template and reloads list',
      setUp: () {
        when(() => mockGetActiveCompanyId()).thenReturn(tCompanyId);
        when(() => mockCreateChecklistTemplate(any()))
            .thenAnswer((_) async => const SuccessState(data: true));
        when(() => mockGetChecklists(any()))
            .thenAnswer((_) async => SuccessState(data: tTemplates));
      },
      build: () => ChecklistTemplatesCubit(useCases: useCases),
      act: (cubit) => cubit.saveTemplate(
        id: null,
        name: 'Novo Checklist',
        description: 'Descrição de teste',
      ),
      expect: () => [
        isA<ChecklistTemplatesState>().having(
          (s) => s.sections[ChecklistTemplatesSections.saveTemplate]?.status,
          'saveTemplate running',
          SectionStatus.running,
        ),
        isA<ChecklistTemplatesState>()
            .having(
              (s) => s.sections[ChecklistTemplatesSections.saveTemplate]?.status,
              'saveTemplate success',
              SectionStatus.success,
            )
            .having((s) => s.selectedTemplate?.name, 'selectedTemplate.name', 'Novo Checklist'),
        isA<ChecklistTemplatesState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'load success',
          SectionStatus.success,
        ),
      ],
    );

    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'deleteTemplate removes template and reloads',
      setUp: () {
        when(() => mockGetActiveCompanyId()).thenReturn(tCompanyId);
        when(() => mockDeleteChecklistTemplate(any()))
            .thenAnswer((_) async => const SuccessState(data: true));
        when(() => mockGetChecklists(any()))
            .thenAnswer((_) async => SuccessState(data: tTemplates));
      },
      build: () => ChecklistTemplatesCubit(useCases: useCases),
      seed: () => const ChecklistTemplatesState.initial().copyWith(
        templates: tTemplates,
      ),
      act: (cubit) => cubit.deleteTemplate(tTemplates.first.id),
      expect: () => [
        isA<ChecklistTemplatesState>().having(
          (s) => s.sections[ChecklistTemplatesSections.deleteTemplate]?.status,
          'deleteTemplate running',
          SectionStatus.running,
        ),
        isA<ChecklistTemplatesState>()
            .having(
              (s) => s.sections[ChecklistTemplatesSections.deleteTemplate]?.status,
              'deleteTemplate success',
              SectionStatus.success,
            )
            .having((s) => s.templates.length, 'templates.length', equals(tTemplates.length - 1)),
        isA<ChecklistTemplatesState>().having(
          (s) => s.sections[BaseSections.load]?.status,
          'load success',
          SectionStatus.success,
        ),
      ],
    );

    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'saveItem saves checklist item and reloads template items',
      setUp: () {
        when(() => mockGetActiveCompanyId()).thenReturn(tCompanyId);
        when(() => mockCreateChecklistItem(any()))
            .thenAnswer((_) async => const SuccessState(data: true));
        when(() => mockGetChecklistItemsByTemplate(any()))
            .thenAnswer((_) async => SuccessState(data: tItems));
      },
      build: () => ChecklistTemplatesCubit(useCases: useCases),
      act: (cubit) => cubit.saveItem(
        id: null,
        templateId: tTemplates.first.id,
        label: 'Verificar pressão',
        type: ChecklistItemType.boolean,
        isRequired: true,
      ),
      expect: () => [
        isA<ChecklistTemplatesState>().having(
          (s) => s.sections[ChecklistTemplatesSections.saveItem]?.status,
          'saveItem running',
          SectionStatus.running,
        ),
        isA<ChecklistTemplatesState>().having(
          (s) => s.sections[ChecklistTemplatesSections.saveItem]?.status,
          'saveItem success',
          SectionStatus.success,
        ),
        isA<ChecklistTemplatesState>().having(
          (s) => s.sections[ChecklistTemplatesSections.loadItems]?.status,
          'loadItems success',
          SectionStatus.success,
        ),
      ],
    );
  });
}
