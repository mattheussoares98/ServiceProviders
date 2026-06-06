import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'checklists_state.dart';

@injectable
class ChecklistsCubit extends BaseCubit<ChecklistsState> {
  ChecklistsCubit() : super(const ChecklistsState.empty());
}