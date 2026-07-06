import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'attachments_state.dart';

@injectable
class AttachmentsCubit extends BaseCubit<AttachmentsState> {
  AttachmentsCubit() : super(const AttachmentsState.empty());
}
