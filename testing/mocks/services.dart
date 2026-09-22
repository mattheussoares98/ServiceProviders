import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/services/platform_launcher_service.dart';
import 'package:o_jogo_da_obra/core/services/support_service.dart';
import 'package:o_jogo_da_obra/features/sync/domain/services/sync_engine.dart';

class MockFileService extends Mock implements FileService {}

class MockSyncEngine extends Mock implements SyncEngine {}

class MockPlatformLauncherService extends Mock
    implements PlatformLauncherService {}

class MockSupportService extends Mock implements SupportService {}
