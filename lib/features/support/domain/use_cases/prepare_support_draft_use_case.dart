import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/support/domain/entities/support_draft_message_entity.dart';
import 'package:o_jogo_da_obra/features/support/domain/use_cases/prepare_support_draft_params.dart';

@LazySingleton()
final class PrepareSupportDraftUseCase
    implements UseCase<SupportDraftMessageEntity, PrepareSupportDraftParams> {
  const PrepareSupportDraftUseCase();

  static const int maxDescriptionLength = 2000;

  @override
  FutureData<SupportDraftMessageEntity> call(
    PrepareSupportDraftParams request,
  ) async {
    final trimmed = request.userDescription.trim();

    if (trimmed.isEmpty) {
      return FailureState(
        message: 'empty_description',
        error: 'Description cannot be empty',
      );
    }

    if (request.userDescription.length > maxDescriptionLength) {
      return FailureState(
        message: 'description_too_long',
        error:
            'Description exceeds maximum length of $maxDescriptionLength characters',
      );
    }

    final subject = '[${request.appName}] ${request.subjectPrefix}';

    final buffer = StringBuffer()
      ..writeln('Descrição:')
      ..writeln(request.userDescription)
      ..writeln()
      ..writeln('---')
      ..writeln('Aplicativo: ${request.appName}')
      ..writeln('Plataforma: ${request.platformName}');

    return SuccessState(
      data: SupportDraftMessageEntity(
        subject: subject,
        body: buffer.toString(),
        destination: request.destinationEmail.trim(),
      ),
    );
  }
}
