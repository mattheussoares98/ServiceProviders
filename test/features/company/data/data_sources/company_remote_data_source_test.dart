import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/company/data/data_sources/company_remote_data_source.dart';
import 'package:clean_architecture/features/company/data/models/requests/company_request_model.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_model.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

  group('CompanyRemoteDataSourceImpl', () {
    group('createCompany', () {
      test(
        'should insert company and return SuccessState<CompanyResponseModel>',
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
        expect(failure.message, 'Empresa não encontrada');
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
  });
}
