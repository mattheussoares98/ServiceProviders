import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_answer_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_item_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_template_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/repositories/checklists_repository_impl.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternet;
  late MockChecklistsRemoteDataSource mockRemoteDataSource;
  late MockChecklistsLocalDataSource mockLocalDataSource;
  late ChecklistsRepositoryImpl repository;

  setUp(() {
    mockInternet = MockInternetClient();
    mockRemoteDataSource = MockChecklistsRemoteDataSource();
    mockLocalDataSource = MockChecklistsLocalDataSource();
    repository = ChecklistsRepositoryImpl(
      internet: mockInternet,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );

    registerFallbackValue(
      ChecklistTemplateModel.fromEntity(
        EntityFactory.makeChecklistTemplateEntity(),
      ),
    );
    registerFallbackValue(
      ChecklistItemModel.fromEntity(EntityFactory.makeChecklistItemEntity()),
    );
    registerFallbackValue(
      ChecklistAnswerModel.fromEntity(
        EntityFactory.makeChecklistAnswerEntity(),
      ),
    );
  });

  final tTemplateEntity = EntityFactory.makeChecklistTemplateEntity();
  final tTemplateModel = ChecklistTemplateModel.fromEntity(tTemplateEntity);
  final tTemplateEntityList = EntityFactory.makeChecklistTemplateEntityList();
  final tTemplateModelList = tTemplateEntityList
      .map(ChecklistTemplateModel.fromEntity)
      .toList();

  final tItemEntity = EntityFactory.makeChecklistItemEntity();
  final tItemModel = ChecklistItemModel.fromEntity(tItemEntity);
  final tItemEntityList = EntityFactory.makeChecklistItemEntityList();
  final tItemModelList = tItemEntityList
      .map(ChecklistItemModel.fromEntity)
      .toList();

  final tAnswerEntity = EntityFactory.makeChecklistAnswerEntity();
  final tAnswerModel = ChecklistAnswerModel.fromEntity(tAnswerEntity);
  final tAnswerEntityList = EntityFactory.makeChecklistAnswerEntityList();
  final tAnswerModelList = tAnswerEntityList
      .map(ChecklistAnswerModel.fromEntity)
      .toList();

  group('ChecklistsRepositoryImpl', () {
    group('Templates', () {
      test('getTemplates calls remote when internet is connected', () async {
        final companyId = faker.guid.guid();
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getTemplates(any()),
        ).thenAnswer((_) async => SuccessState(data: tTemplateModelList));
        when(
          () => mockLocalDataSource.saveTemplate(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getTemplates(companyId);

        expect(result, isA<SuccessState<List<ChecklistTemplateEntity>>>());
        expect(result.data, equals(tTemplateEntityList));
        verify(() => mockRemoteDataSource.getTemplates(companyId)).called(1);
      });

      test(
        'getTemplates falls back to local when internet is offline',
        () async {
          final companyId = faker.guid.guid();
          when(() => mockInternet.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.getTemplates(any()),
          ).thenAnswer((_) async => SuccessState(data: tTemplateModelList));

          final result = await repository.getTemplates(companyId);

          expect(result, isA<SuccessState<List<ChecklistTemplateEntity>>>());
          expect(result.data, equals(tTemplateEntityList));
          verify(() => mockLocalDataSource.getTemplates(companyId)).called(1);
        },
      );

      test('getTemplateById calls remote when online', () async {
        final id = faker.guid.guid();
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getTemplateById(any()),
        ).thenAnswer((_) async => SuccessState(data: tTemplateModel));
        when(
          () => mockLocalDataSource.saveTemplate(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getTemplateById(id);

        expect(result, isA<SuccessState<ChecklistTemplateEntity>>());
        expect(result.data, equals(tTemplateEntity));
        verify(() => mockRemoteDataSource.getTemplateById(id)).called(1);
      });

      test('createTemplate saves to remote and mirrors locally', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.createTemplate(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.saveTemplate(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createTemplate(tTemplateEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(
          () => mockRemoteDataSource.createTemplate(tTemplateModel),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveTemplate(tTemplateModel),
        ).called(1);
      });

      test('deleteTemplate deletes from remote and local', () async {
        final id = faker.guid.guid();
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.deleteTemplate(any()),
        ).thenAnswer((_) async => SuccessState.nil);
        when(
          () => mockLocalDataSource.deleteTemplate(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteTemplate(id);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRemoteDataSource.deleteTemplate(id)).called(1);
        verify(() => mockLocalDataSource.deleteTemplate(id)).called(1);
      });
    });

    group('Items', () {
      test(
        'getItemsByTemplate calls remote and saves locally when online',
        () async {
          final templateId = faker.guid.guid();
          when(() => mockInternet.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getItemsByTemplate(any()),
          ).thenAnswer((_) async => SuccessState(data: tItemModelList));
          when(
            () => mockLocalDataSource.saveItem(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.getItemsByTemplate(templateId);

          expect(result, isA<SuccessState<List<ChecklistItemEntity>>>());
          expect(result.data, equals(tItemEntityList));
          verify(
            () => mockRemoteDataSource.getItemsByTemplate(templateId),
          ).called(1);
        },
      );

      test('createItem saves remote and mirrors locally', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.createItem(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.saveItem(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createItem(tItemEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRemoteDataSource.createItem(tItemModel)).called(1);
        verify(() => mockLocalDataSource.saveItem(tItemModel)).called(1);
      });

      test('deleteItem deletes on remote and locally', () async {
        final id = faker.guid.guid();
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.deleteItem(any()),
        ).thenAnswer((_) async => SuccessState.nil);
        when(
          () => mockLocalDataSource.deleteItem(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteItem(id);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRemoteDataSource.deleteItem(id)).called(1);
        verify(() => mockLocalDataSource.deleteItem(id)).called(1);
      });
    });

    group('Responses', () {
      test(
        'getResponsesByWorkOrder calls remote and mirrors locally when online',
        () async {
          final workOrderId = faker.guid.guid();
          when(() => mockInternet.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getResponsesByWorkOrder(any()),
          ).thenAnswer((_) async => SuccessState(data: tAnswerModelList));
          when(
            () => mockLocalDataSource.saveResponse(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.getResponsesByWorkOrder(workOrderId);

          expect(result, isA<SuccessState<List<ChecklistAnswerEntity>>>());
          expect(result.data, equals(tAnswerEntityList));
          verify(
            () => mockRemoteDataSource.getResponsesByWorkOrder(workOrderId),
          ).called(1);
        },
      );

      test('saveResponse saves to remote and mirrors locally', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.saveResponse(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.saveResponse(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.saveResponse(tAnswerEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRemoteDataSource.saveResponse(tAnswerModel)).called(1);
        verify(() => mockLocalDataSource.saveResponse(tAnswerModel)).called(1);
      });
    });
  });
}
