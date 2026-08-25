import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/company/data/data_sources/company_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_parameter_request_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_request_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_parameter_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late CompanyRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<SupabaseFilter>[]);
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = CompanyRemoteDataSourceImpl(database: mockDatabase);
  });

  final tCompanyEntity = EntityFactory.makeCompanyEntity();
  final tRequest = CompanyRequestModel.fromEntity(tCompanyEntity);
  final tResponse = CompanyModel.fromEntity(tCompanyEntity);

  final tCompanyParameterEntity = EntityFactory.makeCompanyParameterEntity()
      .copyWith(companyId: tCompanyEntity.id);
  final tParameterRequest = CompanyParameterRequestModel.fromEntity(
    tCompanyParameterEntity,
  );
  final tParameterResponse = CompanyParameterModel.fromEntity(
    tCompanyParameterEntity,
  );

  group('CompanyRemoteDataSourceImpl', () {
    group('createCompany', () {
      test(
        'should insert company and return SuccessState<CompanyModel>',
        () async {
          when(
            () => mockDatabase.insert(
              table: any(named: 'table'),
              values: any(named: 'values'),
            ),
          ).thenAnswer((_) async => [tResponse.toJson()]);

          final result = await dataSource.createCompany(tRequest);

          expect(result, isA<SuccessState<CompanyModel>>());
          expect(result.data, tResponse);
          verify(
            () => mockDatabase.insert(
              table: 'companies',
              values: tRequest.toJson(),
            ),
          ).called(1);
        },
      );

      test('should return FailureState when insert throws', () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenThrow(Exception('insert failed'));

        final result = await dataSource.createCompany(tRequest);

        expect(result, isA<FailureState<CompanyModel>>());
      });
    });

    group('updateCompany', () {
      test(
        'should update company and return SuccessState<CompanyModel>',
        () async {
          when(
            () => mockDatabase.update(
              table: any(named: 'table'),
              values: any(named: 'values'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => [tResponse.toJson()]);

          final result = await dataSource.updateCompany(tRequest);

          expect(result, isA<SuccessState<CompanyModel>>());
          expect(result.data, tResponse);
          verify(
            () => mockDatabase.update(
              table: 'companies',
              values: tRequest.toJson(),
              filters: [SupabaseFilter.eq('id', tRequest.id)],
            ),
          ).called(1);
        },
      );

      test('should return FailureState when update throws', () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('update failed'));

        final result = await dataSource.updateCompany(tRequest);

        expect(result, isA<FailureState<CompanyModel>>());
      });
    });

    group('getCompany', () {
      test('should return SuccessState when company is found', () async {
        final id = faker.guid.guid();
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => tResponse.toJson());

        final result = await dataSource.getCompany(id);

        expect(result, isA<SuccessState<CompanyModel>>());
        expect(result.data, tResponse);
        verify(
          () => mockDatabase.selectOne(
            table: 'companies',
            filters: [SupabaseFilter.eq('id', id)],
          ),
        ).called(1);
      });

      test('should return FailureState when company is null', () async {
        final id = faker.guid.guid();
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => null);

        final result = await dataSource.getCompany(id);

        expect(result, isA<FailureState<CompanyModel>>());
        final failure = result as FailureState<CompanyModel>;
        expect(failure.message, contains('Empresa não encontrada'));
      });

      test('should return FailureState when selectOne throws', () async {
        final id = faker.guid.guid();
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('selectOne failed'));

        final result = await dataSource.getCompany(id);

        expect(result, isA<FailureState<CompanyModel>>());
      });
    });

    group('getCompanyParameters', () {
      test('should return SuccessState when parameters are found', () async {
        final companyId = tCompanyEntity.id;
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => tParameterResponse.toJson());

        final result = await dataSource.getCompanyParameters(companyId);

        expect(result, isA<SuccessState<CompanyParameterModel>>());
        expect(result.data, tParameterResponse);
        verify(
          () => mockDatabase.selectOne(
            table: 'company_parameters',
            filters: [
              SupabaseFilter.eq('company_id', companyId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          ),
        ).called(1);
      });

      test('should return FailureState when parameters are null', () async {
        final companyId = tCompanyEntity.id;
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => null);

        final result = await dataSource.getCompanyParameters(companyId);

        expect(result, isA<FailureState<CompanyParameterModel>>());
        final failure = result as FailureState<CompanyParameterModel>;
        expect(failure.message, contains('Parâmetros da empresa não encontrados'));
      });

      test('should return FailureState when selectOne throws', () async {
        final companyId = tCompanyEntity.id;
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('database error'));

        final result = await dataSource.getCompanyParameters(companyId);

        expect(result, isA<FailureState<CompanyParameterModel>>());
      });
    });

    group('saveCompanyParameters', () {
      test(
        'should upsert parameters and return SuccessState<CompanyParameterModel>',
        () async {
          when(
            () => mockDatabase.upsert(
              table: any(named: 'table'),
              values: any(named: 'values'),
              onConflict: any(named: 'onConflict'),
            ),
          ).thenAnswer((_) async => [tParameterResponse.toJson()]);

          final result = await dataSource.saveCompanyParameters(
            tParameterRequest,
          );

          expect(result, isA<SuccessState<CompanyParameterModel>>());
          expect(result.data, tParameterResponse);
          verify(
            () => mockDatabase.upsert(
              table: 'company_parameters',
              values: tParameterRequest.toJson(),
              onConflict: 'company_id',
            ),
          ).called(1);
        },
      );

      test('should return FailureState when upsert throws', () async {
        when(
          () => mockDatabase.upsert(
            table: any(named: 'table'),
            values: any(named: 'values'),
            onConflict: any(named: 'onConflict'),
          ),
        ).thenThrow(Exception('upsert failed'));

        final result = await dataSource.saveCompanyParameters(
          tParameterRequest,
        );

        expect(result, isA<FailureState<CompanyParameterModel>>());
      });
    });

    group('getAllCompanies', () {
      test('should return SuccessState<List<CompanyModel>> when database succeeds', () async {
        final tList = [tResponse.toJson()];
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => tList);

        final result = await dataSource.getAllCompanies();

        expect(result, isA<SuccessState<List<CompanyModel>>>());
        expect(result.data?.length, 1);
        expect(result.data?.first, tResponse);
      });

      test('should return FailureState when database throws', () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('selectList failed'));

        final result = await dataSource.getAllCompanies();

        expect(result, isA<FailureState<List<CompanyModel>>>());
      });
    });
  });
}

