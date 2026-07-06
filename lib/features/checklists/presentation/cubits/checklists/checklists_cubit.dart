import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'checklists_state.dart';

@injectable
class ChecklistsCubit extends BaseCubit<ChecklistsState> {
  ChecklistsCubit() : super(const ChecklistsState.empty());
}
