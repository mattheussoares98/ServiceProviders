import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/create_checklist_item_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/create_checklist_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/delete_checklist_item_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/delete_checklist_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklist_items_by_template_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklist_template_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_checklists_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/get_work_order_checklist_answers_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/save_checklist_response_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/update_checklist_item_use_case.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/use_cases/update_checklist_template_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockChecklistsRepository mockRepository;

  setUp(() {
    mockRepository = MockChecklistsRepository();
    registerFallbackValue(EntityFactory.makeChecklistTemplateEntity());
    registerFallbackValue(EntityFactory.makeChecklistItemEntity());
    registerFallbackValue(EntityFactory.makeChecklistAnswerEntity());
  });

  group('Checklists Use Cases', () {
    group('GetChecklistsUseCase', () {
      test('calls repository.getTemplates and returns result', () async {
        final useCase = GetChecklistsUseCase(
          checklistsRepository: mockRepository,
        );
        final list = EntityFactory.makeChecklistTemplateEntityList();
        final companyId = faker.guid.guid();

        when(
          () => mockRepository.getTemplates(any()),
        ).thenAnswer((_) async => SuccessState(data: list));

        final result = await useCase(companyId);

        expect(result, isA<SuccessState<List<ChecklistTemplateEntity>>>());
        expect(result.data, equals(list));
        verify(() => mockRepository.getTemplates(companyId)).called(1);
      });

      test('returns FailureState when repository fails', () async {
        final useCase = GetChecklistsUseCase(
          checklistsRepository: mockRepository,
        );
        final companyId = faker.guid.guid();

        when(() => mockRepository.getTemplates(any())).thenAnswer(
          (_) async =>
              FailureState<List<ChecklistTemplateEntity>>(message: 'Error'),
        );

        final result = await useCase(companyId);

        expect(result, isA<FailureState<List<ChecklistTemplateEntity>>>());
        verify(() => mockRepository.getTemplates(companyId)).called(1);
      });
    });

    group('GetChecklistTemplateByIdUseCase', () {
      test('calls repository.getTemplateById and returns result', () async {
        final useCase = GetChecklistTemplateByIdUseCase(
          checklistsRepository: mockRepository,
        );
        final template = EntityFactory.makeChecklistTemplateEntity();
        final id = faker.guid.guid();

        when(
          () => mockRepository.getTemplateById(any()),
        ).thenAnswer((_) async => SuccessState(data: template));

        final result = await useCase(id);

        expect(result, isA<SuccessState<ChecklistTemplateEntity>>());
        expect(result.data, equals(template));
        verify(() => mockRepository.getTemplateById(id)).called(1);
      });
    });

    group('CreateChecklistTemplateUseCase', () {
      test('calls repository.createTemplate and returns result', () async {
        final useCase = CreateChecklistTemplateUseCase(
          checklistsRepository: mockRepository,
        );
        final template = EntityFactory.makeChecklistTemplateEntity();

        when(
          () => mockRepository.createTemplate(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await useCase(template);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.createTemplate(template)).called(1);
      });
    });

    group('UpdateChecklistTemplateUseCase', () {
      test('calls repository.updateTemplate and returns result', () async {
        final useCase = UpdateChecklistTemplateUseCase(
          checklistsRepository: mockRepository,
        );
        final template = EntityFactory.makeChecklistTemplateEntity();

        when(
          () => mockRepository.updateTemplate(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await useCase(template);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.updateTemplate(template)).called(1);
      });
    });

    group('DeleteChecklistTemplateUseCase', () {
      test('calls repository.deleteTemplate and returns result', () async {
        final useCase = DeleteChecklistTemplateUseCase(
          checklistsRepository: mockRepository,
        );
        final id = faker.guid.guid();

        when(
          () => mockRepository.deleteTemplate(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await useCase(id);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.deleteTemplate(id)).called(1);
      });
    });

    group('GetChecklistItemsByTemplateUseCase', () {
      test('calls repository.getItemsByTemplate and returns result', () async {
        final useCase = GetChecklistItemsByTemplateUseCase(
          checklistsRepository: mockRepository,
        );
        final items = EntityFactory.makeChecklistItemEntityList();
        final templateId = faker.guid.guid();

        when(
          () => mockRepository.getItemsByTemplate(any()),
        ).thenAnswer((_) async => SuccessState(data: items));

        final result = await useCase(templateId);

        expect(result, isA<SuccessState<List<ChecklistItemEntity>>>());
        expect(result.data, equals(items));
        verify(() => mockRepository.getItemsByTemplate(templateId)).called(1);
      });
    });

    group('CreateChecklistItemUseCase', () {
      test('calls repository.createItem and returns result', () async {
        final useCase = CreateChecklistItemUseCase(
          checklistsRepository: mockRepository,
        );
        final item = EntityFactory.makeChecklistItemEntity();

        when(
          () => mockRepository.createItem(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await useCase(item);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.createItem(item)).called(1);
      });
    });

    group('UpdateChecklistItemUseCase', () {
      test('calls repository.updateItem and returns result', () async {
        final useCase = UpdateChecklistItemUseCase(
          checklistsRepository: mockRepository,
        );
        final item = EntityFactory.makeChecklistItemEntity();

        when(
          () => mockRepository.updateItem(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await useCase(item);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.updateItem(item)).called(1);
      });
    });

    group('DeleteChecklistItemUseCase', () {
      test('calls repository.deleteItem and returns result', () async {
        final useCase = DeleteChecklistItemUseCase(
          checklistsRepository: mockRepository,
        );
        final id = faker.guid.guid();

        when(
          () => mockRepository.deleteItem(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await useCase(id);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.deleteItem(id)).called(1);
      });
    });

    group('GetWorkOrderChecklistAnswersUseCase', () {
      test(
        'calls repository.getResponsesByWorkOrder and returns result',
        () async {
          final useCase = GetWorkOrderChecklistAnswersUseCase(
            checklistsRepository: mockRepository,
          );
          final answers = EntityFactory.makeChecklistAnswerEntityList();
          final workOrderId = faker.guid.guid();

          when(
            () => mockRepository.getResponsesByWorkOrder(any()),
          ).thenAnswer((_) async => SuccessState(data: answers));

          final result = await useCase(workOrderId);

          expect(result, isA<SuccessState<List<ChecklistAnswerEntity>>>());
          expect(result.data, equals(answers));
          verify(
            () => mockRepository.getResponsesByWorkOrder(workOrderId),
          ).called(1);
        },
      );
    });

    group('SaveChecklistResponseUseCase', () {
      test('calls repository.saveResponse and returns result', () async {
        final useCase = SaveChecklistResponseUseCase(
          checklistsRepository: mockRepository,
        );
        final answer = EntityFactory.makeChecklistAnswerEntity();

        when(
          () => mockRepository.saveResponse(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await useCase(answer);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.saveResponse(answer)).called(1);
      });
    });
  });
}
