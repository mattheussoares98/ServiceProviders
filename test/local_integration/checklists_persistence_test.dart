// Finding: docs/testing/validation_findings.md VAL-008.
// Targeted flutter analyze passed; local SQLite only; no fixes applied.
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/checklists/data/data_sources/checklists_local_data_source.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_answer_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_item_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_template_model.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';

import '../../testing/mocks/factories/checklist_factory.dart';
import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/work_order_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  ChecklistsLocalDataSourceImpl source() =>
      ChecklistsLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'template CRUD persists without changing another company template',
    () async {
      final a = ChecklistFactory.makeChecklistTemplateEntity();
      final b = ChecklistFactory.makeChecklistTemplateEntity();
      expect(
        (await source().saveTemplate(
          ChecklistTemplateModel.fromEntity(a),
        )).data,
        isTrue,
      );
      expect(
        (await source().saveTemplate(
          ChecklistTemplateModel.fromEntity(b),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      expect((await source().getTemplates(a.companyId)).data!.single.id, a.id);
      expect(
        (await source().saveTemplate(
          ChecklistTemplateModel.fromEntity(
            a.copyWith(name: 'Inspeção revisada', annulDescription: true),
          ),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final updated = (await source().getTemplateById(a.id)).data!;
      expect(updated.name, 'Inspeção revisada');
      expect(updated.description, isNull);
      expect((await source().deleteTemplate(a.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getTemplates(a.companyId)).data, isEmpty);
      expect(
        await source().getTemplateById(a.id),
        isA<FailureState<ChecklistTemplateModel>>(),
      );
      expect(
        (await source().getTemplates(b.companyId)).data!.single.name,
        b.name,
      );
    },
  );

  test(
    'item options, required flag, ordering value, and removal survive restart',
    () async {
      final template = ChecklistFactory.makeChecklistTemplateEntity();
      final item = ChecklistFactory.makeChecklistItemEntity().copyWith(
        templateId: template.id,
        companyId: template.companyId,
        type: ChecklistItemType.multiSelection,
        options: ['Óleo', 'Água', 'Peça "A"'],
        isRequired: true,
        sortOrder: 2,
      );
      expect(
        (await source().saveTemplate(
          ChecklistTemplateModel.fromEntity(template),
        )).data,
        isTrue,
      );
      expect(
        (await source().saveItem(ChecklistItemModel.fromEntity(item))).data,
        isTrue,
      );
      await fixture.reopen();
      var row = (await source().getItemsByTemplate(template.id)).data!.single;
      expect(row.options, ['Óleo', 'Água', 'Peça "A"']);
      expect(row.type, ChecklistItemType.multiSelection);
      expect(row.isRequired, isTrue);
      expect(row.sortOrder, 2);
      expect(
        (await source().saveItem(
          ChecklistItemModel.fromEntity(
            item.copyWith(
              label: 'Comentário',
              type: ChecklistItemType.text,
              annulOptions: true,
              isRequired: false,
              sortOrder: 1,
            ),
          ),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      row = (await source().getItemsByTemplate(template.id)).data!.single;
      expect(row.label, 'Comentário');
      expect(row.options, isNull);
      expect(row.type, ChecklistItemType.text);
      expect(row.isRequired, isFalse);
      expect(row.sortOrder, 1);
      expect((await source().deleteItem(item.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getItemsByTemplate(template.id)).data, isEmpty);
    },
  );

  test(
    're-answering after restart updates the item without duplicating or leaking answers',
    () async {
      final order = WorkOrderFactory.makeWorkOrderEntity();
      expect(
        (await WorkOrdersLocalDataSourceImpl(
          database: fixture.database,
        ).saveWorkOrder(WorkOrderModel.fromEntity(order))).data,
        isTrue,
      );
      final original = ChecklistFactory.makeChecklistAnswerEntity().copyWith(
        workOrderId: order.id,
        textValue: 'Antes',
        selectedOptions: ['A', 'B'],
      );
      final other = ChecklistFactory.makeChecklistAnswerEntity();
      expect(
        (await source().saveResponse(
          ChecklistAnswerModel.fromEntity(original),
        )).data,
        isTrue,
      );
      expect(
        (await source().saveResponse(
          ChecklistAnswerModel.fromEntity(other),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final edited = original.copyWith(
        id: ChecklistFactory.makeChecklistAnswerEntity().id,
        booleanValue: false,
        textValue: 'Depois',
        numberValue: 0,
        selectedOptions: [],
        annulPhotoUrl: true,
        annulSelectedOption: true,
      );
      expect(
        (await source().saveResponse(
          ChecklistAnswerModel.fromEntity(edited),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final row = (await source().getResponsesByWorkOrder(
        order.id,
      )).data!.single;
      expect(row.id, original.id);
      expect(row.textValue, 'Depois');
      expect(row.booleanValue, isFalse);
      expect(row.numberValue, 0);
      expect(row.selectedOptions, isEmpty);
      expect(row.photoUrl, isNull);
      expect(row.selectedOption, isNull);
      expect(
        (await source().getResponsesByWorkOrder(
          other.workOrderId,
        )).data!.single.id,
        other.id,
      );
      expect((await source().getResponsesByWorkOrderIds([])).data, isEmpty);
    },
  );

  test(
    'bulk answer persistence must surface a failed write on a closed database',
    () async {
      final response = ChecklistAnswerModel.fromEntity(
        ChecklistFactory.makeChecklistAnswerEntity(),
      );
      final closedSource = source();
      await fixture.database.customSelect('SELECT 1').get();
      await fixture.reopen();
      expect(
        await closedSource.saveResponse(response),
        isA<FailureState<bool>>(),
      );
      expect(
        await closedSource.saveResponses([response]),
        isA<FailureState<void>>(),
        reason:
            'A failed member write must not turn into successful batch persistence.',
      );
    },
  );
}
