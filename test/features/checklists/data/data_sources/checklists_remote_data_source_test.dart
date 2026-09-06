import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_order.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/checklists/data/data_sources/checklists_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_answer_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_item_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_template_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/checklist_factory.dart'
    show ChecklistFactory;

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late MockSupabaseRealtimeClient mockRealtimeClient;
  late ChecklistsRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<SupabaseFilter>[]);
    registerFallbackValue(<SupabaseOrder>[]);
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    mockRealtimeClient = MockSupabaseRealtimeClient();
    dataSource = ChecklistsRemoteDataSourceImpl(
      database: mockDatabase,
      realtimeClient: mockRealtimeClient,
    );
  });

  final tTemplateEntity = ChecklistFactory.makeChecklistTemplateEntity();
  final tTemplateModel = ChecklistTemplateModel.fromEntity(tTemplateEntity);

  final tItemEntity = ChecklistFactory.makeChecklistItemEntity();
  final tItemModel = ChecklistItemModel.fromEntity(tItemEntity);

  final tAnswerEntity = ChecklistFactory.makeChecklistAnswerEntity();
  final tAnswerModel = ChecklistAnswerModel.fromEntity(tAnswerEntity);

  group('ChecklistsRemoteDataSource - Templates', () {
    test('getTemplates returns SuccessState with list of templates', () async {
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
          orderBy: any(named: 'orderBy'),
        ),
      ).thenAnswer((_) async => [tTemplateModel.toJson()]);

      final result = await dataSource.getTemplates(tTemplateEntity.companyId);

      expect(result, isA<SuccessState<List<ChecklistTemplateModel>>>());
      expect(
        (result as SuccessState<List<ChecklistTemplateModel>>).data!.first.id,
        tTemplateEntity.id,
      );
      verify(
        () => mockDatabase.selectList(
          table: 'checklist_templates',
          filters: any(named: 'filters'),
          orderBy: any(named: 'orderBy'),
        ),
      ).called(1);
    });

    test('getTemplates returns FailureState on error', () async {
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
          orderBy: any(named: 'orderBy'),
        ),
      ).thenThrow(Exception('DB Error'));

      final result = await dataSource.getTemplates(tTemplateEntity.companyId);

      expect(result, isA<FailureState<dynamic>>());
    });

    test('getTemplateById returns SuccessState when found', () async {
      when(
        () => mockDatabase.selectOne(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => tTemplateModel.toJson());

      final result = await dataSource.getTemplateById(tTemplateEntity.id);

      expect(result, isA<SuccessState<ChecklistTemplateModel>>());
      expect(
        (result as SuccessState<ChecklistTemplateModel>).data!.id,
        tTemplateEntity.id,
      );
    });

    test('getTemplateById returns FailureState when not found', () async {
      when(
        () => mockDatabase.selectOne(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => null);

      final result = await dataSource.getTemplateById(tTemplateEntity.id);

      expect(result, isA<FailureState<dynamic>>());
    });

    test('createTemplate returns SuccessState(true) when successful', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenAnswer((_) async => [tTemplateModel.toJson()]);

      final result = await dataSource.createTemplate(tTemplateModel);

      expect(result, isA<SuccessState<bool>>());
      expect((result as SuccessState<bool>).data, true);
      verify(
        () => mockDatabase.insert(
          table: 'checklist_templates',
          values: any(named: 'values'),
        ),
      ).called(1);
    });

    test('createTemplate returns FailureState on error', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenThrow(Exception('Insert error'));

      final result = await dataSource.createTemplate(tTemplateModel);

      expect(result, isA<FailureState<dynamic>>());
    });

    test('updateTemplate returns SuccessState(true) when successful', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tTemplateModel.toJson()]);

      final result = await dataSource.updateTemplate(tTemplateModel);

      expect(result, isA<SuccessState<bool>>());
      expect((result as SuccessState<bool>).data, true);
      verify(
        () => mockDatabase.update(
          table: 'checklist_templates',
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).called(1);
    });

    test('updateTemplate returns FailureState on error', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('Update error'));

      final result = await dataSource.updateTemplate(tTemplateModel);

      expect(result, isA<FailureState<dynamic>>());
    });

    test('deleteTemplate returns SuccessState(null) when successful', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => []);

      final result = await dataSource.deleteTemplate(tTemplateEntity.id);

      expect(result, isA<SuccessState<void>>());
      verify(
        () => mockDatabase.update(
          table: 'checklist_templates',
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).called(1);
    });

    test('deleteTemplate returns FailureState on error', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('Delete error'));

      final result = await dataSource.deleteTemplate(tTemplateEntity.id);

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('ChecklistsRemoteDataSource - Items', () {
    test('getItemsByTemplate returns SuccessState with items list', () async {
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
          orderBy: any(named: 'orderBy'),
        ),
      ).thenAnswer((_) async => [tItemModel.toJson()]);

      final result = await dataSource.getItemsByTemplate(
        tItemEntity.templateId,
      );

      expect(result, isA<SuccessState<List<ChecklistItemModel>>>());
      expect(
        (result as SuccessState<List<ChecklistItemModel>>).data!.first.id,
        tItemEntity.id,
      );
      verify(
        () => mockDatabase.selectList(
          table: 'checklist_items',
          filters: any(named: 'filters'),
          orderBy: any(named: 'orderBy'),
        ),
      ).called(1);
    });

    test('getItemsByTemplate returns FailureState on error', () async {
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
          orderBy: any(named: 'orderBy'),
        ),
      ).thenThrow(Exception('DB Error'));

      final result = await dataSource.getItemsByTemplate(
        tItemEntity.templateId,
      );

      expect(result, isA<FailureState<dynamic>>());
    });

    test('createItem returns SuccessState(true) when successful', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenAnswer((_) async => [tItemModel.toJson()]);

      final result = await dataSource.createItem(tItemModel);

      expect(result, isA<SuccessState<bool>>());
      expect((result as SuccessState<bool>).data, true);
      verify(
        () => mockDatabase.insert(
          table: 'checklist_items',
          values: any(named: 'values'),
        ),
      ).called(1);
    });

    test('createItem returns FailureState on error', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenThrow(Exception('Insert error'));

      final result = await dataSource.createItem(tItemModel);

      expect(result, isA<FailureState<dynamic>>());
    });

    test('updateItem returns SuccessState(true) when successful', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tItemModel.toJson()]);

      final result = await dataSource.updateItem(tItemModel);

      expect(result, isA<SuccessState<bool>>());
      expect((result as SuccessState<bool>).data, true);
    });

    test('updateItem returns FailureState on error', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('Update error'));

      final result = await dataSource.updateItem(tItemModel);

      expect(result, isA<FailureState<dynamic>>());
    });

    test('deleteItem returns SuccessState(null) when successful', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => []);

      final result = await dataSource.deleteItem(tItemEntity.id);

      expect(result, isA<SuccessState<void>>());
      verify(
        () => mockDatabase.update(
          table: 'checklist_items',
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).called(1);
    });

    test('deleteItem returns FailureState on error', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('Delete error'));

      final result = await dataSource.deleteItem(tItemEntity.id);

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('ChecklistsRemoteDataSource - Responses / Tasks', () {
    test('getResponsesByWorkOrder returns SuccessState with answers', () async {
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tAnswerModel.toJson()]);

      final result = await dataSource.getResponsesByWorkOrder(
        tAnswerEntity.workOrderId,
      );

      expect(result, isA<SuccessState<List<ChecklistAnswerModel>>>());
      expect(
        (result as SuccessState<List<ChecklistAnswerModel>>).data!.first.id,
        tAnswerEntity.id,
      );
      verify(
        () => mockDatabase.selectList(
          table: 'checklist_answers',
          filters: any(named: 'filters'),
        ),
      ).called(1);
    });

    test('getResponsesByWorkOrder returns FailureState on error', () async {
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('DB error'));

      final result = await dataSource.getResponsesByWorkOrder(
        tAnswerEntity.workOrderId,
      );

      expect(result, isA<FailureState<dynamic>>());
    });

    test(
      'saveResponse returns SuccessState(true) when upsert succeeds',
      () async {
        when(
          () => mockDatabase.upsert(
            table: any(named: 'table'),
            values: any(named: 'values'),
            onConflict: any(named: 'onConflict'),
          ),
        ).thenAnswer((_) async => [tAnswerModel.toJson()]);

        final result = await dataSource.saveResponse(tAnswerModel);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
        verify(
          () => mockDatabase.upsert(
            table: 'checklist_answers',
            values: any(named: 'values'),
            onConflict: 'work_order_id,checklist_item_id',
          ),
        ).called(1);
      },
    );

    test('saveResponse returns FailureState on error', () async {
      when(
        () => mockDatabase.upsert(
          table: any(named: 'table'),
          values: any(named: 'values'),
          onConflict: any(named: 'onConflict'),
        ),
      ).thenThrow(Exception('Upsert error'));

      final result = await dataSource.saveResponse(tAnswerModel);

      expect(result, isA<FailureState<dynamic>>());
    });
  });
}
