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

    group('updateSector', () {
      final tSector = EntityFactory.makeSectorEntity();
      final tModel = SectorResponseModel.fromEntity(tSector);

      test(
        'calls remote update and saves locally when connected and remote succeeds',
        () async {
          when(() => mockInternet.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateSector(any()),
          ).thenAnswer((_) async => SuccessState(data: tModel));
          when(
            () => mockLocalDataSource.saveSector(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.updateSector(tSector);

          expect(result, isA<SuccessState<bool>>());
          expect((result as SuccessState<bool>).data, isTrue);
          verify(() => mockRemoteDataSource.updateSector(any())).called(1);
          verify(() => mockLocalDataSource.saveSector(tModel)).called(1);
        },
      );

      test(
        'returns FailureState when connected but remote update fails',
        () async {
          when(() => mockInternet.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateSector(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error'));

          final result = await repository.updateSector(tSector);

          expect(result, isA<FailureState<bool>>());
          expect((result as FailureState<bool>).message, 'Error');
        },
      );

      test('calls local save when disconnected', () async {
        when(() => mockInternet.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveSector(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.updateSector(tSector);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, isTrue);
        verify(() => mockLocalDataSource.saveSector(any())).called(1);
      });
    });

    group('deleteSector', () {
      final tSectorId = EntityFactory.makeSectorEntity().id;

      test(
        'calls remote delete and deletes locally when connected and remote succeeds',
        () async {
          when(() => mockInternet.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.deleteSector(any()),
          ).thenAnswer((_) async => SuccessState.nil);
          when(
            () => mockLocalDataSource.deleteSector(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.deleteSector(tSectorId);

          expect(result, isA<SuccessState<bool>>());
          expect((result as SuccessState<bool>).data, isTrue);
          verify(() => mockRemoteDataSource.deleteSector(tSectorId)).called(1);
          verify(() => mockLocalDataSource.deleteSector(tSectorId)).called(1);
        },
      );

      test(
        'returns FailureState when connected but remote delete fails',
        () async {
          when(() => mockInternet.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.deleteSector(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error'));

          final result = await repository.deleteSector(tSectorId);

          expect(result, isA<FailureState<bool>>());
          expect((result as FailureState<bool>).message, 'Error');
        },
      );

      test('calls local delete when disconnected', () async {
        when(() => mockInternet.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.deleteSector(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteSector(tSectorId);

        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, isTrue);
        verify(() => mockLocalDataSource.deleteSector(tSectorId)).called(1);
      });
    });
  });
}
