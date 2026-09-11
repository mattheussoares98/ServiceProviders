import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/checklist_factory.dart';
import '../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetChecklistsUseCase mockGetChecklists;
  late MockGetChecklistTemplateByIdUseCase mockGetChecklistTemplateById;
  late MockCreateChecklistTemplateUseCase mockCreateChecklistTemplate;
  late MockUpdateChecklistTemplateUseCase mockUpdateChecklistTemplate;
  late MockDeleteChecklistTemplateUseCase mockDeleteChecklistTemplate;
  late MockWatchChecklistTemplatesRealtimeUseCase
  mockWatchChecklistTemplatesRealtime;
  late MockGetChecklistItemsByTemplateUseCase mockGetChecklistItemsByTemplate;
  late MockCreateChecklistItemUseCase mockCreateChecklistItem;
  late MockUpdateChecklistItemUseCase mockUpdateChecklistItem;
  late MockDeleteChecklistItemUseCase mockDeleteChecklistItem;
  late MockWatchChecklistItemsRealtimeUseCase mockWatchChecklistItemsRealtime;
  late MockNavigationClient mockNavigationClient;
  late ChecklistTemplatesCubitUseCases useCases;

  setUpAll(() {
    registerFallbackValue(ChecklistFactory.makeChecklistTemplateEntity());
    registerFallbackValue(ChecklistFactory.makeChecklistItemEntity());
    registerFallbackValue(
      CreateUpdateChecklistTemplateRoute(
        template: ChecklistFactory.makeChecklistTemplateEntity(),
      ),
    );
    registerFallbackValue(
      CreateUpdateChecklistItemRoute(
        templateId: ChecklistFactory.makeChecklistItemEntity().templateId,
      ),
    );
  });

  setUp(() {
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockGetChecklists = MockGetChecklistsUseCase();
    mockGetChecklistTemplateById = MockGetChecklistTemplateByIdUseCase();
    mockCreateChecklistTemplate = MockCreateChecklistTemplateUseCase();
    mockUpdateChecklistTemplate = MockUpdateChecklistTemplateUseCase();
    mockDeleteChecklistTemplate = MockDeleteChecklistTemplateUseCase();
    mockWatchChecklistTemplatesRealtime =
        MockWatchChecklistTemplatesRealtimeUseCase();
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

    when(() => mockGetActiveCompanyId()).thenReturn('default-company-id');
    when(() => mockWatchChecklistTemplatesRealtime(companyId: any(named: 'companyId')))
        .thenAnswer((_) => const Stream.empty());
    when(() => mockWatchChecklistItemsRealtime(companyId: any(named: 'companyId')))
        .thenAnswer((_) => const Stream.empty());
  });

  tearDown(GetIt.I.reset);

  final tCompanyId = faker.guid.guid();
  final tTemplates = ChecklistFactory.makeChecklistTemplateEntityList();
  final tItems = ChecklistFactory.makeChecklistItemEntityList();

  group('ChecklistTemplatesCubit', () {
    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'loadTemplates emits [running, success] with templates',
      setUp: () {
        when(() => mockGetActiveCompanyId()).thenReturn(tCompanyId);
        when(
          () => mockGetChecklists(any()),
        ).thenAnswer((_) async => SuccessState(data: tTemplates));
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
        when(
          () => mockGetChecklistItemsByTemplate(any()),
        ).thenAnswer((_) async => SuccessState(data: tItems));
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
        when(
          () => mockCreateChecklistTemplate(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockGetChecklists(any()),
        ).thenAnswer((_) async => SuccessState(data: tTemplates));
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
              (s) =>
                  s.sections[ChecklistTemplatesSections.saveTemplate]?.status,
              'saveTemplate success',
              SectionStatus.success,
            )
            .having(
              (s) => s.selectedTemplate?.name,
              'selectedTemplate.name',
              'Novo Checklist',
            ),
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
        when(
          () => mockDeleteChecklistTemplate(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockGetChecklists(any()),
        ).thenAnswer((_) async => SuccessState(data: tTemplates));
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
              (s) =>
                  s.sections[ChecklistTemplatesSections.deleteTemplate]?.status,
              'deleteTemplate success',
              SectionStatus.success,
            )
            .having(
              (s) => s.templates.length,
              'templates.length',
              equals(tTemplates.length - 1),
            ),
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
        when(
          () => mockCreateChecklistItem(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockGetChecklistItemsByTemplate(any()),
        ).thenAnswer((_) async => SuccessState(data: tItems));
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

  group('Navigation', () {
    final tTemplate = ChecklistFactory.makeChecklistTemplateEntity();
    final tItem = ChecklistFactory.makeChecklistItemEntity();

    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'navigateToCreateUpdateTemplate pushes the route and reloads templates',
      setUp: () {
        when(
          () => mockNavigationClient
              .pushRoute<CreateUpdateChecklistTemplateRouteArgs>(any()),
        ).thenAnswer((_) async => null);
        when(() => mockGetActiveCompanyId()).thenReturn(tTemplate.companyId);
        when(
          () => mockGetChecklists(any()),
        ).thenAnswer((_) async => SuccessState(data: [tTemplate]));
      },
      build: () => ChecklistTemplatesCubit(useCases: useCases),
      act: (cubit) => cubit.navigateToCreateUpdateTemplate(template: tTemplate),
      verify: (_) {
        verify(
          () => mockNavigationClient
              .pushRoute<CreateUpdateChecklistTemplateRouteArgs>(any()),
        ).called(1);
        verify(() => mockGetChecklists(any())).called(1);
      },
    );

    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'navigateToCreateUpdateItem pushes the route and reloads the items',
      setUp: () {
        when(
          () => mockNavigationClient
              .pushRoute<CreateUpdateChecklistItemRouteArgs>(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockGetChecklistItemsByTemplate(any()),
        ).thenAnswer((_) async => SuccessState(data: [tItem]));
      },
      build: () => ChecklistTemplatesCubit(useCases: useCases),
      act: (cubit) => cubit.navigateToCreateUpdateItem(
        templateId: tItem.templateId,
        item: tItem,
      ),
      verify: (_) {
        verify(
          () => mockNavigationClient
              .pushRoute<CreateUpdateChecklistItemRouteArgs>(any()),
        ).called(1);
        verify(
          () => mockGetChecklistItemsByTemplate(tItem.templateId),
        ).called(1);
      },
    );
  });

  group('reorderItems', () {
    final tTemplateId = ChecklistFactory.makeChecklistTemplateEntity().id;
    List<ChecklistItemEntity> orderedItems() => [
      for (var index = 0; index < 3; index++)
        ChecklistFactory.makeChecklistItemEntity().copyWith(
          templateId: tTemplateId,
          sortOrder: index,
        ),
    ];

    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'renumbers the displaced run and persists only what moved',
      setUp: () {
        when(
          () => mockUpdateChecklistItem(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
      },
      build: () => ChecklistTemplatesCubit(useCases: useCases),
      seed: () => ChecklistTemplatesState(
        templates: const [],
        templateItems: orderedItems(),
      ),
      act: (cubit) =>
          cubit.reorderItems(templateId: tTemplateId, oldIndex: 0, newIndex: 2),
      verify: (cubit) {
        expect(
          cubit.state.templateItems.map((e) => e.sortOrder),
          [0, 1, 2],
        );
        // The item that was first is now last.
        expect(cubit.state.templateItems.last.sortOrder, 2);
        // All three shifted, so all three persist.
        verify(() => mockUpdateChecklistItem(any())).called(3);
      },
    );

    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'does nothing when the item is dropped where it started',
      build: () => ChecklistTemplatesCubit(useCases: useCases),
      seed: () => ChecklistTemplatesState(
        templates: const [],
        templateItems: orderedItems(),
      ),
      act: (cubit) =>
          cubit.reorderItems(templateId: tTemplateId, oldIndex: 1, newIndex: 1),
      expect: () => <ChecklistTemplatesState>[],
      verify: (_) => verifyNever(() => mockUpdateChecklistItem(any())),
    );

    blocTest<ChecklistTemplatesCubit, ChecklistTemplatesState>(
      'reloads from source when a persist fails',
      setUp: () {
        when(
          () => mockUpdateChecklistItem(any()),
        ).thenAnswer((_) async => FailureState<bool>(message: faker.lorem.word()));
        when(
          () => mockGetChecklistItemsByTemplate(any()),
        ).thenAnswer((_) async => SuccessState(data: orderedItems()));
      },
      build: () => ChecklistTemplatesCubit(useCases: useCases),
      seed: () => ChecklistTemplatesState(
        templates: const [],
        templateItems: orderedItems(),
      ),
      act: (cubit) =>
          cubit.reorderItems(templateId: tTemplateId, oldIndex: 0, newIndex: 2),
      verify: (_) {
        verify(() => mockGetChecklistItemsByTemplate(tTemplateId)).called(1);
      },
    );
  });
}
