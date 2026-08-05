import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_response_model.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late SectorsLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = SectorsLocalDataSourceImpl(database: database);
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

  group('SectorsLocalDataSourceImpl Tests', () {
    final tSectorEntity = EntityFactory.makeSectorEntity();
    final tSectorModel = SectorResponseModel.fromEntity(tSectorEntity);

    group('saveSector', () {
      test('should save sector successfully when company exists', () async {
        await insertCompany(tSectorModel.companyId);

        final result = await dataSource.saveSector(tSectorModel);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, isTrue);
      });
    });

    group('saveSectors', () {
      test('should save list of sectors successfully', () async {
        await insertCompany(tSectorModel.companyId);
        final list = [
          tSectorModel,
          SectorResponseModel.fromEntity(
            EntityFactory.makeSectorEntity().copyWith(
              companyId: tSectorModel.companyId,
              name: '${tSectorModel.name}_2',
            ),
          ),
        ];

        final result = await dataSource.saveSectors(list);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, isTrue);
      });
    });

    group('getSectors', () {
      test('should return list of saved sectors for a company', () async {
        await insertCompany(tSectorModel.companyId);
        await dataSource.saveSector(tSectorModel);

        final result = await dataSource.getSectors(tSectorModel.companyId);

        expect(result, isA<SuccessState<List<SectorResponseModel>>>());
        final list = (result as SuccessState<List<SectorResponseModel>>).data!;
        expect(list.length, 1);
        expect(list.first.id, tSectorModel.id);
      });

      test(
        'should return empty list if no sectors exist for company',
        () async {
          final result = await dataSource.getSectors('non-existent-company');

          expect(result, isA<SuccessState<List<SectorResponseModel>>>());
          expect(
            (result as SuccessState<List<SectorResponseModel>>).data,
            isEmpty,
          );
        },
      );
    });

    group('deleteSector', () {
      test('should mark sector as deleted successfully', () async {
        await insertCompany(tSectorModel.companyId);
        await dataSource.saveSector(tSectorModel);

        final result = await dataSource.deleteSector(tSectorModel.id);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, isTrue);

        final remainingSectors = await dataSource.getSectors(
          tSectorModel.companyId,
        );
        expect(
          (remainingSectors as SuccessState<List<SectorResponseModel>>).data,
          isEmpty,
        );
      });
    });
  });
}
