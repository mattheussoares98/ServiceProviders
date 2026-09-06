import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/models/requests/create_access_log_request_model.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/models/responses/access_log_model.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/repositories/access_logs_repository_impl.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/factories/system_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockInternetClient mockInternet;
  late MockAccessLogsRemoteDataSource mockRemoteDataSource;
  late MockSyncRepository mockSyncRepository;
  late AccessLogsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      CreateAccessLogRequestModel.fromEntity(
        SystemFactory.makeCreateAccessLogRequestEntity(),
      ),
    );
    registerFallbackValue(SystemFactory.makeGetAccessLogsRequestEntity());
    registerFallbackValue(SystemFactory.makeSyncQueueItemEntity());
  });

  setUp(() {
    mockInternet = MockInternetClient();
    mockRemoteDataSource = MockAccessLogsRemoteDataSource();
    mockSyncRepository = MockSyncRepository();
    repository = AccessLogsRepositoryImpl(
      internet: mockInternet,
      remoteDataSource: mockRemoteDataSource,
      syncRepository: mockSyncRepository,
    );
  });

  group('AccessLogsRepositoryImpl Tests', () {
    group('getAccessLogs', () {
      final tRequest = SystemFactory.makeGetAccessLogsRequestEntity();
      final tEntity = SystemFactory.makeAccessLogEntity();
      final tModel = AccessLogModel.fromEntity(tEntity);

      test('fetches from remote when connected', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getAccessLogs(any()),
        ).thenAnswer((_) async => SuccessState(data: [tModel]));

        final result = await repository.getAccessLogs(tRequest);

        expect(result, isA<SuccessState<List<AccessLogEntity>>>());
        expect(
          (result as SuccessState<List<AccessLogEntity>>).data?.first.id,
          tEntity.id,
        );
        verify(() => mockRemoteDataSource.getAccessLogs(tRequest)).called(1);
      });

      test('returns no internet failure when disconnected', () async {
        when(() => mockInternet.isConnected).thenReturn(false);

        final result = await repository.getAccessLogs(tRequest);

        expect(result, isA<FailureState<List<AccessLogEntity>>>());
      });

      test('returns FailureState when remote fails', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getAccessLogs(any()),
        ).thenAnswer((_) async => FailureState(message: 'Remote error'));

        final result = await repository.getAccessLogs(tRequest);

        expect(result, isA<FailureState<List<AccessLogEntity>>>());
        expect(
          (result as FailureState<List<AccessLogEntity>>).message,
          'Remote error',
        );
      });
    });

    group('createAccessLog', () {
      final tRequest = SystemFactory.makeCreateAccessLogRequestEntity();

      test('calls remote create when connected', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.createAccessLog(any()),
        ).thenAnswer((_) async => SuccessState.nil);

        final result = await repository.createAccessLog(tRequest);

        expect(result, isA<SuccessState<void>>());
        verify(() => mockRemoteDataSource.createAccessLog(any())).called(1);
      });

      test('enqueues to SyncRepository when disconnected', () async {
        when(() => mockInternet.isConnected).thenReturn(false);
        when(
          () => mockSyncRepository.enqueue(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createAccessLog(tRequest);

        expect(result, isA<SuccessState<void>>());
        verify(() => mockSyncRepository.enqueue(any())).called(1);
      });

      test('enqueues to SyncRepository when remote fails', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.createAccessLog(any()),
        ).thenAnswer((_) async => FailureState(message: 'Remote error'));
        when(
          () => mockSyncRepository.enqueue(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createAccessLog(tRequest);

        expect(result, isA<SuccessState<void>>());
        verify(() => mockSyncRepository.enqueue(any())).called(1);
      });
    });
  });
}
