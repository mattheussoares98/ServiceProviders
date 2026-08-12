import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabaseClient;
  late SectorsRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(
      SectorModel.fromEntity(EntityFactory.makeSectorEntity()),
    );
  });

  setUp(() {
    mockDatabaseClient = MockSupabaseDatabaseClient();
    dataSource = SectorsRemoteDataSourceImpl(database: mockDatabaseClient);
  });

  group('SectorsRemoteDataSource Tests', () {
    test('getSectors returns SuccessState when query succeeds', () async {
      final tSectorModel = SectorModel.fromEntity(
        EntityFactory.makeSectorEntity(),
      );
      final jsonList = [tSectorModel.toJson()];

      when(
        () => mockDatabaseClient.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => jsonList);

      final result = await dataSource.getSectors(tSectorModel.companyId);

      expect(result, isA<SuccessState<List<SectorModel>>>());
      expect(
        (result as SuccessState<List<SectorModel>>).data?.first.id,
        tSectorModel.id,
      );
    });

    test('createSector returns SuccessState when insert succeeds', () async {
      final tSectorModel = SectorModel.fromEntity(
        EntityFactory.makeSectorEntity(),
      );
      final jsonList = [tSectorModel.toJson()];

      when(
        () => mockDatabaseClient.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenAnswer((_) async => jsonList);

      final result = await dataSource.createSector(tSectorModel);

      expect(result, isA<SuccessState<SectorModel>>());
      expect((result as SuccessState<SectorModel>).data?.id, tSectorModel.id);
    });

    group('updateSector', () {
      test('returns SuccessState when update succeeds', () async {
        final tSectorModel = SectorModel.fromEntity(
          EntityFactory.makeSectorEntity(),
        );
        final jsonList = [tSectorModel.toJson()];

        when(
          () => mockDatabaseClient.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => jsonList);

        final result = await dataSource.updateSector(tSectorModel);

        expect(result, isA<SuccessState<SectorModel>>());
        expect((result as SuccessState<SectorModel>).data?.id, tSectorModel.id);
      });

      test('returns FailureState when update fails', () async {
        final tSectorModel = SectorModel.fromEntity(
          EntityFactory.makeSectorEntity(),
        );

        when(
          () => mockDatabaseClient.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('Update error'));

        final result = await dataSource.updateSector(tSectorModel);

        expect(result, isA<FailureState<SectorModel>>());
      });
    });

    group('deleteSector', () {
      test('returns SuccessState when delete succeeds', () async {
        final tSectorModel = SectorModel.fromEntity(
          EntityFactory.makeSectorEntity(),
        );

        when(
          () => mockDatabaseClient.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tSectorModel.toJson()]);

        final result = await dataSource.deleteSector(tSectorModel.id);

        expect(result, isA<SuccessState<void>>());
      });

      test('returns FailureState when delete fails', () async {
        final tSectorModel = SectorModel.fromEntity(
          EntityFactory.makeSectorEntity(),
        );

        when(
          () => mockDatabaseClient.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('Delete error'));

        final result = await dataSource.deleteSector(tSectorModel.id);

        expect(result, isA<FailureState<void>>());
      });
    });
  });
}
