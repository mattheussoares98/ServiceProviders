import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_local_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_remote_data_source.dart';

class MockAttachmentsRemoteDataSource extends Mock
    implements AttachmentsRemoteDataSource {}

class MockAttachmentsLocalDataSource extends Mock
    implements AttachmentsLocalDataSource {}
