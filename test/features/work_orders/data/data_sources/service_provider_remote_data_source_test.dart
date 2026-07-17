import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/service_provider_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/service_provider_company_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/service_provider_profile_response_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late ServiceProviderRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<SupabaseFilter>[]);
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = ServiceProviderRemoteDataSourceImpl(database: mockDatabase);
  });

  final tCompanyEntity = EntityFactory.makeServiceProviderCompanyEntity();
  final tCompanyModel = ServiceProviderCompanyResponseModel.fromEntity(
    tCompanyEntity,
  );

  final tProfileEntity = EntityFactory.makeServiceProviderProfileEntity();
  final tProfileModel = ServiceProviderProfileResponseModel.fromEntity(
    tProfileEntity,
  );

  group('getServiceProviderCompanies', () {
    test(
      'should return SuccessState with list of company models when call to DB is successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tCompanyModel.toJson()]);

        final result = await dataSource.getServiceProviderCompanies(
          tCompanyEntity.companyId,
        );

        expect(
          result,
          isA<SuccessState<List<ServiceProviderCompanyResponseModel>>>(),
        );
        expect(
          (result as SuccessState<List<ServiceProviderCompanyResponseModel>>)
              .data!
              .first
              .id,
          tCompanyEntity.id,
        );
        verify(
          () => mockDatabase.selectList(
            table: 'service_provider_companies',
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );

    test(
      'should return FailureState when DB call throws an exception',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('DB error'));

        final result = await dataSource.getServiceProviderCompanies(
          tCompanyEntity.companyId,
        );

        expect(result, isA<FailureState<dynamic>>());
      },
    );
  });

  group('getServiceProviderCompanyById', () {
    test(
      'should return SuccessState with company model when company exists',
      () async {
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => tCompanyModel.toJson());

        final result = await dataSource.getServiceProviderCompanyById(
          tCompanyEntity.id,
        );

        expect(
          result,
          isA<SuccessState<ServiceProviderCompanyResponseModel>>(),
        );
        expect(
          (result as SuccessState<ServiceProviderCompanyResponseModel>)
              .data!
              .id,
          tCompanyEntity.id,
        );
      },
    );

    test('should return FailureState when company does not exist', () async {
      when(
        () => mockDatabase.selectOne(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => null);

      final result = await dataSource.getServiceProviderCompanyById(
        tCompanyEntity.id,
      );

      expect(result, isA<FailureState<dynamic>>());
    });

    test('should return FailureState when DB call fails', () async {
      when(
        () => mockDatabase.selectOne(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('DB error'));

      final result = await dataSource.getServiceProviderCompanyById(
        tCompanyEntity.id,
      );

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('createServiceProviderCompany', () {
    test(
      'should return SuccessState(true) when insert is successful',
      () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tCompanyModel.toJson()]);

        final result = await dataSource.createServiceProviderCompany(
          tCompanyModel,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.insert(
            table: 'service_provider_companies',
            values: any(named: 'values'),
          ),
        ).called(1);
      },
    );

    test('should return FailureState when insert fails', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenThrow(Exception('Insert error'));

      final result = await dataSource.createServiceProviderCompany(
        tCompanyModel,
      );

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('updateServiceProviderCompany', () {
    test(
      'should return SuccessState(true) when update is successful',
      () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tCompanyModel.toJson()]);

        final result = await dataSource.updateServiceProviderCompany(
          tCompanyModel,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.update(
            table: 'service_provider_companies',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );

    test('should return FailureState when update fails', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('Update error'));

      final result = await dataSource.updateServiceProviderCompany(
        tCompanyModel,
      );

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('getServiceProviderProfiles', () {
    test(
      'should return SuccessState with list of profile models when successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tProfileModel.toJson()]);

        final result = await dataSource.getServiceProviderProfiles(
          tProfileEntity.serviceProviderCompanyId,
        );

        expect(
          result,
          isA<SuccessState<List<ServiceProviderProfileResponseModel>>>(),
        );
        expect(
          (result as SuccessState<List<ServiceProviderProfileResponseModel>>)
              .data!
              .first
              .id,
          tProfileEntity.id,
        );
      },
    );
  });

  group('getServiceProviderProfilesByAuthUser', () {
    test(
      'should return SuccessState with list of profile models when successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tProfileModel.toJson()]);

        final result = await dataSource.getServiceProviderProfilesByAuthUser(
          tProfileEntity.authUserId!,
        );

        expect(
          result,
          isA<SuccessState<List<ServiceProviderProfileResponseModel>>>(),
        );
        expect(
          (result as SuccessState<List<ServiceProviderProfileResponseModel>>)
              .data!
              .first
              .id,
          tProfileEntity.id,
        );
      },
    );
  });

  group('createServiceProviderProfile', () {
    test(
      'should return SuccessState(true) when insert is successful',
      () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tProfileModel.toJson()]);

        final result = await dataSource.createServiceProviderProfile(
          tProfileModel,
        );

        expect(result, const SuccessState(data: true));
      },
    );
  });

  group('updateServiceProviderProfile', () {
    test(
      'should return SuccessState(true) when update is successful',
      () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tProfileModel.toJson()]);

        final result = await dataSource.updateServiceProviderProfile(
          tProfileModel,
        );

        expect(result, const SuccessState(data: true));
      },
    );
  });
}
