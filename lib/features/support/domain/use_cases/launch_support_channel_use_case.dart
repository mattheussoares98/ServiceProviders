import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/services/platform_launcher_service.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/support/domain/entities/support_draft_message_entity.dart';

@LazySingleton()
final class LaunchSupportChannelUseCase
    implements UseCase<LauncherResult, SupportDraftMessageEntity> {
  const LaunchSupportChannelUseCase({
    required PlatformLauncherService platformLauncherService,
  }) : _platformLauncherService = platformLauncherService;

  final PlatformLauncherService _platformLauncherService;

  @override
  FutureData<LauncherResult> call(SupportDraftMessageEntity request) async {
    final queryParameters = <String, String>{
      'subject': request.subject,
      'body': request.body,
    };

    final emailUri = Uri(
      scheme: 'mailto',
      path: request.destination,
      query: queryParameters.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&'),
    );

    final result = await _platformLauncherService.launchExternalUri(emailUri);

    if (result.isSuccess) {
      return SuccessState(data: result);
    }

    return FailureState(
      message: result.isCannotLaunch ? 'cannot_launch' : 'launch_failed',
      error: result.errorMessage,
    );
  }
}
