import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sync/data/data_sources/sync_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sync/data/models/sync_error_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/system_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late SyncRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(
      SyncErrorModel.fromEntity(SystemFactory.makeSyncErrorEntity()),
    );
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = SyncRemoteDataSourceImpl(database: mockDatabase);
  });

  final tEntity = SystemFactory.makeSyncErrorEntity();
  final tModel = SyncErrorModel.fromEntity(tEntity);

  group('SyncRemoteDataSourceImpl', () {
    group('reportSyncError', () {
      test(
        'should return SuccessState(data: true) when insert succeeds',
        () async {
          when(
            () => mockDatabase.insert(
              table: any(named: 'table'),
              values: any(named: 'values'),
            ),
          ).thenAnswer((_) async => [tModel.toJson()]);

          final result = await dataSource.reportSyncError(tModel);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockDatabase.insert(
              table: 'sync_errors',
              values: tModel.toJson(),
            ),
          ).called(1);
        },
      );

      test('should return FailureState when insert throws exception', () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenThrow(Exception('Supabase DB connection error'));

        final result = await dataSource.reportSyncError(tModel);

        expect(result, isA<FailureState<bool>>());
      });
    });
  });
}
