import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/checklists/data/data_sources/checklists_local_data_source.dart';
import 'package:o_jogo_da_obra/features/checklists/data/data_sources/checklists_remote_data_source.dart';

class MockChecklistsRemoteDataSource extends Mock
    implements ChecklistsRemoteDataSource {}

class MockChecklistsLocalDataSource extends Mock
    implements ChecklistsLocalDataSource {}
