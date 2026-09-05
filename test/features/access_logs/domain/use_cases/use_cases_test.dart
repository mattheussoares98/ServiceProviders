import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/use_cases/create_access_log_use_case.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/use_cases/get_access_logs_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockAccessLogsRepository mockRepository;
  late GetAccessLogsUseCase getAccessLogsUseCase;
  late CreateAccessLogUseCase createAccessLogUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeGetAccessLogsRequestEntity());
    registerFallbackValue(EntityFactory.makeCreateAccessLogRequestEntity());
  });

  setUp(() {
    mockRepository = MockAccessLogsRepository();
    getAccessLogsUseCase = GetAccessLogsUseCase(
      accessLogsRepository: mockRepository,
    );
    createAccessLogUseCase = CreateAccessLogUseCase(
      accessLogsRepository: mockRepository,
    );
  });

  group('GetAccessLogsUseCase', () {
    test('returns SuccessState when repository succeeds', () async {
      final tLogs = EntityFactory.makeAccessLogEntityList();
      final tRequest = EntityFactory.makeGetAccessLogsRequestEntity();

      when(
        () => mockRepository.getAccessLogs(any()),
      ).thenAnswer((_) async => SuccessState(data: tLogs));

      final result = await getAccessLogsUseCase(tRequest);

      expect(result, isA<SuccessState<List<AccessLogEntity>>>());
      expect((result as SuccessState<List<AccessLogEntity>>).data, tLogs);
      verify(() => mockRepository.getAccessLogs(tRequest)).called(1);
    });

    test('returns FailureState when repository fails', () async {
      final tRequest = EntityFactory.makeGetAccessLogsRequestEntity();
      const tError = 'Failed to load access logs';

      when(
        () => mockRepository.getAccessLogs(any()),
      ).thenAnswer((_) async => FailureState(message: tError));

      final result = await getAccessLogsUseCase(tRequest);

      expect(result, isA<FailureState<List<AccessLogEntity>>>());
      expect((result as FailureState<List<AccessLogEntity>>).message, tError);
      verify(() => mockRepository.getAccessLogs(tRequest)).called(1);
    });
  });

  group('CreateAccessLogUseCase', () {
    test('returns SuccessState when repository succeeds', () async {
      final tRequest = EntityFactory.makeCreateAccessLogRequestEntity();

      when(
        () => mockRepository.createAccessLog(any()),
      ).thenAnswer((_) async => SuccessState.nil);

      final result = await createAccessLogUseCase(tRequest);

      expect(result, isA<SuccessState<void>>());
      verify(() => mockRepository.createAccessLog(tRequest)).called(1);
    });

    test('returns FailureState when repository fails', () async {
      final tRequest = EntityFactory.makeCreateAccessLogRequestEntity();
      const tError = 'Failed to record access log';

      when(
        () => mockRepository.createAccessLog(any()),
      ).thenAnswer((_) async => FailureState(message: tError));

      final result = await createAccessLogUseCase(tRequest);

      expect(result, isA<FailureState<void>>());
      expect((result as FailureState<void>).message, tError);
      verify(() => mockRepository.createAccessLog(tRequest)).called(1);
    });
  });
}
