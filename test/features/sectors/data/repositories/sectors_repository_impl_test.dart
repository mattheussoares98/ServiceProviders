import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_model.dart';
import 'package:o_jogo_da_obra/features/sectors/data/repositories/sectors_repository_impl.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/system_factory.dart';

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
      SectorModel.fromEntity(SystemFactory.makeSectorEntity()),
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
    group('watchSectorsRealtime', () {
      final tSector = SystemFactory.makeSectorEntity();
      final tModel = SectorModel.fromEntity(tSector);

      test('saves to localDataSource on insert/update event', () async {
        when(
          () => mockRemoteDataSource.watchSectorsRealtime(
            companyId: any(named: 'companyId'),
          ),
        ).thenAnswer(
          (_) => Stream.value(
            RealtimeEvent<SectorModel>(
              eventType: RealtimeEventType.insert,
              id: tModel.id,
              companyId: tSector.companyId,
              entity: tModel,
            ),
          ),
        );
        when(
          () => mockLocalDataSource.saveSector(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final stream = repository.watchSectorsRealtime(
          companyId: tSector.companyId,
        );
        final event = await stream.first;

        expect(event.entity, equals(tSector));
        verify(() => mockLocalDataSource.saveSector(tModel)).called(1);
      });

      test(
        'deletes from localDataSource on update event when deletedAt is not null',
        () async {
          final deletedModel = SectorModel.fromEntity(
            tSector.copyWith(deletedAt: DateTime.now()),
          );
          when(
            () => mockRemoteDataSource.watchSectorsRealtime(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer(
            (_) => Stream.value(
              RealtimeEvent<SectorModel>(
                eventType: RealtimeEventType.update,
                id: deletedModel.id,
                companyId: tSector.companyId,
                entity: deletedModel,
              ),
            ),
          );
          when(
            () => mockLocalDataSource.deleteSector(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final stream = repository.watchSectorsRealtime(
            companyId: tSector.companyId,
          );
          await stream.first;

          verify(
            () => mockLocalDataSource.deleteSector(deletedModel.id),
          ).called(1);
        },
      );

      test('deletes from localDataSource on delete event', () async {
        when(
          () => mockRemoteDataSource.watchSectorsRealtime(
            companyId: any(named: 'companyId'),
          ),
        ).thenAnswer(
          (_) => Stream.value(
            RealtimeEvent<SectorModel>(
              eventType: RealtimeEventType.delete,
              id: tModel.id,
              companyId: tSector.companyId,
            ),
          ),
        );
        when(
          () => mockLocalDataSource.deleteSector(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final stream = repository.watchSectorsRealtime(
          companyId: tSector.companyId,
        );
        await stream.first;

        verify(() => mockLocalDataSource.deleteSector(tModel.id)).called(1);
      });
    });

    test(
      'getSectors fetches from remote and caches locally when connected',
      () async {
        final tSector = SystemFactory.makeSectorEntity();
        final tModel = SectorModel.fromEntity(tSector);

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
      final tSector = SystemFactory.makeSectorEntity();
      final tModel = SectorModel.fromEntity(tSector);

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
      final tSector = SystemFactory.makeSectorEntity();
      final tModel = SectorModel.fromEntity(tSector);

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
      final tSectorId = SystemFactory.makeSectorEntity().id;

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
