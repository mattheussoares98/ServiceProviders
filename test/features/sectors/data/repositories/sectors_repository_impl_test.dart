import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_response_model.dart';
import 'package:o_jogo_da_obra/features/sectors/data/repositories/sectors_repository_impl.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

class MockSectorsRemoteDataSource extends Mock
    implements SectorsRemoteDataSource {}

class MockSectorsLocalDataSource extends Mock
    implements SectorsLocalDataSource {}

void main() {
  late MockInternetClient mockInternet;
  late MockSectorsRemoteDataSource mockRemoteDataSource;
  late MockSectorsLocalDataSource mockLocalDataSource;
  late SectorsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      SectorResponseModel.fromEntity(EntityFactory.makeSectorEntity()),
    );
  });

  setUp(() {
    mockInternet = MockInternetClient();
    mockRemoteDataSource = MockSectorsRemoteDataSource();
    mockLocalDataSource = MockSectorsLocalDataSource();
    repository = SectorsRepositoryImpl(
      internet: mockInternet,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('SectorsRepositoryImpl Tests', () {
    test(
      'getSectors fetches from remote and caches locally when connected',
      () async {
        final tSector = EntityFactory.makeSectorEntity();
        final tModel = SectorResponseModel.fromEntity(tSector);

        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getSectors(any()),
        ).thenAnswer((_) async => SuccessState(data: [tModel]));
        when(
          () => mockLocalDataSource.saveSectors(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getSectors(tSector.companyId);

        expect(result, isA<SuccessState<List<SectorEntity>>>());
        expect(
          (result as SuccessState<List<SectorEntity>>).data?.first.id,
          tSector.id,
        );
        verify(
          () => mockRemoteDataSource.getSectors(tSector.companyId),
        ).called(1);
      },
    );

    test('getSectors fetches from local source when disconnected', () async {
      final tSector = EntityFactory.makeSectorEntity();
      final tModel = SectorResponseModel.fromEntity(tSector);

      when(() => mockInternet.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getSectors(any()),
      ).thenAnswer((_) async => SuccessState(data: [tModel]));

      final result = await repository.getSectors(tSector.companyId);

      expect(result, isA<SuccessState<List<SectorEntity>>>());
      expect(
        (result as SuccessState<List<SectorEntity>>).data?.first.id,
        tSector.id,
      );
      verify(() => mockLocalDataSource.getSectors(tSector.companyId)).called(1);
    });
  });
}
