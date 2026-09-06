import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/data/data_sources/checklists_local_data_source.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_answer_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_item_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_template_model.dart';

import '../../../../../testing/mocks/factories/checklist_factory.dart';

void main() {
  late AppDatabase database;
  late ChecklistsLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ChecklistsLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertDependencies({
    required String companyId,
    String? categoryId,
    String? workOrderId,
  }) async {
    await database
        .into(database.companies)
        .insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );

    if (categoryId != null) {
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: categoryId,
              companyId: companyId,
              name: faker.company.name(),
            ),
          );
    }

    if (workOrderId != null) {
      final locId = faker.guid.guid();
      await database
          .into(database.locations)
          .insert(
            LocationsCompanion.insert(
              id: locId,
              companyId: companyId,
              name: faker.company.name(),
              isActive: const Value(true),
            ),
          );

      await database
          .into(database.workOrders)
          .insert(
            WorkOrdersCompanion.insert(
              id: workOrderId,
              companyId: companyId,
              locationId: locId,
              title: faker.job.title(),
            ),
          );
    }
  }

  final tTemplateEntity = ChecklistFactory.makeChecklistTemplateEntity();
  final tTemplateModel = ChecklistTemplateModel.fromEntity(tTemplateEntity);

  final tItemEntity = ChecklistFactory.makeChecklistItemEntity();
  final tItemModel = ChecklistItemModel.fromEntity(tItemEntity);

  final tAnswerEntity = ChecklistFactory.makeChecklistAnswerEntity();
  final tAnswerModel = ChecklistAnswerModel.fromEntity(tAnswerEntity);

  group('ChecklistsLocalDataSource - Templates', () {
    test('saveTemplate and getTemplates / getTemplateById', () async {
      await insertDependencies(
        companyId: tTemplateModel.companyId,
        categoryId: tTemplateModel.categoryId,
      );

      final saveResult = await dataSource.saveTemplate(tTemplateModel);
      expect(saveResult, isA<SuccessState<bool>>());
      expect(saveResult.data, isTrue);

      final listResult = await dataSource.getTemplates(
        tTemplateModel.companyId,
      );
      expect(listResult, isA<SuccessState<List<ChecklistTemplateModel>>>());
      expect(listResult.data, hasLength(1));
      expect(listResult.data!.first.id, tTemplateModel.id);

      final singleResult = await dataSource.getTemplateById(tTemplateModel.id);
      expect(singleResult, isA<SuccessState<ChecklistTemplateModel>>());
      expect(singleResult.data!.id, tTemplateModel.id);
    });

    test('getTemplateById returns FailureState when not found', () async {
      final result = await dataSource.getTemplateById(faker.guid.guid());
      expect(result, isA<FailureState<ChecklistTemplateModel>>());
      expect(result.message, 'Template de checklist não encontrado'.hardcoded);
    });

    test('deleteTemplate soft deletes template', () async {
      await insertDependencies(
        companyId: tTemplateModel.companyId,
        categoryId: tTemplateModel.categoryId,
      );
      await dataSource.saveTemplate(tTemplateModel);

      final deleteResult = await dataSource.deleteTemplate(tTemplateModel.id);
      expect(deleteResult, isA<SuccessState<bool>>());
      expect(deleteResult.data, isTrue);

      final listResult = await dataSource.getTemplates(
        tTemplateModel.companyId,
      );
      expect(listResult, isA<SuccessState<List<ChecklistTemplateModel>>>());
      expect(listResult.data, isEmpty);

      final singleResult = await dataSource.getTemplateById(tTemplateModel.id);
      expect(singleResult, isA<FailureState<ChecklistTemplateModel>>());
    });
  });

  group('ChecklistsLocalDataSource - Items', () {
    test('saveItem and getItemsByTemplate / deleteItem', () async {
      await insertDependencies(companyId: tItemModel.companyId);
      await dataSource.saveTemplate(
        ChecklistTemplateModel.fromEntity(
          tTemplateEntity.copyWith(
            id: tItemModel.templateId,
            companyId: tItemModel.companyId,
          ),
        ),
      );

      final saveResult = await dataSource.saveItem(tItemModel);
      expect(saveResult, isA<SuccessState<bool>>());
      expect(saveResult.data, isTrue);

      final listResult = await dataSource.getItemsByTemplate(
        tItemModel.templateId,
      );
      expect(listResult, isA<SuccessState<List<ChecklistItemModel>>>());
      expect(listResult.data, hasLength(1));
      expect(listResult.data!.first.id, tItemModel.id);

      final deleteResult = await dataSource.deleteItem(tItemModel.id);
      expect(deleteResult, isA<SuccessState<bool>>());
      expect(deleteResult.data, isTrue);

      final listAfterDelete = await dataSource.getItemsByTemplate(
        tItemModel.templateId,
      );
      expect(listAfterDelete, isA<SuccessState<List<ChecklistItemModel>>>());
      expect(listAfterDelete.data, isEmpty);
    });
  });

  group('ChecklistsLocalDataSource - Responses', () {
    test('saveResponse and getResponsesByWorkOrder', () async {
      await insertDependencies(
        companyId: faker.guid.guid(),
        workOrderId: tAnswerModel.workOrderId,
      );

      final saveResult = await dataSource.saveResponse(tAnswerModel);
      expect(saveResult, isA<SuccessState<bool>>());
      expect(saveResult.data, isTrue);

      final listResult = await dataSource.getResponsesByWorkOrder(
        tAnswerModel.workOrderId,
      );
      expect(listResult, isA<SuccessState<List<ChecklistAnswerModel>>>());
      expect(listResult.data, hasLength(1));
      expect(listResult.data!.first.id, tAnswerModel.id);
    });
  });
}
