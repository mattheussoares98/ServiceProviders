import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/service_provider_company_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/service_provider_profile_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/repositories/service_provider_repository_impl.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/service_provider_profile_entity.dart';

import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockServiceProviderRemoteDataSource mockRemoteDataSource;
  late ServiceProviderRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeServiceProviderCompanyEntity());
    registerFallbackValue(
      ServiceProviderCompanyResponseModel.fromEntity(
        EntityFactory.makeServiceProviderCompanyEntity(),
      ),
    );
    registerFallbackValue(EntityFactory.makeServiceProviderProfileEntity());
    registerFallbackValue(
      ServiceProviderProfileResponseModel.fromEntity(
        EntityFactory.makeServiceProviderProfileEntity(),
      ),
    );
  });

  setUp(() {
    mockRemoteDataSource = MockServiceProviderRemoteDataSource();
    repository = ServiceProviderRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
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
      'should return SuccessState with domain list when remote call succeeds',
      () async {
        when(
          () => mockRemoteDataSource.getServiceProviderCompanies(any()),
        ).thenAnswer((_) async => SuccessState(data: [tCompanyModel]));

        final result = await repository.getServiceProviderCompanies(
          tCompanyEntity.companyId,
        );

        expect(result, isA<SuccessState<List<ServiceProviderCompanyEntity>>>());
        expect(
          (result as SuccessState<List<ServiceProviderCompanyEntity>>)
              .data!
              .first,
          tCompanyEntity,
        );
        verify(
          () => mockRemoteDataSource.getServiceProviderCompanies(
            tCompanyEntity.companyId,
          ),
        ).called(1);
      },
    );

    test('should return FailureState when remote call fails', () async {
      when(
        () => mockRemoteDataSource.getServiceProviderCompanies(any()),
      ).thenAnswer((_) async => FailureState(message: 'Error'));

      final result = await repository.getServiceProviderCompanies(
        tCompanyEntity.companyId,
      );

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('getServiceProviderCompanyById', () {
    test(
      'should return SuccessState with domain entity when remote call succeeds',
      () async {
        when(
          () => mockRemoteDataSource.getServiceProviderCompanyById(any()),
        ).thenAnswer((_) async => SuccessState(data: tCompanyModel));

        final result = await repository.getServiceProviderCompanyById(
          tCompanyEntity.id,
        );

        expect(result, isA<SuccessState<ServiceProviderCompanyEntity>>());
        expect(
          (result as SuccessState<ServiceProviderCompanyEntity>).data,
          tCompanyEntity,
        );
      },
    );

    test('should return FailureState when remote call fails', () async {
      when(
        () => mockRemoteDataSource.getServiceProviderCompanyById(any()),
      ).thenAnswer((_) async => FailureState(message: 'Error'));

      final result = await repository.getServiceProviderCompanyById(
        tCompanyEntity.id,
      );

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('createServiceProviderCompany', () {
    test('should return true when creation succeeds', () async {
      when(
        () => mockRemoteDataSource.createServiceProviderCompany(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.createServiceProviderCompany(
        tCompanyEntity,
      );

      expect(result, const SuccessState(data: true));
      verify(
        () => mockRemoteDataSource.createServiceProviderCompany(tCompanyModel),
      ).called(1);
    });
  });

  group('updateServiceProviderCompany', () {
    test('should return true when update succeeds', () async {
      when(
        () => mockRemoteDataSource.updateServiceProviderCompany(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.updateServiceProviderCompany(
        tCompanyEntity,
      );

      expect(result, const SuccessState(data: true));
      verify(
        () => mockRemoteDataSource.updateServiceProviderCompany(tCompanyModel),
      ).called(1);
    });
  });

  group('getServiceProviderProfiles', () {
    test(
      'should return SuccessState with domain profiles list when remote call succeeds',
      () async {
        when(
          () => mockRemoteDataSource.getServiceProviderProfiles(any()),
        ).thenAnswer((_) async => SuccessState(data: [tProfileModel]));

        final result = await repository.getServiceProviderProfiles(
          tProfileEntity.serviceProviderCompanyId,
        );

        expect(result, isA<SuccessState<List<ServiceProviderProfileEntity>>>());
        expect(
          (result as SuccessState<List<ServiceProviderProfileEntity>>)
              .data!
              .first,
          tProfileEntity,
        );
      },
    );
  });

  group('getServiceProviderProfilesByAuthUser', () {
    test(
      'should return SuccessState with domain profiles list when remote call succeeds',
      () async {
        when(
          () => mockRemoteDataSource.getServiceProviderProfilesByAuthUser(any()),
        ).thenAnswer((_) async => SuccessState(data: [tProfileModel]));

        final result = await repository.getServiceProviderProfilesByAuthUser(
          tProfileEntity.authUserId!,
        );

        expect(result, isA<SuccessState<List<ServiceProviderProfileEntity>>>());
        expect(
          (result as SuccessState<List<ServiceProviderProfileEntity>>)
              .data!
              .first,
          tProfileEntity,
        );
      },
    );
  });

  group('createServiceProviderProfile', () {
    test('should return true when creation succeeds', () async {
      when(
        () => mockRemoteDataSource.createServiceProviderProfile(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.createServiceProviderProfile(
        tProfileEntity,
      );

      expect(result, const SuccessState(data: true));
    });
  });

  group('updateServiceProviderProfile', () {
    test('should return true when update succeeds', () async {
      when(
        () => mockRemoteDataSource.updateServiceProviderProfile(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.updateServiceProviderProfile(
        tProfileEntity,
      );

      expect(result, const SuccessState(data: true));
    });
  });
}
