import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/data_sources/service_provider_local_data_source.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_company_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_profile_model.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/service_provider_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  ServiceProviderLocalDataSourceImpl source() =>
      ServiceProviderLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'provider company edits, contact clearing, and deletion survive reopening',
    () async {
      final company = ServiceProviderFactory.makeServiceProviderCompanyEntity();
      expect(
        (await source().saveServiceProviderCompany(
          ServiceProviderCompanyModel.fromEntity(company),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getServiceProviderCompanies(
          company.companyId,
        )).data!.single.id,
        company.id,
      );
      final updated = company.copyWith(
        name: 'Prestador revisado',
        annulContactEmail: true,
        annulContactPhone: true,
        isActive: false,
      );
      expect(
        (await source().saveServiceProviderCompany(
          ServiceProviderCompanyModel.fromEntity(updated),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final row = (await source().getServiceProviderCompanyById(
        company.id,
      )).data!;
      expect(row.name, 'Prestador revisado');
      expect(row.isActive, isFalse);
      expect(row.contactEmail, isNull);
      expect(row.contactPhone, isNull);
      expect(row.document, company.document);
      expect(
        (await source().deleteServiceProviderCompany(company.id)).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getServiceProviderCompanies(company.companyId)).data,
        isEmpty,
      );
      expect(
        await source().getServiceProviderCompanyById(company.id),
        isA<FailureState<ServiceProviderCompanyModel>>(),
      );
    },
  );

  test(
    'contractor-company lists stay isolated after repeated server batches',
    () async {
      final a = ServiceProviderFactory.makeServiceProviderCompanyEntity();
      final b = ServiceProviderFactory.makeServiceProviderCompanyEntity()
          .copyWith(document: '98765432000188');
      final batch = [
        ServiceProviderCompanyModel.fromEntity(a),
        ServiceProviderCompanyModel.fromEntity(b),
      ];
      expect((await source().saveServiceProviderCompanies(batch)).data, isTrue);
      await fixture.reopen();
      expect((await source().saveServiceProviderCompanies(batch)).data, isTrue);
      await fixture.reopen();
      expect(
        (await source().getServiceProviderCompanies(
          a.companyId,
        )).data!.single.id,
        a.id,
      );
      expect(
        (await source().getServiceProviderCompanies(
          b.companyId,
        )).data!.single.id,
        b.id,
      );
      expect((await source().deleteServiceProviderCompany(a.id)).data, isTrue);
      await fixture.reopen();
      expect(
        (await source().getServiceProviderCompanies(
          b.companyId,
        )).data!.single.id,
        b.id,
      );
    },
  );

  test(
    'conflicting documents fail atomically without losing existing providers',
    () async {
      final existing =
          ServiceProviderFactory.makeServiceProviderCompanyEntity();
      expect(
        (await source().saveServiceProviderCompany(
          ServiceProviderCompanyModel.fromEntity(existing),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final newProvider =
          ServiceProviderFactory.makeServiceProviderCompanyEntity().copyWith(
            companyId: existing.companyId,
            document: '98765432000188',
          );
      final duplicate =
          ServiceProviderFactory.makeServiceProviderCompanyEntity().copyWith(
            companyId: existing.companyId,
            document: existing.document,
          );
      expect(
        await source().saveServiceProviderCompanies([
          ServiceProviderCompanyModel.fromEntity(newProvider),
          ServiceProviderCompanyModel.fromEntity(duplicate),
        ]),
        isA<FailureState<bool>>(),
      );
      await fixture.reopen();
      expect(
        (await source().getServiceProviderCompanies(
          existing.companyId,
        )).data!.map((r) => r.id),
        [existing.id],
      );
    },
  );

  test(
    'provider profile changes persist without exposing another provider profile',
    () async {
      final a = ServiceProviderFactory.makeServiceProviderProfileEntity();
      final b = ServiceProviderFactory.makeServiceProviderProfileEntity();
      expect(
        (await source().saveServiceProviderProfiles([
          ServiceProviderProfileModel.fromEntity(a),
          ServiceProviderProfileModel.fromEntity(b),
        ])).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getServiceProviderProfiles(
          a.serviceProviderCompanyId,
        )).data!.single.id,
        a.id,
      );
      expect(
        (await source().getServiceProviderProfilesByCompanyIds([])).data,
        isEmpty,
      );
      final updated = a.copyWith(
        isActive: false,
        annulPhone: true,
        name: 'Técnico revisado',
      );
      expect(
        (await source().saveServiceProviderProfile(
          ServiceProviderProfileModel.fromEntity(updated),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final row = (await source().getServiceProviderProfilesByCompanyIds([
        a.serviceProviderCompanyId,
      ])).data!.single;
      expect(row.id, a.id);
      expect(row.name, updated.name);
      expect(row.isActive, isFalse);
      expect(row.phone, isNull);
      expect((await source().deleteServiceProviderProfile(a.id)).data, isTrue);
      await fixture.reopen();
      expect(
        (await source().getServiceProviderProfiles(
          a.serviceProviderCompanyId,
        )).data,
        isEmpty,
      );
      expect(
        (await source().getServiceProviderProfiles(
          b.serviceProviderCompanyId,
        )).data!.single.id,
        b.id,
      );
    },
  );
}
