import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/models/responses/sla_policy_model.dart';

import '../../../../../testing/mocks/factories/system_factory.dart';

void main() {
  late AppDatabase database;
  late SlaLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = SlaLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertCompany(String companyId) async {
    await database
        .into(database.companies)
        .insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );
  }

  group('SlaLocalDataSourceImpl', () {
    final tSlaPolicyEntity = SystemFactory.makeSlaPolicyEntity();
    final tSlaPolicyModel = SlaPolicyModel.fromEntity(tSlaPolicyEntity);

    group('saveSlaPolicy', () {
      test('should save SLA policy successfully when company exists', () async {
        await insertCompany(tSlaPolicyModel.companyId);

        final result = await dataSource.saveSlaPolicy(tSlaPolicyModel);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, true);
      });
    });

    group('getSlaPolicies', () {
      test('should return list of saved SLA policies for a company', () async {
        await insertCompany(tSlaPolicyModel.companyId);
        await dataSource.saveSlaPolicy(tSlaPolicyModel);

        final result = await dataSource.getSlaPolicies(
          tSlaPolicyModel.companyId,
        );

        expect(result, isA<SuccessState<List<SlaPolicyModel>>>());
        final list = (result as SuccessState<List<SlaPolicyModel>>).data!;
        expect(list.length, 1);
        expect(list.first.id, tSlaPolicyModel.id);
      });

      test(
        'should return empty list if no SLA policies exist for company',
        () async {
          final result = await dataSource.getSlaPolicies(
            tSlaPolicyModel.companyId,
          );

          expect(result, isA<SuccessState<List<SlaPolicyModel>>>());
          expect((result as SuccessState<List<SlaPolicyModel>>).data, isEmpty);
        },
      );
    });

    group('getSlaPolicyById', () {
      test('should return the SLA policy with matching ID', () async {
        await insertCompany(tSlaPolicyModel.companyId);
        await dataSource.saveSlaPolicy(tSlaPolicyModel);

        final result = await dataSource.getSlaPolicyById(tSlaPolicyModel.id);

        expect(result, isA<SuccessState<SlaPolicyModel>>());
        expect(
          (result as SuccessState<SlaPolicyModel>).data!.id,
          tSlaPolicyModel.id,
        );
      });

      test(
        'should return FailureState when SLA policy does not exist',
        () async {
          final result = await dataSource.getSlaPolicyById('non-existent-id');

          expect(result, isA<FailureState<SlaPolicyModel>>());
        },
      );
    });

    group('deleteSlaPolicy', () {
      test('should soft delete SLA policy by updating deletedAt', () async {
        await insertCompany(tSlaPolicyModel.companyId);
        await dataSource.saveSlaPolicy(tSlaPolicyModel);

        final deleteResult = await dataSource.deleteSlaPolicy(
          tSlaPolicyModel.id,
        );

        expect(deleteResult, isA<SuccessState<bool>>());
        expect((deleteResult as SuccessState<bool>).data, true);

        final getResult = await dataSource.getSlaPolicyById(tSlaPolicyModel.id);
        expect(getResult, isA<FailureState<SlaPolicyModel>>());
      });
    });
  });
}
