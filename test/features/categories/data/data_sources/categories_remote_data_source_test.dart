import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/requests/category_request_model.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/responses/category_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late CategoriesRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(
      CategoryModel.fromEntity(EntityFactory.makeCategoryEntity()),
    );
    registerFallbackValue(
      CategoryRequestModel.fromEntity(EntityFactory.makeCategoryEntity()),
    );
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = CategoriesRemoteDataSourceImpl(database: mockDatabase);
  });

  final tEntity = EntityFactory.makeCategoryEntity();
  final tModel = CategoryModel.fromEntity(tEntity);
  final tRequest = CategoryRequestModel.fromEntity(tEntity);
  final tCompanyId = faker.guid.guid();

  group('CategoriesRemoteDataSourceImpl', () {
    group('getCategories', () {
      test(
        'should return SuccessState<List<CategoryModel>> on success',
        () async {
          when(
            () => mockDatabase.selectList(
              table: any(named: 'table'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => [tModel.toJson()]);

          final result = await dataSource.getCategories(tCompanyId);

          expect(result, isA<SuccessState<List<CategoryModel>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first.id, tModel.id);
          verify(
            () => mockDatabase.selectList(
              table: 'categories',
              filters: [
                SupabaseFilter.eq('company_id', tCompanyId),
                SupabaseFilter.isFilter('deleted_at', null),
              ],
            ),
          ).called(1);
        },
      );
    });

    group('createCategory', () {
      test('should return SuccessState<CategoryModel> on success', () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tModel.toJson()]);

        final result = await dataSource.createCategory(tRequest);

        expect(result, isA<SuccessState<CategoryModel>>());
        expect(result.data!.id, tModel.id);
        verify(
          () => mockDatabase.insert(
            table: 'categories',
            values: tRequest.toJson(),
          ),
        ).called(1);
      });
    });

    group('updateCategory', () {
      test('should return SuccessState<CategoryModel> on success', () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tModel.toJson()]);

        final result = await dataSource.updateCategory(tRequest);

        expect(result, isA<SuccessState<CategoryModel>>());
        expect(result.data!.id, tModel.id);
        verify(
          () => mockDatabase.update(
            table: 'categories',
            values: tRequest.toJson(),
            filters: [SupabaseFilter.eq('id', tRequest.id)],
          ),
        ).called(1);
      });
    });

    group('deleteCategory', () {
      test('should return SuccessState<void> on success', () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tModel.toJson()]);

        final result = await dataSource.deleteCategory(tModel.id);

        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockDatabase.update(
            table: 'categories',
            values: any(named: 'values'),
            filters: [SupabaseFilter.eq('id', tModel.id)],
          ),
        ).called(1);
      });
    });
  });
}
