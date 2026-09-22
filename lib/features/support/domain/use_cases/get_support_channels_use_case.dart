import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/config/app_config.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/support/domain/entities/support_channel_entity.dart';
import 'package:o_jogo_da_obra/features/support/domain/entities/support_channel_type.dart';

@LazySingleton()
final class GetSupportChannelsUseCase
    implements UseCaseNoParameter<List<SupportChannelEntity>> {
  const GetSupportChannelsUseCase({required AppConfig appConfig})
    : _appConfig = appConfig;

  final AppConfig _appConfig;

  // Standard email validation pattern
  static final RegExp _emailRegExp = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');

  @override
  FutureData<List<SupportChannelEntity>> call() async {
    final email = _appConfig.supportEmail.trim();

    if (email.isEmpty) {
      return const SuccessState(
        data: [
          SupportChannelEntity(
            type: SupportChannelType.email,
            destination: '',
            isAvailable: false,
            unavailableReason: 'unconfigured_email',
          ),
        ],
      );
    }

    if (!_emailRegExp.hasMatch(email)) {
      return SuccessState(
        data: [
          SupportChannelEntity(
            type: SupportChannelType.email,
            destination: email,
            isAvailable: false,
            unavailableReason: 'invalid_email',
          ),
        ],
      );
    }

    return SuccessState(
      data: [
        SupportChannelEntity(
          type: SupportChannelType.email,
          destination: email,
        ),
      ],
    );
  }
}
