import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class DeleteAttachmentUseCase implements UseCase<bool, String> {
  DeleteAttachmentUseCase(
      {required AttachmentsRepository attachmentsRepository})
      : _attachmentsRepository = attachmentsRepository;

  final AttachmentsRepository _attachmentsRepository;

  @override
  FutureBool call(String request) =>
      _attachmentsRepository.deleteAttachment(request);
}
