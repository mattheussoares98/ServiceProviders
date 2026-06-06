import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetAttachmentsUseCase implements UseCase<String, String> {
  GetAttachmentsUseCase({required AttachmentsRepository attachmentsRepository})
      : _attachmentsRepository = attachmentsRepository;

  final AttachmentsRepository _attachmentsRepository;

  @override
  FutureData<String> call(String request) async => const SuccessState(data: '');
}
