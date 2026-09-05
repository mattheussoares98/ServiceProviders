import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/data_sources/access_logs_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/models/requests/create_access_log_request_model.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/models/responses/access_log_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabaseClient;
  late AccessLogsRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(
      CreateAccessLogRequestModel.fromEntity(
        EntityFactory.makeCreateAccessLogRequestEntity(),
      ),
    );
  });

  setUp(() {
    mockDatabaseClient = MockSupabaseDatabaseClient();
    dataSource = AccessLogsRemoteDataSourceImpl(database: mockDatabaseClient);
  });

  group('AccessLogsRemoteDataSource Tests', () {
    group('getAccessLogs', () {
      test('returns SuccessState when selectList succeeds', () async {
        final tEntity = EntityFactory.makeAccessLogEntity();
        final tModel = AccessLogModel.fromEntity(tEntity);
        final tRequest = EntityFactory.makeGetAccessLogsRequestEntity();

        when(
          () => mockDatabaseClient.selectList(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
            orderBy: any(named: 'orderBy'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [tModel.toJson()]);

        final result = await dataSource.getAccessLogs(tRequest);

        expect(result, isA<SuccessState<List<AccessLogModel>>>());
        expect(
          (result as SuccessState<List<AccessLogModel>>).data?.first.id,
          tModel.id,
        );
      });

      test('returns FailureState when selectList throws', () async {
        final tRequest = EntityFactory.makeGetAccessLogsRequestEntity();

        when(
          () => mockDatabaseClient.selectList(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
            orderBy: any(named: 'orderBy'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('Database error'));

        final result = await dataSource.getAccessLogs(tRequest);

        expect(result, isA<FailureState<List<AccessLogModel>>>());
      });
    });

    group('createAccessLog', () {
      test('returns SuccessState when insert succeeds', () async {
        final tRequest = CreateAccessLogRequestModel.fromEntity(
          EntityFactory.makeCreateAccessLogRequestEntity(),
        );

        when(
          () => mockDatabaseClient.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tRequest.toJson()]);

        final result = await dataSource.createAccessLog(tRequest);

        expect(result, isA<SuccessState<void>>());
      });

      test('returns FailureState when insert throws', () async {
        final tRequest = CreateAccessLogRequestModel.fromEntity(
          EntityFactory.makeCreateAccessLogRequestEntity(),
        );

        when(
          () => mockDatabaseClient.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenThrow(Exception('Insert error'));

        final result = await dataSource.createAccessLog(tRequest);

        expect(result, isA<FailureState<void>>());
      });
    });
  });
}
