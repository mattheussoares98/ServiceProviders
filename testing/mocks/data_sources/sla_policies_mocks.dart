import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_remote_data_source.dart';

class MockSlaRemoteDataSource extends Mock implements SlaRemoteDataSource {}

class MockSlaLocalDataSource extends Mock implements SlaLocalDataSource {}
