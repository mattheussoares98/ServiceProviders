import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/data_sources/service_provider_local_data_source.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_company_response_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_invitation_response_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_profile_response_model.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late ServiceProviderLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ServiceProviderLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  final tCompanyEntity = EntityFactory.makeServiceProviderCompanyEntity();
  final tCompanyModel = ServiceProviderCompanyResponseModel.fromEntity(
    tCompanyEntity,
  );

  final tProfileEntity = EntityFactory.makeServiceProviderProfileEntity();
  final tProfileModel = ServiceProviderProfileResponseModel.fromEntity(
    tProfileEntity,
  );

  final tInvitationEntity = EntityFactory.makeServiceProviderInvitationEntity();
  final tInvitationModel = ServiceProviderInvitationResponseModel.fromEntity(
    tInvitationEntity,
  );

  group('ServiceProviderLocalDataSourceImpl', () {
    group('Companies', () {
      test(
        'saveServiceProviderCompany and getServiceProviderCompanyById',
        () async {
          final saveResult = await dataSource.saveServiceProviderCompany(
            tCompanyModel,
          );
          expect(saveResult, isA<SuccessState<bool>>());
          expect(saveResult.data, isTrue);

          final getResult = await dataSource.getServiceProviderCompanyById(
            tCompanyModel.id,
          );
          expect(
            getResult,
            isA<SuccessState<ServiceProviderCompanyResponseModel>>(),
          );
          expect(getResult.data?.id, tCompanyModel.id);
          expect(getResult.data?.name, tCompanyModel.name);
        },
      );

      test(
        'saveServiceProviderCompanies and getServiceProviderCompanies',
        () async {
          final saveResult = await dataSource.saveServiceProviderCompanies([
            tCompanyModel,
          ]);
          expect(saveResult, isA<SuccessState<bool>>());
          expect(saveResult.data, isTrue);

          final getResult = await dataSource.getServiceProviderCompanies(
            tCompanyModel.companyId,
          );
          expect(
            getResult,
            isA<SuccessState<List<ServiceProviderCompanyResponseModel>>>(),
          );
          expect(getResult.data?.length, 1);
          expect(getResult.data?.first.id, tCompanyModel.id);
        },
      );

      test(
        'getServiceProviderCompanyById returns failure when not found',
        () async {
          final result = await dataSource.getServiceProviderCompanyById(
            'non-existent-id',
          );
          expect(
            result,
            isA<FailureState<ServiceProviderCompanyResponseModel>>(),
          );
        },
      );
    });

    group('Profiles', () {
      test(
        'saveServiceProviderProfiles and getServiceProviderProfiles',
        () async {
          // Need company first due to foreign key references in Drift
          await dataSource.saveServiceProviderCompany(tCompanyModel);

          final saveResult = await dataSource.saveServiceProviderProfiles([
            tProfileModel,
          ]);
          expect(saveResult, isA<SuccessState<bool>>());

          final getResult = await dataSource.getServiceProviderProfiles(
            tProfileModel.serviceProviderCompanyId,
          );
          expect(
            getResult,
            isA<SuccessState<List<ServiceProviderProfileResponseModel>>>(),
          );
          expect(getResult.data?.length, 1);
          expect(getResult.data?.first.id, tProfileModel.id);
        },
      );

      test('saveServiceProviderProfile updates existing profile', () async {
        await dataSource.saveServiceProviderCompany(tCompanyModel);
        await dataSource.saveServiceProviderProfile(tProfileModel);

        final getResult = await dataSource.getServiceProviderProfiles(
          tProfileModel.serviceProviderCompanyId,
        );
        expect(getResult.data?.first.name, tProfileModel.name);
      });

      test(
        'getServiceProviderProfilesByCompanyIds returns profiles matching list of company IDs',
        () async {
          await dataSource.saveServiceProviderCompany(tCompanyModel);
          await dataSource.saveServiceProviderProfiles([tProfileModel]);

          final getResult =
              await dataSource.getServiceProviderProfilesByCompanyIds([
                tProfileModel.serviceProviderCompanyId,
              ]);

          expect(
            getResult,
            isA<SuccessState<List<ServiceProviderProfileResponseModel>>>(),
          );
          expect(getResult.data?.length, 1);
          expect(getResult.data?.first.id, tProfileModel.id);
        },
      );
    });

    group('Invitations', () {
      test(
        'saveServiceProviderInvitations, getServiceProviderInvitations, deleteServiceProviderInvitation',
        () async {
          await dataSource.saveServiceProviderCompany(tCompanyModel);

          final saveResult = await dataSource.saveServiceProviderInvitations([
            tInvitationModel,
          ]);
          expect(saveResult, isA<SuccessState<bool>>());

          final getResult = await dataSource.getServiceProviderInvitations(
            tInvitationModel.serviceProviderCompanyId,
          );
          expect(
            getResult,
            isA<SuccessState<List<ServiceProviderInvitationResponseModel>>>(),
          );
          expect(getResult.data?.length, 1);

          final deleteResult = await dataSource.deleteServiceProviderInvitation(
            tInvitationModel.id,
          );
          expect(deleteResult, isA<SuccessState<bool>>());

          final getAfterDelete = await dataSource.getServiceProviderInvitations(
            tInvitationModel.serviceProviderCompanyId,
          );
          expect(getAfterDelete.data, isEmpty);
        },
      );
    });
  });
}
