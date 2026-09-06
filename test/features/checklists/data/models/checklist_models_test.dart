import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_answer_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_item_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_template_model.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';

import '../../../../../testing/mocks/factories/checklist_factory.dart';

void main() {
  group('ChecklistTemplateModel', () {
    final tEntity = ChecklistFactory.makeChecklistTemplateEntity();

    test('should be a subclass of ChecklistTemplateEntity', () {
      final model = ChecklistTemplateModel.fromEntity(tEntity);
      expect(model, isA<ChecklistTemplateEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final model = ChecklistTemplateModel.fromEntity(tEntity);
      final json = model.toJson();
      final fromJson = ChecklistTemplateModel.fromJson(json);

      expect(fromJson.toEntity(), tEntity);
    });
  });

  group('ChecklistItemModel', () {
    final tEntity = ChecklistFactory.makeChecklistItemEntity().copyWith(
      options: ['Option A', 'Option B'],
      type: ChecklistItemType.selection,
    );

    test('should be a subclass of ChecklistItemEntity', () {
      final model = ChecklistItemModel.fromEntity(tEntity);
      expect(model, isA<ChecklistItemEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final model = ChecklistItemModel.fromEntity(tEntity);
      final json = model.toJson();
      final fromJson = ChecklistItemModel.fromJson(json);

      expect(fromJson.toEntity(), tEntity);
    });

    test('should parse json string options for ChecklistItemModel', () {
      final json = {
        'id': '1',
        'template_id': 'tpl_1',
        'company_id': 'cmp_1',
        'label': 'Test Item',
        'type': 'selection',
        'is_required': true,
        'options': '["Opt 1", "Opt 2"]',
        'sort_order': 1,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

      final model = ChecklistItemModel.fromJson(json);
      expect(model.options, ['Opt 1', 'Opt 2']);
    });
  });

  group('ChecklistAnswerModel', () {
    final tEntity = ChecklistFactory.makeChecklistAnswerEntity();

    test('should be a subclass of ChecklistAnswerEntity', () {
      final model = ChecklistAnswerModel.fromEntity(tEntity);
      expect(model, isA<ChecklistAnswerEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final model = ChecklistAnswerModel.fromEntity(tEntity);
      final json = model.toJson();
      final fromJson = ChecklistAnswerModel.fromJson(json);

      expect(fromJson.toEntity(), tEntity);
    });
  });
}
