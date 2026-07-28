import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_response_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabaseClient;
  late SectorsRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(
      SectorResponseModel.fromEntity(EntityFactory.makeSectorEntity()),
    );
  });

  setUp(() {
    mockDatabaseClient = MockSupabaseDatabaseClient();
    dataSource = SectorsRemoteDataSourceImpl(database: mockDatabaseClient);
  });

  group('SectorsRemoteDataSource Tests', () {
    test('getSectors returns SuccessState when query succeeds', () async {
      final tSectorModel = SectorResponseModel.fromEntity(
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

      expect(result, isA<SuccessState<List<SectorResponseModel>>>());
      expect(
        (result as SuccessState<List<SectorResponseModel>>).data?.first.id,
        tSectorModel.id,
      );
    });

    test('createSector returns SuccessState when insert succeeds', () async {
      final tSectorModel = SectorResponseModel.fromEntity(
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

      expect(result, isA<SuccessState<SectorResponseModel>>());
      expect(
        (result as SuccessState<SectorResponseModel>).data?.id,
        tSectorModel.id,
      );
    });
  });
}
