import 'package:o_jogo_da_obra/features/support/domain/entities/support_channel_entity.dart';
import 'package:o_jogo_da_obra/features/support/domain/entities/support_channel_type.dart';
import 'package:o_jogo_da_obra/features/support/domain/entities/support_draft_message_entity.dart';
import 'package:o_jogo_da_obra/features/support/domain/use_cases/prepare_support_draft_params.dart';

abstract final class SupportFactory {
  static SupportChannelEntity makeSupportChannelEntity({
    SupportChannelType type = SupportChannelType.email,
    String destination = 'contact@soarescodes.com.br',
    bool isAvailable = true,
    String? unavailableReason,
  }) {
    return SupportChannelEntity(
      type: type,
      destination: destination,
      isAvailable: isAvailable,
      unavailableReason: unavailableReason,
    );
  }

  static SupportDraftMessageEntity makeSupportDraftMessageEntity({
    String subject = '[Test App] Suporte',
    String body =
        'Descrição:\nPreciso de ajuda com o aplicativo.\n\n---\nAplicativo: Test App\nPlataforma: web',
    String destination = 'contact@soarescodes.com.br',
  }) {
    return SupportDraftMessageEntity(
      subject: subject,
      body: body,
      destination: destination,
    );
  }

  static PrepareSupportDraftParams makePrepareSupportDraftParams({
    String userDescription = 'Preciso de ajuda com o aplicativo.',
    String destinationEmail = 'contact@soarescodes.com.br',
    String appName = 'Test App',
    String platformName = 'web',
    String subjectPrefix = 'Suporte',
  }) {
    return PrepareSupportDraftParams(
      userDescription: userDescription,
      destinationEmail: destinationEmail,
      appName: appName,
      platformName: platformName,
      subjectPrefix: subjectPrefix,
    );
  }
}
