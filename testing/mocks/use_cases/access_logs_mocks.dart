import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/use_cases/create_access_log_use_case.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/use_cases/get_access_logs_use_case.dart';

class MockGetAccessLogsUseCase extends Mock implements GetAccessLogsUseCase {}

class MockCreateAccessLogUseCase extends Mock
    implements CreateAccessLogUseCase {}
