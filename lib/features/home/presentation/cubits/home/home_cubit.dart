import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeState> {
  HomeCubit() : super(const HomeState.empty());
}