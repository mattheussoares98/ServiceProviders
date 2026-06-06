import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'attachments_state.dart';

@injectable
class AttachmentsCubit extends BaseCubit<AttachmentsState> {
  AttachmentsCubit() : super(const AttachmentsState.empty());
}