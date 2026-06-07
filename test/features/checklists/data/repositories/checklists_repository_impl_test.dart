import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/checklists/data/models/responses/checklist_item_response_model.dart';
import 'package:clean_architecture/features/checklists/data/models/responses/checklist_template_response_model.dart';
import 'package:clean_architecture/features/checklists/data/repositories/checklists_repository_impl.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
      ChecklistTemplateResponseModel.fromEntity(
        EntityFactory.makeChecklistTemplateEntity(),
      ),
    );
    registerFallbackValue(
      ChecklistItemResponseModel.fromEntity(
        EntityFactory.makeChecklistItemEntity(),
      ),
    );
  });

  final tTemplateEntity = EntityFactory.makeChecklistTemplateEntity();
  final tTemplateModel = ChecklistTemplateResponseModel.fromEntity(tTemplateEntity);
  final tTemplateEntityList = EntityFactory.makeChecklistTemplateEntityList();
  final tTemplateModelList = tTemplateEntityList
      .map(ChecklistTemplateResponseModel.fromEntity)
      .toList();

  final tItemEntity = EntityFactory.makeChecklistItemEntity();
  final tItemModel = ChecklistItemResponseModel.fromEntity(tItemEntity);
  final tItemEntityList = EntityFactory.makeChecklistItemEntityList();
  final tItemModelList = tItemEntityList
      .map(ChecklistItemResponseModel.fromEntity)
      .toList();

  group('ChecklistsRepositoryImpl', () {
    group('Templates', () {
      test('getTemplates should return list of templates from local data source', () async {
        // Arrange
        final companyId = faker.guid.guid();
        when(() => mockLocalDataSource.getTemplates(any()))
            .thenAnswer((_) async => SuccessState(data: tTemplateModelList));

        // Act
        final result = await repository.getTemplates(companyId);

        // Assert
        expect(result, isA<SuccessState<List<ChecklistTemplateEntity>>>());
        expect(result.data, equals(tTemplateEntityList));
        verify(() => mockLocalDataSource.getTemplates(companyId)).called(1);
      });

      test('getTemplateById should return single template from local data source', () async {
        // Arrange
        final id = faker.guid.guid();
        when(() => mockLocalDataSource.getTemplateById(any()))
            .thenAnswer((_) async => SuccessState(data: tTemplateModel));

        // Act
        final result = await repository.getTemplateById(id);

        // Assert
        expect(result, isA<SuccessState<ChecklistTemplateEntity>>());
        expect(result.data, equals(tTemplateEntity));
        verify(() => mockLocalDataSource.getTemplateById(id)).called(1);
      });

      test('createTemplate should return true when local save is successful', () async {
        // Arrange
        when(() => mockLocalDataSource.saveTemplate(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.createTemplate(tTemplateEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.saveTemplate(tTemplateModel)).called(1);
      });

      test('updateTemplate should return true when local save is successful', () async {
        // Arrange
        when(() => mockLocalDataSource.saveTemplate(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.updateTemplate(tTemplateEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.saveTemplate(tTemplateModel)).called(1);
      });

      test('deleteTemplate should return true when local delete is successful', () async {
        // Arrange
        final id = faker.guid.guid();
        when(() => mockLocalDataSource.deleteTemplate(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.deleteTemplate(id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.deleteTemplate(id)).called(1);
      });
    });

    group('Items', () {
      test('getItemsByTemplate should return list of items from local data source', () async {
        // Arrange
        final templateId = faker.guid.guid();
        when(() => mockLocalDataSource.getItemsByTemplate(any()))
            .thenAnswer((_) async => SuccessState(data: tItemModelList));

        // Act
        final result = await repository.getItemsByTemplate(templateId);

        // Assert
        expect(result, isA<SuccessState<List<ChecklistItemEntity>>>());
        expect(result.data, equals(tItemEntityList));
        verify(() => mockLocalDataSource.getItemsByTemplate(templateId)).called(1);
      });

      test('createItem should return true when local save is successful', () async {
        // Arrange
        when(() => mockLocalDataSource.saveItem(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.createItem(tItemEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.saveItem(tItemModel)).called(1);
      });

      test('updateItem should return true when local save is successful', () async {
        // Arrange
        when(() => mockLocalDataSource.saveItem(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.updateItem(tItemEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.saveItem(tItemModel)).called(1);
      });

      test('deleteItem should return true when local delete is successful', () async {
        // Arrange
        final id = faker.guid.guid();
        when(() => mockLocalDataSource.deleteItem(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.deleteItem(id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.deleteItem(id)).called(1);
      });
    });
  });
}
