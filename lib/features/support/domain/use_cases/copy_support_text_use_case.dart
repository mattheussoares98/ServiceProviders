import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/services/platform_launcher_service.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

@LazySingleton()
final class CopySupportTextUseCase implements UseCase<LauncherResult, String> {
  const CopySupportTextUseCase({
    required PlatformLauncherService platformLauncherService,
  }) : _platformLauncherService = platformLauncherService;

  final PlatformLauncherService _platformLauncherService;

  @override
  FutureData<LauncherResult> call(String request) async {
    final result = await _platformLauncherService.copyToClipboard(request);

    if (result.isSuccess) {
      return SuccessState(data: result);
    }

    return FailureState(message: 'copy_failed', error: result.errorMessage);
  }
}
