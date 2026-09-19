import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/company/data/data_sources/company_local_data_source.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_parameter_model.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/user_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  CompanyLocalDataSourceImpl source() =>
      CompanyLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'company name and active state survive restart without changing another company',
    () async {
      final a = UserFactory.makeCompanyEntity();
      final b = UserFactory.makeCompanyEntity().copyWith(
        cnpj: '98765432000188',
      );
      expect(
        (await source().saveCompany(CompanyModel.fromEntity(a))).data,
        isTrue,
      );
      expect(
        (await source().saveCompany(CompanyModel.fromEntity(b))).data,
        isTrue,
      );
      await fixture.reopen();
      expect((await source().getCompany(a.id)).data!.name, a.name);
      expect(
        (await source().saveCompany(
          CompanyModel.fromEntity(
            a.copyWith(name: 'Empresa revisada', isActive: false),
          ),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final changed = (await source().getCompany(a.id)).data!;
      expect(changed.name, 'Empresa revisada');
      expect(changed.isActive, isFalse);
      expect(changed.cnpj, a.cnpj);
      expect((await source().getCompany(b.id)).data!.name, b.name);
      expect((await source().getCompany(b.id)).data!.isActive, isTrue);
    },
  );

  test(
    'company limits and permission settings persist including false and empty values',
    () async {
      final company = UserFactory.makeCompanyEntity();
      final params = UserFactory.makeCompanyParameterEntity().copyWith(
        companyId: company.id,
        allowProviderCreateWorkOrder: true,
        advanceWarningMinutes: 30,
        delayedNotificationIntervalMinutes: 120,
      );
      expect(
        (await source().saveCompany(CompanyModel.fromEntity(company))).data,
        isTrue,
      );
      expect(
        (await source().saveCompanyParameters(
          CompanyParameterModel.fromEntity(params),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      var row = (await source().getCompanyParameters(company.id)).data!;
      expect(row.maxOfflineDurationHours, params.maxOfflineDurationHours);
      expect(row.maxSyncAttempts, params.maxSyncAttempts);
      expect(row.allowProviderCreateWorkOrder, isTrue);
      expect(row.advanceWarningGroupIds, params.advanceWarningGroupIds);
      expect(row.escalationGroupIds, params.escalationGroupIds);
      expect(row.advanceWarningMinutes, 30);
      expect(row.delayedNotificationIntervalMinutes, 120);
      final changed = params.copyWith(
        maxImageSizeMb: 8,
        sandboxQuotaMb: 256,
        allowProviderCreateWorkOrder: false,
        advanceWarningGroupIds: [],
        escalationGroupIds: [],
      );
      expect(
        (await source().saveCompanyParameters(
          CompanyParameterModel.fromEntity(changed),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      row = (await source().getCompanyParameters(company.id)).data!;
      expect(row.id, params.id);
      expect(row.allowProviderCreateWorkOrder, isFalse);
      expect(row.maxImageSizeMb, 8);
      expect(row.sandboxQuotaMb, 256);
      expect(row.advanceWarningGroupIds, isEmpty);
      expect(row.escalationGroupIds, isEmpty);
      expect(row.inviteExpiryHours, params.inviteExpiryHours);
    },
  );

  test(
    'company parameter reads stay isolated and exclude downloaded tombstones',
    () async {
      final a = UserFactory.makeCompanyParameterEntity().copyWith(
        maxImageSizeMb: 5,
      );
      final b = UserFactory.makeCompanyParameterEntity().copyWith(
        maxImageSizeMb: 20,
      );
      expect(
        (await source().saveCompanyParameters(
          CompanyParameterModel.fromEntity(a),
        )).data,
        isTrue,
      );
      expect(
        (await source().saveCompanyParameters(
          CompanyParameterModel.fromEntity(b),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getCompanyParameters(a.companyId)).data!.maxImageSizeMb,
        5,
      );
      expect(
        (await source().getCompanyParameters(b.companyId)).data!.maxImageSizeMb,
        20,
      );
      expect(
        (await source().saveCompanyParameters(
          CompanyParameterModel.fromEntity(
            a.copyWith(deletedAt: DateTime.utc(2026, 9, 19)),
          ),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        await source().getCompanyParameters(a.companyId),
        isA<FailureState<CompanyParameterModel>>(),
      );
      expect((await source().getCompanyParameters(b.companyId)).data!.id, b.id);
    },
  );
}
